import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ItemStatus { found, lost }

class ItemCard extends StatelessWidget {
  final String title;
  final String timeAgo;
  final String location;
  final String userAvatarUrl;
  final String userName;
  final ItemStatus status;
  final String imageUrl;
  final VoidCallback? onActionPressed;

  const ItemCard({
    super.key,
    required this.title,
    required this.timeAgo,
    required this.location,
    required this.userAvatarUrl,
    required this.userName,
    required this.status,
    required this.imageUrl,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = status == ItemStatus.found;
    final Color badgeColor = isFound ? context.colors.tagFoundGreen : context.colors.tagLostRed;
    final String badgeText = isFound ? 'FOUND' : 'LOST';
    final String actionText = isFound ? 'Claim Item' : 'I Found This';

    // To prevent actual external network calls failing without images, 
    // we use a colored container as a placeholder if imageUrl is empty.
    Widget imageWidget = imageUrl.isNotEmpty
        ? Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)
        : Container(height: 160, width: double.infinity, color: context.colors.iconBackground);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Badge
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                imageWidget,
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: EdgeInsets.all(16.0),
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
                          fontWeight: FontWeight.bold,
                          color: context.colors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: context.colors.textLight),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: context.colors.iconBackground,
                          child: Icon(Icons.person, size: 16, color: context.colors.primaryTeal),
                        ),
                        SizedBox(width: 8),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textDark,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFound ? context.colors.primaryTeal : Colors.white,
                        foregroundColor: isFound ? Colors.white : context.colors.primaryTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: isFound 
                            ? BorderSide.none 
                            : BorderSide(color: context.colors.primaryTeal),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
