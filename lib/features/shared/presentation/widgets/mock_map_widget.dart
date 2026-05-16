import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MockMapWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isPicker;
  final String locationName;
  final double height;

  const MockMapWidget({
    super.key,
    this.onTap,
    this.isPicker = false,
    this.locationName = 'Central Park, NYC',
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E3DF), // Classic map background color
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.dividerColor),
          image: const DecorationImage(
            image: NetworkImage(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=800'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Mock map route/streets overlay
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CustomPaint(
                  painter: _MockMapLinesPainter(),
                ),
              ),
            ),
            // Map Pin
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    isPicker ? 'Tap to set location' : locationName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colors.textDark,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 40,
                ),
              ],
            ),
            if (isPicker)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MockMapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.4, size.width, size.height * 0.2)
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.4, size.height)
      ..moveTo(size.width * 0.6, 0)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.5, size.width, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
