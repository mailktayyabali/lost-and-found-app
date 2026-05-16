import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import 'support_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _buildSectionHeader(context, 'PREFERENCES'),
          _buildThemeToggle(context),
          _buildSettingItem(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Manage push notifications and alerts',
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English (United States)',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'LEGAL & SUPPORT'),
          _buildSettingItem(
            context,
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQs and support contact',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage(title: 'Help Center'))),
          ),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage(title: 'Privacy Policy'))),
          ),
          _buildSettingItem(
            context,
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage(title: 'Terms of Service'))),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'ACCOUNT'),
          _buildSettingItem(
            context,
            icon: Icons.delete_outline_rounded,
            title: 'Delete Account',
            titleColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.textLight,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? context.colors.primaryTeal).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: titleColor ?? context.colors.primaryTeal, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? context.colors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: context.colors.textLight, fontSize: 13),
            )
          : null,
      trailing: Icon(Icons.chevron_right_rounded, color: context.colors.dividerColor),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.dark_mode_outlined, color: context.colors.primaryTeal, size: 22),
        ),
        title: Text(
          'Dark Mode',
          style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: Switch(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) => ThemeManager.toggleTheme(),
          activeColor: context.colors.primaryTeal,
        ),
      ),
    );
  }
}
