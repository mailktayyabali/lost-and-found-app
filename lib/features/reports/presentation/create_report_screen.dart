import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/cloudinary_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../shared/presentation/widgets/mock_map_widget.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/domain/auth_service.dart';
import '../data/repositories/firebase_reports_repository.dart';
import 'report_success_screen.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  int _currentStep = 0;
  bool _isLost = true;
  bool _isSubmitting = false;

  // Form Controllers - Phase 1
  final _itemNameController = TextEditingController();
  String _selectedCategory = 'Electronics';
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Media
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

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

  // Image Picking
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Date Picking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: context.colors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Time Picking
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: context.colors.primaryTeal,
              onPrimary: Colors.white,
              onSurface: context.colors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _onStepTapped(int step) {
    if (_isSubmitting) return;
    setState(() => _currentStep = step);
  }

  void _onStepContinue() {
    if (_isSubmitting) return;
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _submitReport();
    }
  }

  void _onStepCancel() {
    if (_isSubmitting) return;
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<String> _uploadImageToCloudinary(String filePath) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', filePath));
        
      final response = await request.send().timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url'] as String;
      } else {
        throw Exception('Cloudinary upload failed with status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Cloudinary upload timed out. Please check your internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  void _submitReport() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final currentUser = AuthService().currentUser;
    final reportId = FirebaseFirestore.instance.collection('reports').doc().id;

    try {
      String uploadedImageUrl = 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200';
      
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrl = await _uploadImageToCloudinary(_selectedImages.first.path);
      }

      final newItem = Item(
        id: reportId,
        title: _itemNameController.text.trim().isEmpty ? 'Unnamed Item' : _itemNameController.text.trim(),
        location: _locationController.text.trim().isEmpty ? 'Unknown Location' : _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        isLost: _isLost,
        imageUrl: uploadedImageUrl,
        timeAgo: 'Just now',
        category: _selectedCategory,
        status: _isLost ? 'LOST' : 'FOUND',
        createdBy: currentUser?.uid ?? 'anonymous',
        reporterName: _nameController.text.trim().isEmpty ? (currentUser?.displayName ?? 'Anonymous') : _nameController.text.trim(),
        reporterEmail: _emailController.text.trim().isEmpty ? (currentUser?.email ?? '') : _emailController.text.trim(),
        reporterPhone: _phoneController.text.trim().isEmpty ? '' : _phoneController.text.trim(),
      );

      await FirebaseReportsRepository().addReport(newItem);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ReportSuccessScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLost = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: context.colors.primaryTeal, size: 20) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        child: Text(category, style: const TextStyle(fontSize: 14)),
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
            children: const [
              TextSpan(
                text: '*',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.colors.dividerColor),
                      ),
                      child: Icon(Icons.add_a_photo, color: context.colors.primaryTeal),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.textLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG, GIF up to 10MB',
                    style: TextStyle(color: context.colors.textLight, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('About the Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            _buildTextField('Item Name', 'e.g., Black Leather Wallet', _itemNameController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown('Category')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Color', 'e.g., Red', _colorController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Detailed Description',
              'Describe any distinctive features, brand, condition, or contents...',
              _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildPhotoUpload(),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Where & When', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.colors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            MockMapWidget(
              isPicker: true,
              height: 150,
              onTap: () {
                // In a real app, this would open a full map screen to pick a location
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock Map Picker tapped')),
                );
                setState(() {
                  _locationController.text = 'Mock Selected Location';
                });
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Or enter address manually',
                hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Date ${_isLost ? 'Lost' : 'Found'}', 
                    'dd/mm/yyyy', 
                    _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Approximate Time', 
                    '--:-- --', 
                    _timeController,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    suffixIcon: Icons.access_time,
                  ),
                ),
              ],
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Your Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField('Your Name', 'John Doe', _nameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Email Address', 'you@example.com', _emailController)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Phone Number', 'e.g., +1 234 567 890', _phoneController),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFFF59E0B), size: 16),
                  const SizedBox(width: 12),
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
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildToggle(),
          ),
          const SizedBox(height: 16),
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
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _isSubmitting ? null : details.onStepCancel,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: context.colors.dividerColor),
                              ),
                            ),
                            child: Text('Back', style: TextStyle(color: context.colors.textDark)),
                          ),
                        if (_currentStep == 0)
                          TextButton(
                            onPressed: _isSubmitting ? null : details.onStepCancel,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: context.colors.dividerColor),
                              ),
                            ),
                            child: Text('Cancel', style: TextStyle(color: context.colors.textDark)),
                          ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primaryTeal,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _currentStep == 2 ? 'Submit Report' : 'Continue',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
