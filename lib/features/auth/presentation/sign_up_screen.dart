import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textDark),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: context.colors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon at top
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add_alt_1, // Best match for person with plus
                    color: context.colors.primaryTeal,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Title
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              // Subtitle
              Text(
                'Join our community to help find lost items\nand return them to owners.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              
              // Full Name Field
              _buildFieldLabel('Full Name'),
              SizedBox(height: 8),
              _buildTextField(
                hint: 'Enter your full name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 20),

              // Email Field
              _buildFieldLabel('Email'),
              SizedBox(height: 8),
              _buildTextField(
                hint: 'example@mail.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),

              // Password Field
              _buildFieldLabel('Password'),
              SizedBox(height: 8),
              _buildTextField(
                hint: 'Create a password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscurePassword,
                onVisibilityToggle: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              SizedBox(height: 20),

              // Confirm Password Field
              _buildFieldLabel('Confirm Password'),
              SizedBox(height: 8),
              _buildTextField(
                hint: 'Repeat your password',
                icon: Icons.restore_rounded, // Best match for circular arrow
                isPassword: true,
                obscureText: _obscureConfirmPassword,
                onVisibilityToggle: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              SizedBox(height: 20),

              // Terms of Service Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                         setState(() {
                           _agreedToTerms = value ?? false;
                         });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: context.colors.fieldBorder, width: 1.5),
                      activeColor: context.colors.primaryTeal,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: context.colors.textLight,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(color: context.colors.primaryTeal, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy\nPolicy',
                            style: TextStyle(color: context.colors.primaryTeal, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    // Mock network delay
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) {
                      setState(() => _isLoading = false);
                      // Normally this would go to home or verify screen
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              SizedBox(height: 24),
              
              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.dividerColor)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                       'OR',
                       style: TextStyle(
                         color: context.colors.textLight,
                         fontSize: 13,
                         fontWeight: FontWeight.w600,
                         letterSpacing: 0.5,
                       ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.dividerColor)),
                ],
              ),
              SizedBox(height: 24),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: context.colors.textLight, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        color: context.colors.primaryTeal,
                        fontSize: 15,
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

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.colors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: context.colors.textDark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.textLight),
        prefixIcon: Icon(icon, color: context.colors.textLight),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.remove_red_eye_rounded,
                  color: context.colors.textLight,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
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
    );
  }
}
