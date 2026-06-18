import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign In with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserDocumentExists(credential.user);
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Up with email and password
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String name = '',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'role': email == 'admin@findit.com' ? 'admin' : 'user', // Set admin role for main admin email
          'isBanned': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Ensure user record exists in Firestore
  Future<void> _ensureUserDocumentExists(User? user) async {
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'role': user.email == 'admin@findit.com' ? 'admin' : 'user',
        'isBanned': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get current user role
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'user';
      }
      return 'user';
    } catch (e) {
      return 'user';
    }
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    
    // Developer Backdoor: Automatically grant admin access to the sole admin email
    if (user.email == 'admin@findit.com') {
      return true;
    }

    final role = await getUserRole(user.uid);
    return role == 'admin';
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Sign In with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Force account selection by signing out first
      await _googleSignIn.signOut();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by the user');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Ensure user record exists in Firestore
      if (userCredential.user != null) {
        await _ensureUserDocumentExists(userCredential.user);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // Update user profile in Firestore
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String bio,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Re-authenticate user with email and password
  Future<void> reauthenticateWithEmail(String password) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in or email is null');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  // Re-authenticate user with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by the user');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account and Firestore related data
  Future<void> deleteUserAccountAndData() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }
    final uid = user.uid;

    // 1. Delete all Firestore related data
    // A. Delete saved_items subcollection under users/uid
    final savedItemsSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('saved_items')
        .get();
    for (var doc in savedItemsSnapshot.docs) {
      await doc.reference.delete();
    }

    // B. Delete users/uid document
    await _firestore.collection('users').doc(uid).delete();

    // C. Delete reports where createdBy == uid
    final reportsSnapshot = await _firestore
        .collection('reports')
        .where('createdBy', isEqualTo: uid)
        .get();
    for (var doc in reportsSnapshot.docs) {
      await doc.reference.delete();
    }

    // D. Delete claim_requests where requesterUid == uid or ownerUid == uid
    final claimsByRequester = await _firestore
        .collection('claim_requests')
        .where('requesterUid', isEqualTo: uid)
        .get();
    for (var doc in claimsByRequester.docs) {
      await doc.reference.delete();
    }

    final claimsByOwner = await _firestore
        .collection('claim_requests')
        .where('ownerUid', isEqualTo: uid)
        .get();
    for (var doc in claimsByOwner.docs) {
      await doc.reference.delete();
    }

    // E. Delete notifications where recipientId == uid
    final notificationsSnapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: uid)
        .get();
    for (var doc in notificationsSnapshot.docs) {
      await doc.reference.delete();
    }

    // F. Delete reviews where reviewerUid == uid or revieweeUid == uid
    final reviewsByReviewer = await _firestore
        .collection('reviews')
        .where('reviewerUid', isEqualTo: uid)
        .get();
    for (var doc in reviewsByReviewer.docs) {
      await doc.reference.delete();
    }

    final reviewsByReviewee = await _firestore
        .collection('reviews')
        .where('revieweeUid', isEqualTo: uid)
        .get();
    for (var doc in reviewsByReviewee.docs) {
      await doc.reference.delete();
    }

    // G. Delete chats where participantIds contains uid
    final chatsSnapshot = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .get();
    for (var chatDoc in chatsSnapshot.docs) {
      // Delete messages subcollection
      final messagesSnapshot = await chatDoc.reference.collection('messages').get();
      for (var msgDoc in messagesSnapshot.docs) {
        await msgDoc.reference.delete();
      }
      // Delete chat document
      await chatDoc.reference.delete();
    }

    // 2. Delete Auth User account
    await user.delete();

    // 3. Clear Google sign-in state
    await _googleSignIn.signOut();
  }

  // Phone auth verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      await _ensureUserDocumentExists(userCredential.user);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}

