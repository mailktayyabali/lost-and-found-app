import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DeleteUserDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onDeleteConfirm;

  const DeleteUserDialog({
    super.key,
    required this.userName,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.colors.surfaceWhite,
      title: Text('Delete User', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
      content: Text('Are you sure you want to permanently delete user "$userName"?', style: TextStyle(color: context.colors.textLight)),
      actions: [
        TextButton(
          child: Text('Cancel', style: TextStyle(color: context.colors.textLight)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: context.colors.tagLostRed),
          onPressed: () {
            Navigator.of(context).pop();
            onDeleteConfirm();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
