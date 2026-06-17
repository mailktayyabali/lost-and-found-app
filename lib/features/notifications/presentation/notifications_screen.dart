import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/domain/auth_service.dart';
import 'providers/notifications_provider.dart';
import 'widgets/alert_notification_item.dart';
import 'widgets/chat_notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService().currentUser;
    final notificationsAsync = ref.watch(notificationsStreamProvider);

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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final primaryTealColor = context.colors.primaryTeal;
              try {
                final unread = await FirebaseFirestore.instance
                    .collection('notifications')
                    .where('recipientId', isEqualTo: currentUser.uid)
                    .where('isRead', isEqualTo: false)
                    .get();
                
                if (unread.docs.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('No unread notifications to mark.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Chunk into sizes of 500
                final docs = unread.docs;
                const chunkSize = 500;
                for (var i = 0; i < docs.length; i += chunkSize) {
                  final chunk = docs.sublist(i, i + chunkSize > docs.length ? docs.length : i + chunkSize);
                  final batch = FirebaseFirestore.instance.batch();
                  for (var doc in chunk) {
                    batch.update(doc.reference, {'isRead': true});
                  }
                  await batch.commit();
                }

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: const Text('All notifications marked as read.'),
                    backgroundColor: primaryTealColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                debugPrint('NotificationsScreen: Error marking all read: $e');
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to mark notifications: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please sign in to view notifications.'))
          : notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading notifications: $err')),
              data: (docs) {
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

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final type = data['type'] ?? 'alert';
                    
                    if (type == 'chat') {
                      return ChatNotificationItem(
                        avatarUrl: data['avatarUrl'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
                        title: data['title'] ?? 'New Message',
                        subtitle: data['description'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
                        isUnread: !(data['isRead'] ?? false),
                      );
                    } else if (type == 'system') {
                      return AlertNotificationItem(
                        icon: Icons.security,
                        iconColor: context.colors.textLight,
                        iconBackgroundColor: context.colors.background,
                        title: data['title'] ?? 'Security Alert',
                        subtitle: data['description'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
                      );
                    } else if (type == 'claim') {
                      return AlertNotificationItem(
                        icon: Icons.verified,
                        iconColor: context.colors.primaryTeal,
                        iconBackgroundColor: context.colors.primaryTeal.withValues(alpha: 0.1),
                        title: data['title'] ?? 'Claim Request',
                        subtitle: data['description'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
                      );
                    } else {
                      return AlertNotificationItem(
                        icon: Icons.search,
                        iconColor: context.colors.buttonBlue,
                        iconBackgroundColor: const Color(0xFFE8F2FF),
                        title: data['title'] ?? 'Alert',
                        subtitle: data['description'] ?? '',
                        timeAgo: _calculateTimeAgo(data['createdAt']),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
