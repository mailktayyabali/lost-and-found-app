import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/home_screen.dart';
import '../domain/auth_service.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';
import '../../admin/presentation/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Login',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: context.colors.primaryTeal,
                  size: 28,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Log in to report or find your lost items and reconnect with your belongings.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textLight,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textDark,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  hintStyle: TextStyle(color: context.colors.textLight),
                  prefixIcon: Icon(Icons.email_outlined, color: context.colors.textLight),
                  filled: true,
                  fillColor: context.colors.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primaryTeal),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textDark,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: context.colors.textLight),
                  prefixIcon: Icon(Icons.lock_outline, color: context.colors.textLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: context.colors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: context.colors.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.primaryTeal),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: context.colors.primaryTeal,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await AuthService().signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      if (!context.mounted) return;
                      
                      final isAdmin = await AuthService().isAdmin();
                      if (!context.mounted) return;
                      
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => isAdmin ? const AdminDashboardScreen() : const HomeScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      if (context.mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.dividerColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        color: context.colors.textLight,
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.dividerColor)),
                ],
              ),
              SizedBox(height: 24),
              Center(
                child: InkWell(
                  onTap: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    try {
                      await AuthService().signInWithGoogle();
                      if (!context.mounted) return;
                      
                      final isAdmin = await AuthService().isAdmin();
                      if (!context.mounted) return;
                      
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => isAdmin ? const AdminDashboardScreen() : const HomeScreen(),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      // Handle the "cancelled" case specifically if desired
                      if (e.toString().contains('cancelled')) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    } finally {
                      if (context.mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.background,
                    ),
                    alignment: Alignment.center,
                    child: _buildGoogleLogo(),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: context.colors.textLight, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: context.colors.primaryTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text(
            'G',
            style: TextStyle(
               color: Color(0xFFDB4437),
               fontWeight: FontWeight.bold,
               fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
