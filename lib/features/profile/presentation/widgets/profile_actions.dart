import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../edit_profile_screen.dart';
import '../../../messages/presentation/chat_screen.dart';

class ProfileActions extends StatelessWidget {
  final bool isOwnProfile;
  final String name;
  final String bio;
  final String? profileUid;
  final String profileUrl;
  final String? userId;
  final VoidCallback onProfileUpdated;

  const ProfileActions({
    super.key,
    required this.isOwnProfile,
    required this.name,
    required this.bio,
    required this.profileUid,
    required this.profileUrl,
    required this.userId,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (isOwnProfile) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        initialName: name,
                        initialBio: bio,
                      ),
                    ),
                  );
                  if (result == true) {
                    onProfileUpdated();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final uid = profileUid ?? '';
                  Clipboard.setData(
                    ClipboardData(text: 'lostandfound://profile/$uid'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile link copied to clipboard!'),
                      backgroundColor: context.colors.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: context.colors.textDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Share Profile',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        userName: name,
                        partnerUid: userId!,
                        avatarUrl: profileUrl,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text(
                  'Contact Member',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
