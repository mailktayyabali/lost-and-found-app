import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Report Lost Items',
      description: 'Found something? Or lost something valuable? Report it in seconds and help the community.',
      image: Icons.search_rounded,
      color: const Color(0xFF1ABC9C),
    ),
    OnboardingData(
      title: 'Real-time Alerts',
      description: 'Get notified immediately when someone finds an item that matches your description.',
      image: Icons.notifications_active_outlined,
      color: const Color(0xFFF59E0B),
    ),
    OnboardingData(
      title: 'Safe Reconnection',
      description: 'Communicate securely with other members to arrange a safe return of your belongings.',
      image: Icons.security_outlined,
      color: const Color(0xFF34495E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          // Top Skip Button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 60,
              right: 24,
              child: TextButton(
                onPressed: () => _navigateToLogin(),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: context.colors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          // Bottom Controls
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
                // Next/Get Started Button
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _navigateToLogin();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? context.colors.primaryTeal : context.colors.dividerColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.image,
              size: 100,
              color: data.color,
            ),
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
