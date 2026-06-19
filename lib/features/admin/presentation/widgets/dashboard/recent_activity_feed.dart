import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class RecentActivityFeed extends StatelessWidget {
  const RecentActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            context,
            'New user registered:\n"TheCurator_99"',
            'Today at 10:45 AM',
            Icons.person_add_alt_1_rounded,
            const Color(0xFFE2F0EF),
            context.colors.primaryTeal,
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            'Updated item:\n"High-Resolution Satellite Data"',
            'Yesterday at 4:12 PM',
            Icons.edit_note_rounded,
            const Color(0xFFFFEBEE),
            context.colors.tagLostRed,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color bgIconColor,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgIconColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
