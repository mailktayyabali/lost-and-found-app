import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../home/presentation/home_screen.dart';
import '../data/repositories/mock_chat_repository.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MockChatRepository _chatRepository = MockChatRepository();
  List<Map<String, dynamic>> _conversations = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final list = await _chatRepository.getConversations();
    setState(() {
      _conversations = list;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((c) {
      final name = c['name'].toString().toLowerCase();
      final msg = c['message'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || msg.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textDark, size: 20),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: context.colors.textDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: context.colors.textLight, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: context.colors.background),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredConversations.isEmpty
                    ? Center(
                        child: Text(
                          'No conversations found',
                          style: TextStyle(color: context.colors.textLight),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conv = _filteredConversations[index];
                          return _buildMessageTile(
                            context,
                            name: conv['name'],
                            message: conv['message'],
                            time: conv['time'],
                            isUnread: conv['isUnread'],
                            isOnline: conv['isOnline'],
                            avatarUrl: conv['avatarUrl'],
                            itemImageUrl: conv['itemImageUrl'],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildMessageTile(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required bool isUnread,
    required bool isOnline,
    required String avatarUrl,
    required String itemImageUrl,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  userName: name,
                  avatarUrl: avatarUrl,
                  isOnline: isOnline,
                ),
              ),
            );
            _loadConversations(); // Reload conversation list when returning
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surfaceWhite, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.colors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                  color: context.colors.textLight,
                ),
              ),
            ],
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isUnread ? context.colors.primaryTeal : context.colors.textLight,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: context.colors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.colors.background,
                  image: DecorationImage(
                    image: NetworkImage(itemImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.background),
      ],
    );
  }
}

