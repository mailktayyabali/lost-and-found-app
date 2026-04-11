import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    
    // Navigate to home after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
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
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Light flash pulse effect from underneath
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Container(
              width: 140 + (value * 130),
              height: 140 + (value * 130),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.6 * (1 - value)),
                    AppColors.primaryBlue.withOpacity(0.0),
                  ],
                ),
              ),
            );
          },
        ),
        // Main Logo Box
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
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
        ),
      ],
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
        color: AppColors.primaryBlue.withOpacity(0.85),
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 2500),
          curve: Curves.fastOutSlowIn,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              minHeight: 4,
            );
          },
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
