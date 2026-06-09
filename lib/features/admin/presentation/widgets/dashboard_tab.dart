import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

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
              _buildOverviewCard(
                context: context,
                title: 'TOTAL USERS',
                value: _totalUsersCount.toString(),
                subtitle: '${_weeklyUserGrowth[3].toInt()} new this week',
                icon: Icons.people_outline_rounded,
                accentColor: context.colors.primaryTeal,
              ),
              _buildOverviewCard(
                context: context,
                title: 'ACTIVE ITEMS',
                value: _activeItemsCount.toString(),
                subtitle: '${_weeklyItemActivity[3].toInt()} new this week',
                icon: Icons.archive_outlined,
                accentColor: context.colors.tagLostRed,
              ),
              _buildOverviewCard(
                context: context,
                title: 'PENDING REPORTS',
                value: _pendingReportsCount.toString(),
                subtitle: 'Requires attention',
                icon: Icons.warning_amber_rounded,
                accentColor: context.colors.tagFoundGreen,
              ),
              _buildOverviewCard(
                context: context,
                title: 'RESOLVED CASES',
                value: _resolvedCasesCount.toString(),
                subtitle: 'All time success',
                icon: Icons.check_circle_outline_rounded,
                accentColor: context.colors.buttonBlue,
              ),
            ],
          ),
        const SizedBox(height: 24),
        _buildBarChart(context),
        const SizedBox(height: 24),
        _buildLineChart(context),
        const SizedBox(height: 24),
        _buildRecentActivitySection(context),
        const SizedBox(height: 40),
      ],
    ),
  );
}

  Widget _buildOverviewCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textLight,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: context.colors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: context.colors.textLight,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final barColor = const Color(0xFF80DEEA);
    final activeBarColor = context.colors.primaryTeal;

    final w1Count = _weeklyUserGrowth[0];
    final w2Count = _weeklyUserGrowth[1];
    final w3Count = _weeklyUserGrowth[2];
    final w4Count = _weeklyUserGrowth[3];

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

  Widget _buildLineChart(BuildContext context) {
    final teal = context.colors.primaryTeal;
    final now = DateTime.now();
    final label1 = DateFormat('dd MMM').format(now.subtract(const Duration(days: 30))).toUpperCase();
    final label2 = DateFormat('dd MMM').format(now.subtract(const Duration(days: 20))).toUpperCase();
    final label3 = DateFormat('dd MMM').format(now.subtract(const Duration(days: 10))).toUpperCase();
    final label4 = DateFormat('dd MMM').format(now).toUpperCase();

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
                'Item Activity (Last 30 Days)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'UPLOADS',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.colors.textLight),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(
                lineColor: teal,
                gradientColor: teal,
                dataPoints: _weeklyItemActivity,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [label1, label2, label3, label4].map((date) {
              return Text(
                date,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textLight,
                  letterSpacing: 0.5,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
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

class _LineChartPainter extends CustomPainter {
  final Color lineColor;
  final Color gradientColor;
  final List<double> dataPoints;

  _LineChartPainter({
    required this.lineColor,
    required this.gradientColor,
    required this.dataPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final scale = maxVal > 0 ? (size.height * 0.75) / maxVal : 1.0;

    final path = Path();
    final stepX = size.width / (dataPoints.length - 1);

    double getY(int index) {
      final val = dataPoints[index];
      final height = size.height - (val * scale) - (size.height * 0.12);
      return height.clamp(size.height * 0.1, size.height * 0.9);
    }

    path.moveTo(0, getY(0));

    for (int i = 0; i < dataPoints.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = getY(i);
      final x2 = (i + 1) * stepX;
      final y2 = getY(i + 1);

      final controlX1 = x1 + stepX / 2;
      final controlY1 = y1;
      final controlX2 = x2 - stepX / 2;
      final controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withValues(alpha: 0.15),
          gradientColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final activePointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final activePointBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointX = size.width;
    final pointY = getY(dataPoints.length - 1);
    canvas.drawCircle(Offset(pointX, pointY), 8, activePointPaint);
    canvas.drawCircle(Offset(pointX, pointY), 4, activePointBorder);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
