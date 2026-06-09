import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  String _activeCategory = 'All';
  Stream<QuerySnapshot<Map<String, dynamic>>>? _usersStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _reportsStream;

  @override
  Widget build(BuildContext context) {
    _usersStream ??= FirebaseFirestore.instance.collection('users').snapshots();
    _reportsStream ??= FirebaseFirestore.instance.collection('reports').snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (context, usersSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _reportsStream,
          builder: (context, reportsSnapshot) {
            if ((usersSnapshot.connectionState == ConnectionState.waiting && !usersSnapshot.hasData) ||
                (reportsSnapshot.connectionState == ConnectionState.waiting && !reportsSnapshot.hasData)) {
              return const Center(child: CircularProgressIndicator());
            }

            final userDocs = usersSnapshot.data?.docs ?? [];
            final reportDocs = reportsSnapshot.data?.docs ?? [];

            final activeUsersCount = userDocs.where((doc) => doc.data()['isBanned'] != true).length;
            final totalItemsCount = reportDocs.length;

            final userLogs = userDocs.map((doc) {
              final data = doc.data();
              final name = data['name'] ?? 'No Name';
              final timestamp = data['createdAt'] as Timestamp?;
              return {
                'type': 'User',
                'title': 'New user $name joined',
                'timestamp': timestamp,
                'dateTime': timestamp?.toDate() ?? DateTime(2000),
                'icon': Icons.person_add_rounded,
                'iconColor': context.colors.primaryTeal,
              };
            }).toList();

            final reportLogs = reportDocs.map((doc) {
              final data = doc.data();
              final title = data['title'] ?? data['itemName'] ?? 'Untitled Item';
              final isLost = data['isLost'] ?? true;
              final timestamp = (data['createdAt'] ?? data['dateReported']) as Timestamp?;
              return {
                'type': 'Item',
                'title': 'New ${isLost ? 'lost' : 'found'} item reported: "$title"',
                'timestamp': timestamp,
                'dateTime': timestamp?.toDate() ?? DateTime(2000),
                'icon': isLost ? Icons.search_rounded : Icons.check_circle_outline_rounded,
                'iconColor': isLost ? context.colors.tagLostRed : context.colors.tagFoundGreen,
              };
            }).toList();

            final allLogs = [...userLogs, ...reportLogs];
            allLogs.sort((a, b) => (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime));

            final filteredLogs = allLogs.where((log) {
              if (_activeCategory == 'All') return true;
              if (_activeCategory == 'Users') return log['type'] == 'User';
              if (_activeCategory == 'Items') return log['type'] == 'Item';
              return true;
            }).toList();

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
                        activeUsersCount.toString(),
                        '+ 12%',
                        true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTrendCard(
                        context,
                        'TOTAL ITEMS',
                        totalItemsCount.toString(),
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

                if (filteredLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.notes_rounded, size: 48, color: context.colors.textLight.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No activities recorded yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredLogs.length > 15 ? 15 : filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final timestampStr = log['timestamp'] != null
                          ? DateFormat('M/d/yyyy, h:mm:ss a').format((log['timestamp'] as Timestamp).toDate())
                          : 'N/A';
                      return _buildLogItem(
                        context,
                        log['title'] as String,
                        timestampStr,
                        log['icon'] as IconData,
                        log['iconColor'] as Color,
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            );
          },
        );
      },
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
        color: context.colors.surfaceWhite,
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
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _activeCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? context.colors.primaryTeal : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.colors.primaryTeal : context.colors.textLight,
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
        color: context.colors.surfaceWhite,
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
