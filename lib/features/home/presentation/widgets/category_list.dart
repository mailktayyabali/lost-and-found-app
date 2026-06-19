import 'package:flutter/material.dart';
import 'category_item.dart';

class CategoryList extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  CategoryList({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.grid_view, 'label': 'All'},
    {'icon': Icons.devices_other, 'label': 'Electronics'},
    {'icon': Icons.pets, 'label': 'Pets'},
    {'icon': Icons.key, 'label': 'Keys'},
    {'icon': Icons.account_balance_wallet, 'label': 'Wallets'},
    {'icon': Icons.description, 'label': 'Documents'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final label = category['label'] as String;
          return CategoryItem(
            icon: category['icon'] as IconData,
            label: label,
            isSelected: selectedCategory == label,
            onTap: () => onCategoryChanged(label),
          );
        },
      ),
    );
  }
}
