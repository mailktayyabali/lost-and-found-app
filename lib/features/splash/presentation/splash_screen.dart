import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'onboarding_screen.dart';
import '../../auth/domain/auth_service.dart';
import '../../home/presentation/home_screen.dart';
import '../../admin/presentation/screens/item_management.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Controller for screen entry animations (Scale, Rotation)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 2. Controller for the continuous bouncing pin animation
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.elasticOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entry animations
    _entryController.forward().then((_) {
      if (mounted) {
        // Start continuous bouncing once entered
        _bounceController.repeat(reverse: true);
      }
    });

    // Navigate after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        final authService = AuthService();
        final isLoggedIn = authService.currentUser != null;

        Widget targetScreen = const OnboardingScreen();
        if (isLoggedIn) {
          final isAdmin = await authService.isAdmin();
          targetScreen = isAdmin ? const AdminDashboardScreen() : const HomeScreen();
        }

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
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
  void dispose() {
    _entryController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
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
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _bounceController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.textDark.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Magnifying Glass
                  Icon(
                    Icons.search_rounded,
                    size: 100,
                    color: context.colors.textDark,
                  ),
                  // Inner group
                  Positioned(
                    top: 25,
                    left: 28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Wallet inside
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 42,
                          color: context.colors.textDark,
                        ),
                        // Location pin offset to top-left - Animated Bounce
                        Positioned(
                          top: -12,
                          left: -8,
                          child: Transform.translate(
                            offset: Offset(0, _bounceAnimation.value),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.colors.background,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 24,
                                color: context.colors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      'FoundIt',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: context.colors.textDark,
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
        color: context.colors.primaryTeal.withValues(alpha: 0.85),
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
          value: null,
          backgroundColor: context.colors.primaryTeal.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation<Color>(context.colors.primaryTeal),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Text(
      'Initializing secure search...',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: context.colors.textLight,
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'SECURE & TRUSTED',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.colors.textLight,
        letterSpacing: 1.2,
      ),
    );
  }
}
