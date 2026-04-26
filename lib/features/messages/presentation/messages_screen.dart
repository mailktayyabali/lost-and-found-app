import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_bottom_nav_bar.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
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
                color: const Color(0xFFF1F5F9), // Light grey matching image
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10), // centers text with 40 height
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          
          Expanded(
            child: ListView(
              children: [
                _buildMessageTile(context,
                  name: 'Sarah Miller',
                  message: 'Is this the brown wallet you lo...',
                  time: '2:45 PM',
                  isUnread: true,
                  isOnline: true,
                  avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
                  itemImageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                ),
                _buildMessageTile(context,
                  name: 'Alex Johnson',
                  message: 'I found your keys near the park e...',
                  time: 'Yesterday',
                  isUnread: false,
                  isOnline: false,
                  avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
                  itemImageUrl: 'https://images.unsplash.com/photo-1584447128309-8d76ae5cb3f7?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                ),
                _buildMessageTile(context,
                  name: 'Jordan Smith',
                  message: 'Thanks for returning my dog! He...',
                  time: 'Monday',
                  isUnread: false,
                  isOnline: false,
                  avatarUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
                  itemImageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 3), // Pass index 3 for Messages tab
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  userName: name,
                  avatarUrl: avatarUrl,
                  isOnline: isOnline,
                ),
              ),
            );
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
                      color: const Color(0xFF10B981), // Green status dot
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
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
                  color: isUnread ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8), // Sameish color, mostly font weight differs
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
                    color: isUnread ? AppColors.primaryTeal : const Color(0xFF64748B),
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
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              // Item Image
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFFF1F5F9),
                  image: DecorationImage(
                    image: NetworkImage(itemImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
      ],
    );
  }
}
