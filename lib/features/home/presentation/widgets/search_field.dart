import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for items, pets, etc.',
          hintStyle: TextStyle(
            color: context.colors.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.colors.textLight,
            size: 20,
          ),
          filled: true,
          fillColor: context.colors.surfaceWhite,
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.fieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.primaryTeal),
          ),
        ),
      ),
    );
  }
}
