import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  String _activeCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, color: context.colors.primaryTeal, size: 28),
            const SizedBox(width: 8),
            Text(
              'System Analytics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor system activity and performance',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: _buildTrendCard(
                context,
                'ACTIVE USERS',
                '1,284',
                '+ 12%',
                true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrendCard(
                context,
                'TOTAL ITEMS',
                '45.2k',
                '+ 5%',
                true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        _buildCategoryFilters(),
        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
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

        _buildLogItem(
          context,
          'New user Admin joined',
          '5/24/2026, 11:37:15 AM',
          Icons.person_add_rounded,
          context.colors.primaryTeal,
        ),
        _buildLogItem(
          context,
          'Collection Meridian Alpha updated',
          '5/24/2026, 10:15:02 AM',
          Icons.inventory_2_rounded,
          Colors.orange,
        ),
        _buildLogItem(
          context,
          'Security audit Success',
          '5/24/2026, 09:45:30 AM',
          Icons.verified_user_rounded,
          context.colors.tagFoundGreen,
        ),
        _buildLogItem(
          context,
          'Backup completed for Items DB',
          '5/24/2026, 08:30:11 AM',
          Icons.cloud_done_rounded,
          Colors.blue,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    String title,
    String value,
    String trend,
    bool isPositive,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: context.colors.primaryTeal, width: 5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: isPositive ? context.colors.tagFoundGreen : context.colors.tagLostRed,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? context.colors.tagFoundGreen : context.colors.tagLostRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Users', 'Items'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _activeCategory == cat;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = cat),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : context.colors.textLight,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogItem(
    BuildContext context,
    String title,
    String timestamp,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
