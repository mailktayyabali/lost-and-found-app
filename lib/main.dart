import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  runApp(const LostAndFoundApp());
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost and Found',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
