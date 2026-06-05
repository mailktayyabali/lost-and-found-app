import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton instance
  static final FirebaseChatRepository _instance = FirebaseChatRepository._internal();
  factory FirebaseChatRepository() => _instance;
  FirebaseChatRepository._internal();

  String get _currentUserId => _auth.currentUser?.uid ?? 'anonymous';

  // Helper: calculate time ago string from Firestore Timestamp
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Find partner's UID by name
  Future<String> _resolvePartnerUid(String name) async {
    final query = await _firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    // Fallback deterministic ID for mock users
    return 'mock_user_${name.replaceAll(' ', '_').toLowerCase()}';
  }

  // Find chat document by partner's name
  Future<DocumentSnapshot?> _findChatDocByPartnerName(String partnerName) async {
    final userId = _currentUserId;
    if (userId == 'anonymous') return null;

    final query = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .get();

    for (var doc in query.docs) {
      final info = doc.data()['participantsInfo'] as Map<String, dynamic>?;
      if (info != null) {
        for (var entry in info.entries) {
          if (entry.key != userId && entry.value['name'] == partnerName) {
            return doc;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = _currentUserId;
    if (userId == 'anonymous') return [];

    try {
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTimestamp', descending: true)
          .get();

      List<Map<String, dynamic>> conversations = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final participantIds = List<String>.from(data['participantIds'] ?? []);
        final partnerId = participantIds.firstWhere((id) => id != userId, orElse: () => '');
        if (partnerId.isEmpty) continue;

        final info = data['participantsInfo'] as Map<String, dynamic>?;
        final partnerInfo = info?[partnerId] as Map<String, dynamic>?;

        final unreadCount = (data['unreadCounts'] as Map<String, dynamic>?)?[userId] ?? 0;

        conversations.add({
          'name': partnerInfo?['name'] ?? 'Unknown User',
          'message': data['lastMessageText'] ?? '',
          'time': _formatTimestamp(data['lastMessageTimestamp']),
          'isUnread': unreadCount > 0,
          'isOnline': partnerInfo?['isOnline'] ?? false,
          'avatarUrl': partnerInfo?['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
          'itemImageUrl': data['relatedItemImageUrl'] ?? 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
        });
      }
      return conversations;
    } catch (e) {
      // Return empty or fallback if index is not ready yet
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerName) async {
    final chatDoc = await _findChatDocByPartnerName(chatPartnerName);
    if (chatDoc == null) return [];

    // Mark messages as read
    final userId = _currentUserId;
    await _firestore.collection('chats').doc(chatDoc.id).update({
      'unreadCounts.$userId': 0,
    });

    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatDoc.id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return messagesSnapshot.docs.map((doc) {
      final data = doc.data();
      final senderId = data['senderId'] ?? '';
      return {
        'text': data['text'] ?? '',
        'time': _formatTimestamp(data['timestamp']),
        'isMe': senderId == userId,
      };
    }).toList();
  }

  // Stream version for real-time listener inside ChatScreen
  Stream<QuerySnapshot> getMessagesStream(String chatPartnerName) async* {
    final chatDoc = await _findChatDocByPartnerName(chatPartnerName);
    if (chatDoc != null) {
      // Clear unread count for current user
      final userId = _currentUserId;
      _firestore.collection('chats').doc(chatDoc.id).update({
        'unreadCounts.$userId': 0,
      });

      yield* _firestore
          .collection('chats')
          .doc(chatDoc.id)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    } else {
      // Yield empty stream
      yield* const Stream.empty();
    }
  }

  // Stream version of conversations list for real-time list updates
  Stream<QuerySnapshot> getConversationsStream() {
    final userId = _currentUserId;
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  @override
  Future<void> sendMessage(String chatPartnerName, String text) async {
    final userId = _currentUserId;
    if (userId == 'anonymous') return;

    final partnerUid = await _resolvePartnerUid(chatPartnerName);
    
    // Determine chatId deterministically
    final participantUids = [userId, partnerUid];
    participantUids.sort();
    final chatId = 'chat_${participantUids[0]}_${participantUids[1]}';

    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    final myName = _auth.currentUser?.displayName ?? 'Me';
    final myAvatar = _auth.currentUser?.photoURL ?? 'https://randomuser.me/api/portraits/men/32.jpg';

    // Get my current user info from Firestore users collection if display name is empty
    String resolvedMyName = myName;
    String resolvedMyAvatar = myAvatar;
    final myProfile = await _firestore.collection('users').doc(userId).get();
    if (myProfile.exists) {
      resolvedMyName = myProfile.data()?['name'] ?? myName;
      resolvedMyAvatar = myProfile.data()?['avatarUrl'] ?? myAvatar;
    }

    // Resolve partner info from database if available
    String partnerName = chatPartnerName;
    String partnerAvatar = 'https://randomuser.me/api/portraits/men/32.jpg';
    final partnerProfile = await _firestore.collection('users').doc(partnerUid).get();
    if (partnerProfile.exists) {
      partnerName = partnerProfile.data()?['name'] ?? partnerName;
      partnerAvatar = partnerProfile.data()?['avatarUrl'] ?? partnerAvatar;
    }

    final messageData = {
      'text': text,
      'senderId': userId,
      'senderName': resolvedMyName,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    final batch = _firestore.batch();

    if (!chatDoc.exists) {
      // Create new chat room document
      batch.set(chatRef, {
        'id': chatId,
        'participantIds': [userId, partnerUid],
        'participantsInfo': {
          userId: {
            'name': resolvedMyName,
            'avatarUrl': resolvedMyAvatar,
            'isOnline': true,
          },
          partnerUid: {
            'name': partnerName,
            'avatarUrl': partnerAvatar,
            'isOnline': false,
          }
        },
        'lastMessageText': text,
        'lastMessageSenderId': userId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts': {
          partnerUid: 1,
          userId: 0,
        },
        'relatedItemId': 'default',
        'relatedItemTitle': 'Item Inquiry',
        'relatedItemImageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
      });
    } else {
      // Update existing chat room details
      final currentUnread = (chatDoc.data()?['unreadCounts'] as Map<String, dynamic>?)?[partnerUid] ?? 0;
      batch.update(chatRef, {
        'lastMessageText': text,
        'lastMessageSenderId': userId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts.$partnerUid': currentUnread + 1,
        // Sync user details in case they changed
        'participantsInfo.$userId.name': resolvedMyName,
        'participantsInfo.$userId.avatarUrl': resolvedMyAvatar,
      });
    }

    // Write message document to subcollection
    final messageRef = chatRef.collection('messages').doc();
    batch.set(messageRef, messageData);

    await batch.commit();
  }
}
