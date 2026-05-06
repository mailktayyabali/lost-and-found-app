import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ChatNotificationItem extends StatelessWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isUnread;

  const ChatNotificationItem({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Ensure the blue indicator is aligned properly on the left edge if unread
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (isUnread)
            Positioned(
              left: 0,
              top: 8,
              bottom: 8,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: context.colors.buttonBlue, // Bright blue for unread indicator
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: context.colors.iconBackground,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: context.colors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isUnread ? context.colors.buttonBlue : context.colors.textLight,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnread ? context.colors.textDark : context.colors.textLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
