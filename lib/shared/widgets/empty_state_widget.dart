import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: context.colors.textLight.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    ),
  );
}
}

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    // Simple animated placeholder as a shimmer substitute for now
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
