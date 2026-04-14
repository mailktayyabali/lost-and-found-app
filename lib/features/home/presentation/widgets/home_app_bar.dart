import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textDark),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }
      ),
      title: const Text(
        'Lost & Found',
        style: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
