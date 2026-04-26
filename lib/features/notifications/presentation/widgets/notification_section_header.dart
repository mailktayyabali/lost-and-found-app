import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;

  const NotificationSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.textLight,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
