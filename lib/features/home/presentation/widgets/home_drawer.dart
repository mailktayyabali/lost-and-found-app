import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reports/presentation/my_posts_screen.dart';
import '../saved_items_screen.dart';
import '../../../alerts/presentation/create_alert_screen.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../admin/presentation/screens/item_management.dart';
import '../../../profile/presentation/settings_screen.dart';

import '../../../../core/theme/theme_manager.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.colors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FutureBuilder<Map<String, dynamic>?>(
              future: AuthService().getUserData(AuthService().currentUser?.uid ?? ''),
              builder: (context, snapshot) {
                final user = AuthService().currentUser;
                final userData = snapshot.data;
                final name = userData?['name'] ?? user?.displayName ?? 'User';
                final photoUrl = user?.photoURL ?? 'https://randomuser.me/api/portraits/men/32.jpg';

                return Padding(
                  padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(photoUrl),
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
                                border: Border.all(color: context.colors.background, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'VERIFIED FINDER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: context.colors.primaryTeal.withValues(alpha: 0.85),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: context.colors.dividerColor, height: 1),
            ),
            SizedBox(height: 24),
            // Menu Items
            _buildMenuItem(
              context: context,
              icon: Icons.assignment_outlined,
              label: 'My Reports',
              isSelected: true,
            ),
            _buildMenuItem(context: context, icon: Icons.bookmark_border, label: 'Saved Items'),
            _buildMenuItem(
              context: context,
              icon: Icons.notifications_none_outlined,
              label: 'Create Alert',
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              label: 'Settings',
            ),
            _buildDarkModeToggle(context: context),
            FutureBuilder<bool>(
              future: AuthService().isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return _buildMenuItem(
                    context: context,
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin Panel',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Spacer(),
            // Sign Out Button
            Padding(
              padding: EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await AuthService().signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  },
                  icon: Icon(Icons.logout, color: context.colors.textDark, size: 20),
                  label: Text(
                    'Secure Sign Out',
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.dividerColor, // faint grey
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
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
    required BuildContext context,
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? context.colors.surfaceWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: context.colors.fieldBorder.withValues(alpha: 0.6)) 
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.textDark.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? context.colors.primaryTeal : context.colors.textLight.withValues(alpha: 0.8),
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? context.colors.primaryTeal : context.colors.textLight.withValues(alpha: 0.8),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          onTap: () {
            if (label == 'My Reports') {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MyPostsScreen()),
              );
            } else if (label == 'Saved Items') {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SavedItemsScreen()),
              );
            } else if (label == 'Create Alert') {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateAlertScreen()),
              );
            } else if (label == 'Admin Panel') {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            } else if (label == 'Settings') {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle({
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            Icons.dark_mode_outlined,
            color: context.colors.textLight.withValues(alpha: 0.8),
          ),
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: context.colors.textLight.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          trailing: Switch(
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              ThemeManager.toggleTheme();
            },
            activeThumbColor: context.colors.primaryTeal,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
