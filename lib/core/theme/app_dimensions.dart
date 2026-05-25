import 'package:flutter/material.dart';

class AppDimensions {
  // Border Radii
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusCircular = 100.0;

  static BorderRadius get borderSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderExtraLarge => BorderRadius.circular(radiusExtraLarge);
  static BorderRadius get borderCircular => BorderRadius.circular(radiusCircular);

  // Paddings & Margins
  static const double paddingSmall = 8.0;
  static const double paddingDefault = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingExtraLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
}
