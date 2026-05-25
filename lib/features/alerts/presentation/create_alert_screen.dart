import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../home/presentation/widgets/home_drawer.dart';

class CreateAlertScreen extends StatefulWidget {
  const CreateAlertScreen({super.key});

  @override
  State<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends State<CreateAlertScreen> {
  bool _isLostAlert = true;
  double _radius = 5.2;
  String? _selectedCategory;
  final List<String> _categories = ['Electronics', 'Wallets', 'Keys', 'Pets', 'Bags', 'Other'];

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
          'Alert Management',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: context.colors.textLight),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingExtraLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Alert',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: context.colors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Define specific parameters to be notified immediately when a matching item is posted in your vicinity.',
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Switch
            Container(
              decoration: BoxDecoration(
                color: context.colors.background,
                borderRadius: AppDimensions.borderMedium,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostAlert = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isLostAlert ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _isLostAlert
                              ? [
                                  BoxShadow(
                                    color: context.colors.textDark.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Lost Item Alert',
                          style: TextStyle(
                            color: _isLostAlert ? context.colors.primaryTeal : context.colors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLostAlert = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isLostAlert ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: !_isLostAlert
                              ? [
                                  BoxShadow(
                                    color: context.colors.textDark.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Found Item Alert',
                          style: TextStyle(
                            color: !_isLostAlert ? context.colors.primaryTeal : context.colors.textLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Form Fields Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('ALERT NAME'),
                  _buildTextField(hint: 'e.g., My Lost Keys'),
                  SizedBox(height: 24),
                  _buildLabel('KEYWORDS'),
                  _buildTextField(hint: 'Silver keys, leather keychain...', suffixIcon: Icons.search),
                  SizedBox(height: 24),
                  _buildLabel('CATEGORY'),
                  _buildDropdownField('Select Category'),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Location Card
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('LOCATION SELECTION'),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.my_location, color: context.colors.primaryTeal, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'San Francisco, California',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Map Mockup
                  Image.network(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&q=80&w=600',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('ALERT RADIUS'),
                            Text(
                              '${_radius.toStringAsFixed(1)} Miles',
                              style: TextStyle(
                                color: context.colors.primaryTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: context.colors.primaryTeal,
                            inactiveTrackColor: context.colors.dividerColor,
                            thumbColor: context.colors.primaryTeal,
                            overlayColor: context.colors.primaryTeal.withValues(alpha: 0.1),
                            trackHeight: 4.0,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          ),
                          child: Slider(
                            value: _radius,
                            min: 1,
                            max: 50,
                            onChanged: (v) => setState(() => _radius = v),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('1 MI', style: _sliderTextStyle()),
                            Text('50 MI', style: _sliderTextStyle()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Alert created successfully!'),
                      backgroundColor: context.colors.primaryTeal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) Navigator.pop(context);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Create Alert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'You can manage or silence alerts anytime in Profile settings.',
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textLight,
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 2), // Highlighting Alerts tab
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: context.colors.textLight,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({required String hint, IconData? suffixIcon}) {
    return Padding(
      padding: EdgeInsets.only(top: 12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textLight, fontSize: 15),
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: context.colors.textLight, size: 20) : null,
          filled: true,
          fillColor: context.colors.dividerColor.withValues(alpha: 0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.dividerColor.withValues(alpha: 0.6),
          borderRadius: AppDimensions.borderMedium,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            hint: Text(hint, style: TextStyle(color: context.colors.textLight, fontSize: 15)),
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down, color: context.colors.textLight),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: TextStyle(color: context.colors.textDark, fontSize: 15)),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _selectedCategory = v;
              });
            },
          ),
        ),
      ),
    );
  }

  TextStyle _sliderTextStyle() {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: context.colors.textLight,
    );
  }
}
