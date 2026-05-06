import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primaryTeal;
  final Color tagFoundGreen;
  final Color tagLostRed;
  final Color buttonBlue;
  final Color textDark;
  final Color textLight;
  final Color textAccent;
  final Color background;
  final Color surfaceWhite;
  final Color iconBackground;
  final Color fieldBackground;
  final Color fieldBorder;
  final Color dividerColor;

  const AppColorsExtension({
    required this.primaryTeal,
    required this.tagFoundGreen,
    required this.tagLostRed,
    required this.buttonBlue,
    required this.textDark,
    required this.textLight,
    required this.textAccent,
    required this.background,
    required this.surfaceWhite,
    required this.iconBackground,
    required this.fieldBackground,
    required this.fieldBorder,
    required this.dividerColor,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? primaryTeal,
    Color? tagFoundGreen,
    Color? tagLostRed,
    Color? buttonBlue,
    Color? textDark,
    Color? textLight,
    Color? textAccent,
    Color? background,
    Color? surfaceWhite,
    Color? iconBackground,
    Color? fieldBackground,
    Color? fieldBorder,
    Color? dividerColor,
  }) {
    return AppColorsExtension(
      primaryTeal: primaryTeal ?? this.primaryTeal,
      tagFoundGreen: tagFoundGreen ?? this.tagFoundGreen,
      tagLostRed: tagLostRed ?? this.tagLostRed,
      buttonBlue: buttonBlue ?? this.buttonBlue,
      textDark: textDark ?? this.textDark,
      textLight: textLight ?? this.textLight,
      textAccent: textAccent ?? this.textAccent,
      background: background ?? this.background,
      surfaceWhite: surfaceWhite ?? this.surfaceWhite,
      iconBackground: iconBackground ?? this.iconBackground,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      dividerColor: dividerColor ?? this.dividerColor,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      primaryTeal: Color.lerp(primaryTeal, other.primaryTeal, t)!,
      tagFoundGreen: Color.lerp(tagFoundGreen, other.tagFoundGreen, t)!,
      tagLostRed: Color.lerp(tagLostRed, other.tagLostRed, t)!,
      buttonBlue: Color.lerp(buttonBlue, other.buttonBlue, t)!,
      textDark: Color.lerp(textDark, other.textDark, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      background: Color.lerp(background, other.background, t)!,
      surfaceWhite: Color.lerp(surfaceWhite, other.surfaceWhite, t)!,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t)!,
      fieldBackground: Color.lerp(fieldBackground, other.fieldBackground, t)!,
      fieldBorder: Color.lerp(fieldBorder, other.fieldBorder, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
    );
  }
}

extension AppColorsBuildContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}

class AppColors {
  // Brand colors
  static const Color primaryTeal = Color(0xFF07605D);
  static const Color tagFoundGreen = Color(0xFF34C759); // bright green
  static const Color tagLostRed = Color(0xFFFF3B30); // red
  static const Color buttonBlue = Color(0xFF2D68FE); // bright blue for badges/icons

  // Text colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color textAccent = Color(0xFF07605D); // same as teal

  // Backgrounds
  static const Color background = Color(0xFFF7F8FA);
  static const Color surfaceWhite = Colors.white;
  static const Color iconBackground = Color(0xFFE2F0EF); // light teal background for icons
  static const Color fieldBackground = Colors.white;
  
  // Borders
  static const Color fieldBorder = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFE2E8F0);

  static const lightColors = AppColorsExtension(
    primaryTeal: primaryTeal,
    tagFoundGreen: tagFoundGreen,
    tagLostRed: tagLostRed,
    buttonBlue: buttonBlue,
    textDark: textDark,
    textLight: textLight,
    textAccent: textAccent,
    background: background,
    surfaceWhite: surfaceWhite,
    iconBackground: iconBackground,
    fieldBackground: fieldBackground,
    fieldBorder: fieldBorder,
    dividerColor: dividerColor,
  );

  static const darkColors = AppColorsExtension(
    primaryTeal: Color(0xFF14B8A6), // Lighter teal for dark mode
    tagFoundGreen: Color(0xFF34C759),
    tagLostRed: Color(0xFFFF3B30),
    buttonBlue: Color(0xFF3B82F6),
    textDark: Color(0xFFF8FAFC), // Light text
    textLight: Color(0xFF94A3B8), // Muted text
    textAccent: Color(0xFF14B8A6),
    background: Color(0xFF0F172A), // Dark slate
    surfaceWhite: Color(0xFF1E293B), // Slightly lighter slate
    iconBackground: Color(0xFF1E293B),
    fieldBackground: Color(0xFF1E293B),
    fieldBorder: Color(0xFF334155),
    dividerColor: Color(0xFF334155),
  );
}
