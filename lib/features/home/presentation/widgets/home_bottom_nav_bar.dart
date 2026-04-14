import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: AppColors.textLight.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          items: [
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_filled),
              ),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.search),
              ),
              label: 'SEARCH',
            ),
            BottomNavigationBarItem(
              icon: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              label: 'REPORT',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.chat_bubble_outline),
              ),
              label: 'MESSAGES',
            ),
            const BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person),
              ),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
