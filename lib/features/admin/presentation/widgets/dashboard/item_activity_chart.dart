import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';

class ItemActivityChart extends StatelessWidget {
  final List<double> weeklyItemActivity;

  const ItemActivityChart({
    super.key,
    required this.weeklyItemActivity,
  });

  @override
  Widget build(BuildContext context) {
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
                dataPoints: weeklyItemActivity,
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
