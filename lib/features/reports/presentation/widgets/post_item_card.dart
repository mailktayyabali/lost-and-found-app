import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/item_model.dart';

class PostItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRecovered;

  const PostItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
    this.onRecovered,
  });

  @override
  Widget build(BuildContext context) {
    final isRecovered = item.status == 'RESOLVED';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge, vertical: AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: AppDimensions.borderLarge,
        border: Border.all(color: context.colors.fieldBorder),
      ),
      child: Column(
        children: [
          // Top section with Image and Details
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusLarge),
              topRight: Radius.circular(AppDimensions.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: AppDimensions.borderMedium,
                        child: isRecovered
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                              child: Opacity(
                                opacity: 0.5,
                                child: _buildImage(context),
                              ),
                            )
                          : _buildImage(context),
                      ),
                      if (isRecovered)
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reported ${item.timeAgo}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isRecovered ? context.colors.textLight : context.colors.textDark,
                            decoration: isRecovered ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isRecovered) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: context.colors.textLight),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.displayLocation,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.colors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F3FE), // Very light blue
                              borderRadius: AppDimensions.borderMedium,
                            ),
                            child: Text(
                              'RECOVERED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: context.colors.buttonBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Divider(height: 1, color: context.colors.dividerColor),
          
          // Action Row
          if (isRecovered)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.remove_red_eye,
                    label: 'View Details',
                    color: context.colors.textLight,
                    onPressed: onTap,
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.delete_outline,
                    label: 'Remove Post',
                    color: context.colors.tagLostRed,
                    onPressed: onDelete,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.remove_red_eye,
                    label: 'View Details',
                    color: context.colors.textDark,
                    onPressed: onTap,
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: context.colors.tagLostRed,
                    onPressed: onDelete,
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.check_circle,
                    label: 'Recovered',
                    color: context.colors.buttonBlue,
                    onPressed: onRecovered,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: context.colors.iconBackground,
        borderRadius: AppDimensions.borderMedium,
      ),
      child: item.imageUrl.isNotEmpty
          ? (item.imageUrl.startsWith('http')
              ? Image.network(item.imageUrl, fit: BoxFit.cover)
              : Image.file(File(item.imageUrl), fit: BoxFit.cover))
          : Icon(Icons.image, color: context.colors.textLight),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
