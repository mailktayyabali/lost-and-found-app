import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _currentStep = 0;
  bool _isLost = true;

  // Form Controllers - Phase 1
  final _itemNameController = TextEditingController();
  String _selectedCategory = 'Electronics';
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form Controllers - Phase 2
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // Form Controllers - Phase 3
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onStepTapped(int step) {
    setState(() => _currentStep = step);
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      // Submit Report
      _submitReport();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submitReport() {
    // Show success dialog or snackbar and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted successfully!'),
        backgroundColor: context.colors.primaryTeal,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLost = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isLost ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isLost
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
                  'I Lost Something',
                  style: TextStyle(
                    color: _isLost ? context.colors.textDark : context.colors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLost = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isLost ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !_isLost
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
                  'I Found Something',
                  style: TextStyle(
                    color: !_isLost ? context.colors.textDark : context.colors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.textDark,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.primaryTeal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.colors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colors.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: context.colors.textLight),
              items: ['Electronics', 'Wallets', 'Keys', 'Pets', 'Bags', 'Other']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: 'Upload Photos ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textDark,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.colors.dividerColor,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.textLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cloud_upload, color: Colors.white, size: 24),
              ),
              SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'Drag & drop files here or ',
                  style: TextStyle(color: context.colors.textLight, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'browse',
                      style: TextStyle(color: context.colors.primaryTeal, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'PNG, JPG, GIF up to 10MB',
                style: TextStyle(color: context.colors.textLight, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('About the Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            _buildTextField('Item Name', 'e.g., Black Leather Wallet', _itemNameController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Category')),
                SizedBox(width: 16),
                Expanded(child: _buildTextField('Color', 'e.g., Red', _colorController)),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField(
              'Detailed Description',
              'Describe any distinctive features, brand, condition, or contents...',
              _descriptionController,
              maxLines: 4,
            ),
            SizedBox(height: 16),
            _buildPhotoUpload(),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Where & When', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            _buildTextField('Location', 'e.g., Central Park, near the fountain', _locationController),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Date Lost', 'dd/mm/yyyy', _dateController)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField('Approximate Time', '--:-- --', _timeController)),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text('Your Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Your Name', 'John Doe', _nameController)),
                SizedBox(width: 16),
                Expanded(child: _buildTextField('Email Address', 'you@example.com', _emailController)),
              ],
            ),
            SizedBox(height: 16),
            _buildTextField('Phone Number', 'e.g., +1 234 567 890', _phoneController),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: Color(0xFFF59E0B), size: 16),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your contact information will be kept private and shared only with a user who has a confirmed match for your item.',
                      style: TextStyle(fontSize: 11, color: context.colors.textLight),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryTeal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Report an Item',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          Text(
            'Help reunite lost items with their owners',
            style: TextStyle(color: context.colors.textLight, fontSize: 13),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _buildToggle(),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: context.colors.primaryTeal),
              ),
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepTapped: _onStepTapped,
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                steps: _buildSteps(),
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: context.colors.dividerColor),
                              ),
                            ),
                            child: Text('Back', style: TextStyle(color: context.colors.textDark)),
                          ),
                        if (_currentStep == 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: context.colors.dividerColor),
                              ),
                            ),
                            child: Text('Cancel', style: TextStyle(color: context.colors.textDark)),
                          ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primaryTeal,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentStep == 2 ? 'Submit Report' : 'Continue',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
