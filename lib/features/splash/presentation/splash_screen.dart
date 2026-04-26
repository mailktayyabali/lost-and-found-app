import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Navigate to login after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            _buildLogo(),
            const SizedBox(height: 32),
            _buildTitle(),
            const SizedBox(height: 6),
            _buildSubtitle(),
            const Spacer(flex: 2),
            _buildProgressBar(),
            const SizedBox(height: 16),
            _buildStatusText(),
            const Spacer(flex: 3),
            _buildFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Magnifying Glass
          const Icon(
            Icons.search_rounded,
            size: 100,
            color: AppColors.textDark,
          ),
          // Inner group
          Positioned(
            top: 25,
            left: 28,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Wallet inside
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 42,
                  color: AppColors.textDark,
                ),
                // Location pin offset to top-left
                Positioned(
                  top: -12,
                  left: -8,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.background,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 24,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'FoundIt',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: AppColors.textDark,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'LOST & FOUND',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryTeal.withValues(alpha: 0.85),
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: null, // Indeterminate without animation
          backgroundColor: AppColors.primaryTeal.withValues(alpha: 0.12),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return const Text(
      'Initializing secure search...',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'SECURE & TRUSTED',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 1.2,
      ),
    );
  }
}
