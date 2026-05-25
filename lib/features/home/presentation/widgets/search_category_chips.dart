import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchCategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onClear;

  const SearchCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onClear,
  });

  static const List<String> categories = [
    'All Items',
    'Electronics',
    'Pets',
    'Documents',
    'Keys',
    'Wallets',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORY',
                style: TextStyle(
                  color: context.colors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: context.colors.primaryTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return _buildChip(context, cat, isSelected: isSelected, onTap: () {
                onCategoryChanged(cat);
              });
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String label, {bool isSelected = false, VoidCallback? onTap}) {
    Color bgColor = context.colors.surfaceWhite;
    Color textColor = context.colors.textDark;
    Color borderColor = context.colors.fieldBorder;

    if (isSelected) {
      bgColor = context.colors.primaryTeal;
      textColor = Colors.white;
      borderColor = context.colors.primaryTeal;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
