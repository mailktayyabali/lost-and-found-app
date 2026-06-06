import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class ReporterProfileCard extends StatelessWidget {
  final String reporterName;

  const ReporterProfileCard({
    super.key,
    required this.reporterName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: AppDimensions.borderMedium,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporterName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.colors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since 2021 • 12 items found',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            color: Color(0xFFF59E0B),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '4.9',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: context.colors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
