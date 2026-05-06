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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.fieldBorder),
      ),
      child: Column(
        children: [
          // Top section with Image and Details
          Padding(
            padding: EdgeInsets.all(16.0),
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
                              child: _buildImage(context),
                            ),
                          )
                        : _buildImage(context),
                    ),
                    if (isRecovered)
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                  ],
                ),
                SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textLight,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        title,
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
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: context.colors.textLight),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
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
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F3FE), // Very light blue
                            borderRadius: BorderRadius.circular(12),
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
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.delete_outline,
                    label: 'Remove Post',
                    color: context.colors.tagLostRed,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.edit,
                    label: 'Edit',
                    color: context.colors.textDark,
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: context.colors.tagLostRed,
                  ),
                ),
                Container(width: 1, height: 24, color: context.colors.dividerColor),
                Expanded(
                  child: _buildActionButton(context, 
                    icon: Icons.check_circle,
                    label: 'Recovered',
                    color: context.colors.buttonBlue,
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: imageUrl.isNotEmpty
          ? Image.network(imageUrl, fit: BoxFit.cover)
          : Icon(Icons.image, color: context.colors.textLight),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 4),
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
