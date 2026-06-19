import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard/overview_card.dart';
import 'dashboard/user_growth_chart.dart';
import 'dashboard/item_activity_chart.dart';
import 'dashboard/recent_activity_feed.dart';

class DashboardTab extends StatefulWidget {
  final VoidCallback signOut;
  final Function(int) onNavigate;
  const DashboardTab({super.key, required this.signOut, required this.onNavigate});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _totalUsersCount = 0;
  int _activeItemsCount = 0;
  int _pendingReportsCount = 0;
  int _resolvedCasesCount = 0;
  List<double> _weeklyUserGrowth = [0, 0, 0, 0];
  List<double> _weeklyItemActivity = [0, 0, 0, 0];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = FirebaseFirestore.instance;
      
      final usersQuery = await db.collection('users').get();
      final totalUsers = usersQuery.size;

      final reportsQuery = await db.collection('reports').get();
      final activeItems = reportsQuery.docs.where((doc) {
        final status = doc.data()['status'];
        return status == 'LOST' || status == 'FOUND' || status == 'ACTIVE';
      }).length;

      final resolvedCases = reportsQuery.docs.where((doc) {
        final status = doc.data()['status'];
        return status == 'RESOLVED';
      }).length;

      final moderationQuery = await db.collection('moderation_queue')
          .where('status', isEqualTo: 'PENDING')
          .get();
      final pendingReports = moderationQuery.size;

      // Group weekly User growth & Item activity
      final now = DateTime.now();
      final w4Start = now.subtract(const Duration(days: 7));
      final w3Start = now.subtract(const Duration(days: 14));
      final w2Start = now.subtract(const Duration(days: 21));
      final w1Start = now.subtract(const Duration(days: 30));

      double w1Users = 0;
      double w2Users = 0;
      double w3Users = 0;
      double w4Users = 0;

      for (var doc in usersQuery.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt == null) continue;
        final date = createdAt.toDate();
        if (date.isAfter(w4Start)) {
          w4Users++;
        } else if (date.isAfter(w3Start)) {
          w3Users++;
        } else if (date.isAfter(w2Start)) {
          w2Users++;
        } else if (date.isAfter(w1Start)) {
          w1Users++;
        }
      }

      double w1Items = 0;
      double w2Items = 0;
      double w3Items = 0;
      double w4Items = 0;

      for (var doc in reportsQuery.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] ?? data['dateReported']) as Timestamp?;
        if (createdAt == null) continue;
        final date = createdAt.toDate();
        if (date.isAfter(w4Start)) {
          w4Items++;
        } else if (date.isAfter(w3Start)) {
          w3Items++;
        } else if (date.isAfter(w2Start)) {
          w2Items++;
        } else if (date.isAfter(w1Start)) {
          w1Items++;
        }
      }

      if (mounted) {
        setState(() {
          _totalUsersCount = totalUsers;
          _activeItemsCount = activeItems;
          _pendingReportsCount = pendingReports;
          _resolvedCasesCount = resolvedCases;
          _weeklyUserGrowth = [w1Users, w2Users, w3Users, w4Users];
          _weeklyItemActivity = [w1Items, w2Items, w3Items, w4Items];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.colors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back, here\'s what\'s happening today.',
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.25,
            children: [
              DashboardOverviewCard(
                title: 'TOTAL USERS',
                value: _totalUsersCount.toString(),
                subtitle: '${_weeklyUserGrowth[3].toInt()} new this week',
                icon: Icons.people_outline_rounded,
                accentColor: context.colors.primaryTeal,
              ),
              DashboardOverviewCard(
                title: 'ACTIVE ITEMS',
                value: _activeItemsCount.toString(),
                subtitle: '${_weeklyItemActivity[3].toInt()} new this week',
                icon: Icons.archive_outlined,
                accentColor: context.colors.tagLostRed,
              ),
              DashboardOverviewCard(
                title: 'PENDING REPORTS',
                value: _pendingReportsCount.toString(),
                subtitle: 'Requires attention',
                icon: Icons.warning_amber_rounded,
                accentColor: context.colors.tagFoundGreen,
              ),
              DashboardOverviewCard(
                title: 'RESOLVED CASES',
                value: _resolvedCasesCount.toString(),
                subtitle: 'All time success',
                icon: Icons.check_circle_outline_rounded,
                accentColor: context.colors.buttonBlue,
              ),
            ],
          ),
          const SizedBox(height: 24),
          UserGrowthChart(weeklyUserGrowth: _weeklyUserGrowth),
          const SizedBox(height: 24),
          ItemActivityChart(weeklyItemActivity: _weeklyItemActivity),
          const SizedBox(height: 24),
          const RecentActivityFeed(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
