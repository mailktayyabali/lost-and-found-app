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
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            _buildLogo(),
            SizedBox(height: 32),
            _buildTitle(),
            SizedBox(height: 6),
            _buildSubtitle(),
            const Spacer(flex: 2),
            _buildProgressBar(),
            SizedBox(height: 16),
            _buildStatusText(),
            const Spacer(flex: 3),
            _buildFooter(),
            SizedBox(height: 24),
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
                // Location pin offset to top-left
                Positioned(
                  top: -12,
                  left: -8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.background,
                    ),
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 24,
                      color: context.colors.textDark,
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
      padding: EdgeInsets.symmetric(horizontal: 48.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: null, // Indeterminate without animation
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
