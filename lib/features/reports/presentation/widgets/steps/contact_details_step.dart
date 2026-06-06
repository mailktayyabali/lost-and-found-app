import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../report_text_field.dart';

class ContactDetailsStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const ContactDetailsStep({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ReportTextField(
                label: 'Your Name',
                hint: 'John Doe',
                controller: nameController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ReportTextField(
                label: 'Email Address',
                hint: 'you@example.com',
                controller: emailController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReportTextField(
          label: 'Phone Number',
          hint: 'e.g., +1 234 567 890',
          controller: phoneController,
        ),
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
    );
  }
}
