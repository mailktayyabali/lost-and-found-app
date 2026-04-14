import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/32.jpg',
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1ABC9C), // Green status dot
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.background, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alex Morgan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'VERIFIED FINDER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryTeal.withOpacity(0.85),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: AppColors.dividerColor, height: 1),
            ),
            const SizedBox(height: 24),
            // Menu Items
            _buildMenuItem(
              icon: Icons.assignment_outlined,
              label: 'My Reports',
              isSelected: true,
            ),
            _buildMenuItem(icon: Icons.bookmark_border, label: 'Saved Items'),
            _buildMenuItem(icon: Icons.category_outlined, label: 'Categories'),
            _buildMenuItem(icon: Icons.settings_outlined, label: 'Settings'),
            _buildMenuItem(icon: Icons.help_outline, label: 'Help'),
            const Spacer(),
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: AppColors.textDark, size: 20),
                  label: const Text(
                    'Secure Sign Out',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0), // faint grey
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppColors.fieldBorder.withOpacity(0.6)) 
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? AppColors.primaryTeal : AppColors.textLight.withOpacity(0.8),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryTeal : AppColors.textLight.withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          onTap: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
