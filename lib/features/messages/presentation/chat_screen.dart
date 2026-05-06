import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ChatScreen extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.avatarUrl,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leadingWidth: 40,
          leading: IconButton(
            padding: const EdgeInsets.only(left: 16),
            icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textDark, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    userName,
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isOnline)
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert, color: context.colors.textDark),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Post reference banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.background,
              border: Border(
                top: BorderSide(color: context.colors.dividerColor),
                bottom: BorderSide(color: context.colors.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.dividerColor),
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1627123424574-724758594e9f?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REGARDING YOUR POST',
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lost: Brown Leather Wallet',
                        style: TextStyle(
                          color: context.colors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.info, color: AppColors.primaryTeal, size: 20),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Date separator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.dividerColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'TODAY',
                      style: TextStyle(
                        color: context.colors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Incoming Message
                _buildIncomingMessage(context,
                  text: 'Hi there! I think I found your wallet at the Central Park bench near the fountain.',
                  time: '10:24 AM',
                  avatarUrl: avatarUrl,
                ),
                const SizedBox(height: 24),

                // Outgoing Message
                _buildOutgoingMessage(context,
                  text: 'Oh thank goodness! Does it have a library card with the name "Alex" inside?',
                  time: '10:25 AM',
                ),
                const SizedBox(height: 24),

                // Incoming Message without Image
                _buildIncomingMessage(context,
                  text: 'Yes, it does. I checked inside and found a library card with your name.',
                  time: '10:27 AM',
                  avatarUrl: avatarUrl,
                ),
                const SizedBox(height: 24),

                // Outgoing Message
                _buildOutgoingMessage(context,
                  text: "That's definitely mine! Where can we meet for the handover? I'm happy to...",
                  time: '10:28 AM',
                ),
              ],
            ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surfaceWhite,
              border: Border(top: BorderSide(color: context.colors.dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.textLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: context.colors.surfaceWhite, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        style: TextStyle(color: context.colors.textDark),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: context.colors.textLight, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingMessage(BuildContext context, {
    required String text,
    required String time,
    required String avatarUrl,
    String? imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: context.colors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: context.colors.textDark,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (imageUrl != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          height: 160,
                          width: double.infinity,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Pad right side so it doesn't stretch to the edge
      ],
    );
  }

  Widget _buildOutgoingMessage(BuildContext context, {
    required String text,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40), // Pad left side
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: AppColors.primaryTeal, size: 14),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primaryTeal,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'ME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
