import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../auth/domain/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import 'support_screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
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
            onTap: () => _confirmDeleteAccount(context),
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
          activeThumbColor: context.colors.primaryTeal,
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Delete Account?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'This action is permanent and cannot be undone. All your posts, reviews, messages, and claims will be permanently deleted.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.colors.textDark),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _reauthenticateAndDelete(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reauthenticateAndDelete(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar(context, 'No active user session found.');
      return;
    }

    final providers = user.providerData.map((info) => info.providerId).toList();
    final isGoogleUser = providers.contains('google.com');

    if (isGoogleUser) {
      _showLoadingDialog(context, 'Re-authenticating with Google...');
      try {
        await AuthService().reauthenticateWithGoogle();
        if (!context.mounted) return;
        Navigator.pop(context); // Close loading dialog
        
        await _performAccountDeletion(context);
      } catch (e) {
        if (!context.mounted) return;
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar(context, 'Google re-authentication failed: $e');
      }
    } else {
      _promptForPasswordAndDelete(context);
    }
  }

  void _promptForPasswordAndDelete(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Confirm Password',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter your password to confirm account deletion.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primaryTeal),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.colors.textDark),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password is required'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(dialogContext); // Close prompt dialog
                
                _showLoadingDialog(context, 'Re-authenticating...');
                try {
                  await AuthService().reauthenticateWithEmail(password);
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close loading dialog
                  
                  await _performAccountDeletion(context);
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close loading dialog
                  _showErrorSnackBar(context, 'Re-authentication failed: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAccountDeletion(BuildContext context) async {
    _showLoadingDialog(context, 'Deleting your account and data...');
    try {
      await AuthService().deleteUserAccountAndData();
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account successfully deleted.'), backgroundColor: Colors.green),
      );
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      _showErrorSnackBar(context, 'Failed to delete account: $e');
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                CircularProgressIndicator(color: context.colors.primaryTeal),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
