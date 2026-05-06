import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.lightColors,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkColors.primaryTeal,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.darkColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.darkColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      useMaterial3: true,
      fontFamily: 'Inter',
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.darkColors,
      ],
    );
  }
}
