import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for items, pets, etc.',
          hintStyle: const TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textLight,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.surfaceWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryTeal),
          ),
        ),
      ),
    );
  }
}
