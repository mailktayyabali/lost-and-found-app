import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/notification_section_header.dart';
import 'widgets/alert_notification_item.dart';
import 'widgets/chat_notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              // Action to mark all as read
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // MATCHING ALERTS
          NotificationSectionHeader(
            title: 'Matching Alerts',
            icon: Icons.stars,
            iconColor: context.colors.buttonBlue,
          ),
          AlertNotificationItem(
            icon: Icons.search,
            iconColor: context.colors.buttonBlue,
            iconBackgroundColor: Color(0xFFE8F2FF), // Very light blue
            title: 'New Potential Match Found',
            subtitle: 'A \'Black Leather Wallet\' was found near your last reported location in Downtown.',
            timeAgo: '2m ago',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: context.colors.dividerColor, height: 1),
          ),
          AlertNotificationItem(
            icon: Icons.pets,
            iconColor: context.colors.buttonBlue,
            iconBackgroundColor: Color(0xFFE8F2FF),
            title: 'Item Update',
            subtitle: 'Your reported \'Golden Retriever\' has 3 new potential matches from the community.',
            timeAgo: '1h ago',
          ),
          
          // CHAT ALERTS
          NotificationSectionHeader(
            title: 'Chat Alerts',
            icon: Icons.chat_bubble,
            iconColor: context.colors.textLight,
          ),
          ChatNotificationItem(
            avatarUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
            title: 'Message from David K.',
            subtitle: '"I think I found your keys at the park..."',
            timeAgo: '15m ago',
            isUnread: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: context.colors.dividerColor, height: 1),
          ),
          ChatNotificationItem(
            avatarUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
            title: 'Sarah Wilson',
            subtitle: 'Thank you so much for returning my...',
            timeAgo: '3h ago',
            isUnread: false,
          ),

          // SYSTEM ALERTS
          NotificationSectionHeader(
            title: 'System Alerts',
            icon: Icons.settings,
            iconColor: context.colors.textLight,
          ),
          AlertNotificationItem(
            icon: Icons.security,
            iconColor: context.colors.textLight,
            iconBackgroundColor: context.colors.background, // Light grey
            title: 'Security Alert',
            subtitle: 'Your account was logged in from a new device: iPhone 15 Pro.',
            timeAgo: 'Yesterday',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: context.colors.dividerColor, height: 1),
          ),
          AlertNotificationItem(
            icon: Icons.system_update_alt,
            iconColor: context.colors.textLight,
            iconBackgroundColor: context.colors.background,
            title: 'App Update Available',
            subtitle: 'Version 2.4.0 is now available with improved map accuracy and new filter options.',
            timeAgo: '2 days ago',
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}
