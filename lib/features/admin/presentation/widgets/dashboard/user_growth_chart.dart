import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class UserGrowthChart extends StatelessWidget {
  final List<double> weeklyUserGrowth;

  const UserGrowthChart({
    super.key,
    required this.weeklyUserGrowth,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = const Color(0xFF80DEEA);
    final activeBarColor = context.colors.primaryTeal;

    final w1Count = weeklyUserGrowth.isNotEmpty ? weeklyUserGrowth[0] : 0.0;
    final w2Count = weeklyUserGrowth.length > 1 ? weeklyUserGrowth[1] : 0.0;
    final w3Count = weeklyUserGrowth.length > 2 ? weeklyUserGrowth[2] : 0.0;
    final w4Count = weeklyUserGrowth.length > 3 ? weeklyUserGrowth[3] : 0.0;

    final maxCount = [w1Count, w2Count, w3Count, w4Count].reduce((a, b) => a > b ? a : b);
    final double scale = maxCount > 0 ? 110.0 / maxCount : 1.0;

    final h1 = w1Count > 0 ? (w1Count * scale) + 15.0 : 15.0;
    final h2 = w2Count > 0 ? (w2Count * scale) + 15.0 : 15.0;
    final h3 = w3Count > 0 ? (w3Count * scale) + 15.0 : 15.0;
    final h4 = w4Count > 0 ? (w4Count * scale) + 15.0 : 15.0;

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
                'User Growth (Last 30 Days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                ),
              ),
              Icon(Icons.more_horiz_rounded, color: context.colors.textLight),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(context, 'WEEK 1 (${w1Count.toInt()})', h1, barColor),
                _buildBar(context, 'WEEK 2 (${w2Count.toInt()})', h2, barColor),
                _buildBar(context, 'WEEK 3 (${w3Count.toInt()})', h3, barColor),
                _buildBar(context, 'WEEK 4 (${w4Count.toInt()})', h4, activeBarColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: context.colors.textLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
