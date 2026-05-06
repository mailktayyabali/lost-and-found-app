import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/home_bottom_nav_bar.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String userName;
  final String userAvatarUrl;

  const LeaveReviewScreen({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
  });

  @override
  State<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  int _selectedStars = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryTeal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Leave a Review',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: context.colors.primaryTeal),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.textDark.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        color: context.colors.primaryTeal, // Left edge accent
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                padding: EdgeInsets.all(4), // Inner outline spacing
                                decoration: BoxDecoration(
                                  border: Border.all(color: context.colors.dividerColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    widget.userAvatarUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Reviewing',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.colors.textLight,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      widget.userName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.textDark,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: context.colors.primaryTeal, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          '4.9 (124 reviews)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.colors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Rating Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.textDark.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'How was your experience?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap a star to rate your interaction with ${widget.userName.split(' ')[0]}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textLight,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStars = index + 1;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color: index < _selectedStars ? context.colors.primaryTeal : const Color(0xFFCBD5E1),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _getRatingText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Comments Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.textDark.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADD DETAILED COMMENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 120,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.colors.dividerColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Describe your experience: Was the handover smooth? Was communication clear?',
                        hintStyle: TextStyle(color: context.colors.textLight, fontSize: 15, height: 1.4),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Review submitted successfully!'),
                      backgroundColor: context.colors.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) Navigator.pop(context);
                  });
                },
                icon: Text(
                  'Submit Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                label: Icon(Icons.send, color: Colors.white, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Disclaimer
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Your review will be shared publicly on ${widget.userName.split(' ')[0]}'s profile to help other community members.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textLight,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 0),
    );
  }

  String _getRatingText() {
    switch (_selectedStars) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Poor';
      case 3:
        return 'Okay';
      case 4:
        return 'Great';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
