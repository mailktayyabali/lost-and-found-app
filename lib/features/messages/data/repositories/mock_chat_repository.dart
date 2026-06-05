import '../../domain/repositories/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  static final MockChatRepository _instance = MockChatRepository._internal();
  factory MockChatRepository() => _instance;
  MockChatRepository._internal();

  final Map<String, List<Map<String, dynamic>>> _messagesDb = {
    'test_user_4': [
      {
        'text': 'Hi there! I think I found your wallet at the Central Park bench near the fountain.',
        'time': '10:24 AM',
        'isMe': false,
      },
      {
        'text': 'Oh thank goodness! Does it have a library card with the name "Alex" inside?',
        'time': '10:25 AM',
        'isMe': true,
      },
      {
        'text': 'Yes, it does. I checked inside and found a library card with your name.',
        'time': '10:27 AM',
        'isMe': false,
      },
      {
        'text': "That's definitely mine! Where can we meet for the handover? I'm happy to...",
        'time': '10:28 AM',
        'isMe': true,
      },
    ],
    'test_user_3': [
      {
        'text': "Hi, I have a match for your item.",
        'time': 'Yesterday',
        'isMe': false,
      }
    ]
  };

  final List<Map<String, dynamic>> _conversations = [
    {
      'partnerUid': 'test_user_4',
      'name': 'Sarah Miller',
      'message': 'Is this the brown wallet you lo...',
      'time': '2:45 PM',
      'isUnread': true,
      'isOnline': true,
      'avatarUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
      'itemImageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
    },
    {
      'partnerUid': 'test_user_5',
      'name': 'Alex Johnson',
      'message': 'I found your keys near the park e...',
      'time': 'Yesterday',
      'isUnread': false,
      'isOnline': false,
      'avatarUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
      'itemImageUrl': 'https://images.unsplash.com/photo-1584447128309-8d76ae5cb3f7?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
    },
    {
      'partnerUid': 'test_user_6',
      'name': 'Jordan Smith',
      'message': 'Thanks for returning my dog! He...',
      'time': 'Monday',
      'isUnread': false,
      'isOnline': false,
      'avatarUrl': 'https://randomuser.me/api/portraits/men/22.jpg',
      'itemImageUrl': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
    },
    {
      'partnerUid': 'test_user_3',
      'name': 'Marcus Chen',
      'message': 'Hi, I have a match for your item.',
      'time': 'Yesterday',
      'isUnread': false,
      'isOnline': true,
      'avatarUrl': 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
      'itemImageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
    }
  ];

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    return List.from(_conversations);
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(String chatPartnerUid) async {
    return List.from(_messagesDb[chatPartnerUid] ?? []);
  }

  @override
  Future<void> sendMessage(String chatPartnerUid, String text) async {
    if (!_messagesDb.containsKey(chatPartnerUid)) {
      _messagesDb[chatPartnerUid] = [];
    }
    _messagesDb[chatPartnerUid]!.add({
      'text': text,
      'time': 'Just now',
      'isMe': true,
    });

    final index = _conversations.indexWhere((c) => c['partnerUid'] == chatPartnerUid);
    if (index != -1) {
      _conversations[index]['message'] = text;
      _conversations[index]['time'] = 'Just now';
      _conversations[index]['isUnread'] = false;
    } else {
      _conversations.insert(0, {
        'partnerUid': chatPartnerUid,
        'name': 'User $chatPartnerUid',
        'message': text,
        'time': 'Just now',
        'isUnread': false,
        'isOnline': true,
        'avatarUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
        'itemImageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
      });
    }
  }
}
