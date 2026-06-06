import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class PhotoUploadWidget extends StatelessWidget {
  final List<XFile> selectedImages;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  const PhotoUploadWidget({
    super.key,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
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
        if (selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == selectedImages.length) {
                  return GestureDetector(
                    onTap: onPickImages,
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
                          image: FileImage(File(selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => onRemoveImage(index),
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
            onTap: onPickImages,
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
}
