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

  // Validate the existence of partner UID via a direct Firestore query
  Future<String> _resolvePartnerUid(String uid) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('Partner UID cannot be null or empty');
    }
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) {
      throw StateError('Partner user with UID $uid does not exist in the database');
    }
    return uid;
  }

  // Find chat document by partner's UID
  Future<DocumentSnapshot?> _findChatDocByPartnerUid(String partnerUid) async {
    final userId = _currentUserId;
    if (userId == 'anonymous') return null;

    final query = await _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .get();

    for (var doc in query.docs) {
      final participantIds = List<String>.from(doc.data()['participantIds'] ?? []);
      if (participantIds.contains(partnerUid)) {
        return doc;
      }
    }
    return null;
  }

  // Public exposure to look up chat room document snapshot
  Future<DocumentSnapshot?> getChatRoomByPartnerUid(String partnerUid) async {
    return _findChatDocByPartnerUid(partnerUid);
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

      return _parseConversations(querySnapshot.docs, userId);
    } catch (e) {
      // Fallback if index is not ready yet
      try {
        final querySnapshot = await _firestore
            .collection('chats')
            .where('participantIds', arrayContains: userId)
            .get();
        final conversations = _parseConversations(querySnapshot.docs, userId);
        conversations.sort((a, b) {
          final aTime = a['rawTimestamp'] as Timestamp?;
          final bTime = b['rawTimestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        return conversations;
      } catch (err) {
        return [];
      }
    }
  }

  List<Map<String, dynamic>> _parseConversations(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String userId) {
    List<Map<String, dynamic>> conversations = [];

    for (var doc in docs) {
      final data = doc.data();
      final participantIds = List<String>.from(data['participantIds'] ?? []);
      final partnerId = participantIds.firstWhere((id) => id != userId, orElse: () => '');
      if (partnerId.isEmpty) continue;

      final info = data['participantsInfo'] as Map<String, dynamic>?;
      final partnerInfo = info?[partnerId] as Map<String, dynamic>?;

      final unreadCount = (data['unreadCounts'] as Map<String, dynamic>?)?[userId] ?? 0;

      conversations.add({
        'partnerUid': partnerId,
        'name': partnerInfo?['name'] ?? 'Unknown User',
        'message': data['lastMessageText'] ?? '',
        'time': _formatTimestamp(data['lastMessageTimestamp']),
        'rawTimestamp': data['lastMessageTimestamp'],
        'isUnread': unreadCount > 0,
        'unreadCount': unreadCount,
        'isOnline': partnerInfo?['isOnline'] ?? false,
        'avatarUrl': partnerInfo?['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
        'itemImageUrl': data['relatedItemImageUrl'] ?? 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
        'relatedItemId': data['relatedItemId'] ?? 'default',
        'relatedItemTitle': data['relatedItemTitle'] ?? 'Item Inquiry',
      });
    }
    return conversations;
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerUid) async {
    final chatDoc = await _findChatDocByPartnerUid(chatPartnerUid);
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
  @override
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatPartnerUid) {
    final userId = _currentUserId;
    if (userId == 'anonymous') return const Stream.empty();

    final participantUids = [userId, chatPartnerUid];
    participantUids.sort();
    final chatId = 'chat_${participantUids[0]}_${participantUids[1]}';

    // Clear unread count for current user asynchronously
    _firestore.collection('chats').doc(chatId).update({
      'unreadCounts.$userId': 0,
    }).catchError((e) {
      // Ignore if chat room document doesn't exist in database yet
    });

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final senderId = data['senderId'] ?? '';
            return {
              'text': data['text'] ?? '',
              'time': _formatTimestamp(data['timestamp']),
              'isMe': senderId == userId,
            };
          }).toList();
        });
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

  // Fallback stream without orderBy for handling missing index error scenarios
  Stream<QuerySnapshot> getConversationsStreamFallback() {
    final userId = _currentUserId;
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots();
  }

  @override
  Future<void> sendMessage(
    String chatPartnerUid,
    String text, {
    String? itemId,
    String? itemTitle,
    String? itemImageUrl,
  }) async {
    final userId = _currentUserId;
    if (userId == 'anonymous') return;

    final partnerUid = await _resolvePartnerUid(chatPartnerUid);
    
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
    String partnerName = 'Unknown User';
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
        'relatedItemId': itemId ?? 'default',
        'relatedItemTitle': itemTitle ?? 'Item Inquiry',
        'relatedItemImageUrl': itemImageUrl ?? 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
      });
    } else {
      // Update existing chat room details
      final currentUnread = (chatDoc.data()?['unreadCounts'] as Map<String, dynamic>?)?[partnerUid] ?? 0;
      final Map<String, dynamic> updates = {
        'lastMessageText': text,
        'lastMessageSenderId': userId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'unreadCounts.$partnerUid': currentUnread + 1,
        // Sync user details in case they changed
        'participantsInfo.$userId.name': resolvedMyName,
        'participantsInfo.$userId.avatarUrl': resolvedMyAvatar,
      };

      if (itemId != null) updates['relatedItemId'] = itemId;
      if (itemTitle != null) updates['relatedItemTitle'] = itemTitle;
      if (itemImageUrl != null) updates['relatedItemImageUrl'] = itemImageUrl;

      batch.update(chatRef, updates);
    }

    // Write message document to subcollection
    final messageRef = chatRef.collection('messages').doc();
    batch.set(messageRef, messageData);

    // Write notification document for the recipient so it shows up in their notification feed
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'recipientId': partnerUid,
      'type': 'chat',
      'avatarUrl': resolvedMyAvatar,
      'title': resolvedMyName,
      'description': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await batch.commit();
  }
}
