import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTeal : AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryTeal : AppColors.fieldBorder,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: AppColors.primaryTeal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                else
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textDark,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
