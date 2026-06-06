import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/item_model.dart';

class DeleteListingDialog extends StatelessWidget {
  final Item item;
  final VoidCallback onDeleteConfirm;

  const DeleteListingDialog({
    super.key,
    required this.item,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Delete Listing',
        style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to permanently delete this listing for "${item.title}"? This action cannot be undone.',
        style: TextStyle(color: context.colors.textLight),
      ),
      actions: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: context.colors.textLight, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.tagLostRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onDeleteConfirm();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
