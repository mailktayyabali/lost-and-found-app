import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class ItemImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ItemImageGallery({
    super.key,
    required this.imageUrls,
  });

  @override
  State<ItemImageGallery> createState() => _ItemImageGalleryState();
}

class _ItemImageGalleryState extends State<ItemImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isEmpty ? [''] : widget.imageUrls;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: context.colors.background,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            itemCount: urls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = urls[index];
              return Center(
                child: url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.contain,
                        height: 250,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const ShimmerLoader(
                            width: double.infinity,
                            height: 250,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_rounded,
                          color: context.colors.textLight,
                          size: 48,
                        ),
                      )
                    : Icon(
                        Icons.image_not_supported_rounded,
                        color: context.colors.textLight,
                        size: 48,
                      ),
              );
            },
          ),
          if (urls.length > 1)
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
                  children: List.generate(
                    urls.length,
                    (index) => _buildDot(context, index == _currentIndex),
                  ),
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
