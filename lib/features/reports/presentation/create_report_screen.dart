import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/cloudinary_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/domain/auth_service.dart';
import '../data/repositories/firebase_reports_repository.dart';
import 'report_success_screen.dart';
import 'widgets/report_toggle.dart';
import 'widgets/steps/about_item_step.dart';
import 'widgets/steps/where_and_when_step.dart';
import 'widgets/steps/contact_details_step.dart';

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

  bool _validateStep(int step) {
    if (step == 0) {
      if (_itemNameController.text.trim().isEmpty) {
        _showValidationError('Please enter the item name.');
        return false;
      }
      if (_descriptionController.text.trim().isEmpty) {
        _showValidationError('Please enter a detailed description.');
        return false;
      }
      if (_selectedImages.isEmpty) {
        _showValidationError('Please upload at least one photo.');
        return false;
      }
    } else if (step == 1) {
      if (_locationController.text.trim().isEmpty) {
        _showValidationError('Please select or enter a location.');
        return false;
      }
      if (_dateController.text.trim().isEmpty) {
        _showValidationError('Please select the date.');
        return false;
      }
      if (_timeController.text.trim().isEmpty) {
        _showValidationError('Please select the approximate time.');
        return false;
      }
    } else if (step == 2) {
      if (_nameController.text.trim().isEmpty) {
        _showValidationError('Please enter your name.');
        return false;
      }
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _showValidationError('Please enter your email.');
        return false;
      }
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(email)) {
        _showValidationError('Please enter a valid email address.');
        return false;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showValidationError('Please enter your phone number.');
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onStepTapped(int step) {
    if (_isSubmitting) return;
    for (int i = 0; i < step; i++) {
      if (!_validateStep(i)) return;
    }
    setState(() => _currentStep = step);
  }

  void _onStepContinue() {
    if (_isSubmitting) return;
    if (!_validateStep(_currentStep)) return;
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

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('About the Item', style: TextStyle(fontWeight: FontWeight.bold)),
        content: AboutItemStep(
          itemNameController: _itemNameController,
          colorController: _colorController,
          descriptionController: _descriptionController,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
          selectedImages: _selectedImages,
          onPickImages: _pickImages,
          onRemoveImage: _removeImage,
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Where & When', style: TextStyle(fontWeight: FontWeight.bold)),
        content: WhereAndWhenStep(
          locationController: _locationController,
          dateController: _dateController,
          timeController: _timeController,
          isLost: _isLost,
          onSelectDate: () => _selectDate(context),
          onSelectTime: () => _selectTime(context),
          onTapMap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mock Map Picker tapped')),
            );
            setState(() {
              _locationController.text = 'Mock Selected Location';
            });
          },
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Your Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: ContactDetailsStep(
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
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
            child: ReportToggle(
              isLost: _isLost,
              onToggle: (value) => setState(() => _isLost = value),
            ),
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
