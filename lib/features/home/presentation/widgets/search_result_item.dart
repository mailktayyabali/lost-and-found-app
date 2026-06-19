import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/widgets/heartbeat_bookmark_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../item_details_screen.dart';

class SearchResultItem extends StatelessWidget {
  final Item item;
  final VoidCallback? onBookmarkToggled;

  const SearchResultItem({
    super.key,
    required this.item,
    this.onBookmarkToggled,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = item.isLost 
        ? context.colors.tagLostRed.withValues(alpha: 0.15) 
        : context.colors.tagFoundGreen.withValues(alpha: 0.15);
    final badgeTextColor = item.isLost ? context.colors.tagLostRed : context.colors.tagFoundGreen;
    final badgeText = item.isLost ? 'LOST' : 'FOUND';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const ShimmerLoader(
                          width: 80,
                          height: 80,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: context.colors.iconBackground,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: context.colors.textLight.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: context.colors.iconBackground,
                      child: Icon(
                        Icons.image,
                        color: context.colors.textLight.withValues(alpha: 0.5),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        item.timeAgo,
                        style: TextStyle(
                          color: context.colors.textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: context.colors.textLight, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.displayLocation,
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            HeartbeatBookmarkButton(
              item: item,
              onToggled: onBookmarkToggled,
              isCircleBg: true,
            ),
          ],
        ),
      ),
    );
  }
}
