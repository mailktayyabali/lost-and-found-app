import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String bio;
  final String profileUrl;
  final bool isOwnProfile;
  final int totalReportsCount;
  final int postsCount;
  final int claimsCount;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.bio,
    required this.profileUrl,
    required this.isOwnProfile,
    required this.totalReportsCount,
    required this.postsCount,
    required this.claimsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Profile Image
        Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primaryTeal.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(profileUrl),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colors.primaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.surfaceWhite, width: 2),
                  ),
                  child: const Icon(Icons.verified, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Name
        Text(
          name,
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Email
        if (isOwnProfile)
          Text(
            email,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        const SizedBox(height: 24),
        // Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingExtraLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(context, totalReportsCount.toString(), 'TOTAL REPORTS'),
              _buildStatColumn(context, postsCount.toString(), 'POSTS'),
              _buildStatColumn(context, claimsCount.toString(), 'TOTAL CLAIMS'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Bio
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.colors.textLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
