import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_service.dart';
import 'widgets/notification_section_header.dart';
import 'widgets/alert_notification_item.dart';
import 'widgets/chat_notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static String _calculateTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      return 'Just now';
    }

    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()}w ago';
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

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.colors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: context.colors.buttonBlue),
            onPressed: () async {
              if (currentUser == null) return;
              // Mark all as read
              final batch = FirebaseFirestore.instance.batch();
              final unread = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('recipientId', isEqualTo: currentUser.uid)
                  .where('isRead', isEqualTo: false)
                  .get();
              for (var doc in unread.docs) {
                batch.update(doc.reference, {'isRead': true});
              }
              await batch.commit();
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please sign in to view notifications.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('recipientId', isEqualTo: currentUser.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading notifications: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                final alerts = docs.where((d) => (d.data() as Map<String, dynamic>)['type'] == 'alert').toList();
                final chats = docs.where((d) => (d.data() as Map<String, dynamic>)['type'] == 'chat').toList();
                final systems = docs.where((d) => (d.data() as Map<String, dynamic>)['type'] == 'system').toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: context.colors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          'All caught up!',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  children: [
                    // MATCHING ALERTS
                    if (alerts.isNotEmpty) ...[
                      NotificationSectionHeader(
                        title: 'Matching Alerts',
                        icon: Icons.stars,
                        iconColor: context.colors.buttonBlue,
                      ),
                      ...alerts.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return AlertNotificationItem(
                          icon: Icons.search,
                          iconColor: context.colors.buttonBlue,
                          iconBackgroundColor: const Color(0xFFE8F2FF),
                          title: data['title'] ?? 'Alert',
                          subtitle: data['description'] ?? '',
                          timeAgo: _calculateTimeAgo(data['createdAt']),
                        );
                      }),
                    ],

                    // CHAT ALERTS
                    if (chats.isNotEmpty) ...[
                      NotificationSectionHeader(
                        title: 'Chat Alerts',
                        icon: Icons.chat_bubble,
                        iconColor: context.colors.textLight,
                      ),
                      ...chats.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ChatNotificationItem(
                          avatarUrl: data['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
                          title: data['title'] ?? 'New Message',
                          subtitle: data['description'] ?? '',
                          timeAgo: _calculateTimeAgo(data['createdAt']),
                          isUnread: !(data['isRead'] ?? false),
                        );
                      }),
                    ],

                    // SYSTEM ALERTS
                    if (systems.isNotEmpty) ...[
                      NotificationSectionHeader(
                        title: 'System Alerts',
                        icon: Icons.settings,
                        iconColor: context.colors.textLight,
                      ),
                      ...systems.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return AlertNotificationItem(
                          icon: Icons.security,
                          iconColor: context.colors.textLight,
                          iconBackgroundColor: context.colors.background,
                          title: data['title'] ?? 'Security Alert',
                          subtitle: data['description'] ?? '',
                          timeAgo: _calculateTimeAgo(data['createdAt']),
                        );
                      }),
                    ],
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
    );
  }
}
