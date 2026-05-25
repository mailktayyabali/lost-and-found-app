import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback signOut;
  final Function(int) onNavigate;
  const DashboardTab({super.key, required this.signOut, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListView(
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
        _buildOverviewCard(
          context: context,
          title: 'TOTAL USERS',
          value: '12',
          subtitle: '1 new this month',
          icon: Icons.people_outline_rounded,
          accentColor: context.colors.primaryTeal,
        ),
        _buildOverviewCard(
          context: context,
          title: 'ACTIVE ITEMS',
          value: '2',
          subtitle: '0 new this month',
          icon: Icons.archive_outlined,
          accentColor: context.colors.tagLostRed,
        ),
        _buildOverviewCard(
          context: context,
          title: 'PENDING REPORTS',
          value: '0',
          subtitle: 'Requires attention',
          icon: Icons.warning_amber_rounded,
          accentColor: Colors.orange,
        ),
        _buildOverviewCard(
          context: context,
          title: 'RESOLVED CASES',
          value: '0',
          subtitle: 'All time success',
          icon: Icons.check_circle_outline_rounded,
          accentColor: context.colors.buttonBlue,
        ),
        const SizedBox(height: 24),
        _buildBarChart(context),
        const SizedBox(height: 24),
        _buildLineChart(context),
        const SizedBox(height: 24),
        _buildRecentActivitySection(context),
        const SizedBox(height: 40),
      ],
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
      margin: const EdgeInsets.only(bottom: 16),
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
              left: BorderSide(color: accentColor, width: 5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: context.colors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
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
                _buildBar(context, 'WEEK 1', 60, barColor),
                _buildBar(context, 'WEEK 2', 90, barColor),
                _buildBar(context, 'WEEK 3', 75, barColor),
                _buildBar(context, 'WEEK 4', 140, activeBarColor),
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
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: context.colors.textLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'EDITS',
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
              painter: _LineChartPainter(lineColor: teal, gradientColor: teal),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['01 NOV', '10 NOV', '20 NOV', '30 NOV'].map((date) {
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
  _LineChartPainter({required this.lineColor, required this.gradientColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.3, size.height * 0.8,
      size.width * 0.5, size.height * 0.85,
      size.width * 0.6, size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.9, size.height * 0.2,
      size.width, size.height * 0.25,
    );

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

    final pointX = size.width * 0.6;
    final pointY = size.height * 0.6;
    canvas.drawCircle(Offset(pointX, pointY), 8, activePointPaint);
    canvas.drawCircle(Offset(pointX, pointY), 4, activePointBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
