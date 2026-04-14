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

  const ItemCard({
    super.key,
    required this.title,
    required this.timeAgo,
    required this.location,
    required this.userAvatarUrl,
    required this.userName,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFound = status == ItemStatus.found;
    final Color badgeColor = isFound ? AppColors.tagFoundGreen : AppColors.tagLostRed;
    final String badgeText = isFound ? 'FOUND' : 'LOST';
    final String actionText = isFound ? 'Claim Item' : 'I Found This';

    // To prevent actual external network calls failing without images, 
    // we use a colored container as a placeholder if imageUrl is empty.
    Widget imageWidget = imageUrl.isNotEmpty
        ? Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)
        : Container(height: 160, width: double.infinity, color: AppColors.iconBackground);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Badge
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                imageWidget,
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.iconBackground,
                          child: const Icon(Icons.person, size: 16, color: AppColors.primaryTeal),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFound ? AppColors.primaryTeal : Colors.white,
                        foregroundColor: isFound ? Colors.white : AppColors.primaryTeal,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: isFound 
                            ? BorderSide.none 
                            : const BorderSide(color: AppColors.primaryTeal),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(
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
