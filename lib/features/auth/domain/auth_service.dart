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
          'role': 'user', // Default role
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
        'role': 'user',
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
    
    // Developer Backdoor: Automatically grant admin access to these test emails
    if (user.email == 'admin@admin.com' || user.email == 'admin@lostandfound.com') {
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
}
