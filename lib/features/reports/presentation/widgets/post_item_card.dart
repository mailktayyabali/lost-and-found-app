import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PostItemCard extends StatelessWidget {
  final String title;
  final String dateStr;
  final String location;
  final String imageUrl;
  final bool isRecovered;

  const PostItemCard({
    super.key,
    required this.title,
    required this.dateStr,
    required this.location,
    required this.imageUrl,
    this.isRecovered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Column(
        children: [
          // Top section with Image and Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
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
                              child: _buildImage(),
                            ),
                          )
                        : _buildImage(),
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
                        dateStr,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isRecovered ? AppColors.textLight : AppColors.textDark,
                          decoration: isRecovered ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isRecovered) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'RECOVERED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.buttonBlue,
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
          
          const Divider(height: 1, color: AppColors.dividerColor),
          
          // Action Row
          if (isRecovered)
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.remove_red_eye,
                    label: 'View Details',
                    color: AppColors.textLight,
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.dividerColor),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Remove Post',
                    color: AppColors.tagLostRed,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit',
                    color: AppColors.textDark,
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.dividerColor),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: AppColors.tagLostRed,
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.dividerColor),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.check_circle,
                    label: 'Recovered',
                    color: AppColors.buttonBlue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.iconBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl, fit: BoxFit.cover)
          : const Icon(Icons.image, color: AppColors.textLight),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
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
