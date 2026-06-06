import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../photo_upload_widget.dart';
import '../report_text_field.dart';

class AboutItemStep extends StatelessWidget {
  final TextEditingController itemNameController;
  final TextEditingController colorController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final List<XFile> selectedImages;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  const AboutItemStep({
    super.key,
    required this.itemNameController,
    required this.colorController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportTextField(
          label: 'Item Name',
          hint: 'e.g., Black Leather Wallet',
          controller: itemNameController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdown(context)),
            const SizedBox(width: 16),
            Expanded(
              child: ReportTextField(
                label: 'Color',
                hint: 'e.g., Red',
                controller: colorController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ReportTextField(
          label: 'Detailed Description',
          hint: 'Describe any distinctive features, brand, condition, or contents...',
          controller: descriptionController,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        PhotoUploadWidget(
          selectedImages: selectedImages,
          onPickImages: onPickImages,
          onRemoveImage: onRemoveImage,
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
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
              value: selectedCategory,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: context.colors.textLight),
              items: ['Electronics', 'Wallets', 'Keys', 'Pets', 'Bags', 'Other']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: onCategoryChanged,
            ),
          ),
        ),
      ],
    );
  }
}
