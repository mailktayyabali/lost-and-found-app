import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ItemImageGallery extends StatelessWidget {
  final String imageUrl;

  const ItemImageGallery({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: context.colors.background,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.contain,
            height: 200,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.image_not_supported_rounded,
              color: context.colors.textLight,
              size: 48,
            ),
          ),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.colors.textDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(context, true),
                  _buildDot(context, false),
                  _buildDot(context, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
