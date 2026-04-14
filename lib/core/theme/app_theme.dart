import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: 'Inter', // Assuming a sans-serif like Inter, typical for such designs
    );
  }
}
