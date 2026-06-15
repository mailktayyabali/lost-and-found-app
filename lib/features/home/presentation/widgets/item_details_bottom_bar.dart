import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/item_model.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../messages/presentation/chat_screen.dart';

class ItemDetailsBottomBar extends StatelessWidget {
  final Item item;
  final String reporterName;

  const ItemDetailsBottomBar({
    super.key,
    required this.item,
    required this.reporterName,
  });

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'Spam';
    final reasons = ['Spam', 'Inappropriate Content', 'False Information', 'Other'];
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.colors.surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.flag_rounded, color: context.colors.tagLostRed, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Report Item',
                    style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a reason for reporting this item:',
                    style: TextStyle(color: context.colors.textLight, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    dropdownColor: context.colors.surfaceWhite,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason, style: TextStyle(color: context.colors.textDark)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedReason = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    style: TextStyle(color: context.colors.textDark),
                    decoration: InputDecoration(
                      labelText: 'Comments (Optional)',
                      labelStyle: TextStyle(color: context.colors.textLight),
                      hintText: 'Enter more details...',
                      hintStyle: TextStyle(color: context.colors.textLight.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: context.colors.primaryTeal),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: context.colors.textDark)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.tagLostRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final currentUser = AuthService().currentUser;
                    final dateStr = DateFormat('M/d/yyyy').format(DateTime.now());
                    final ownerUid = item.createdBy;
                    
                    final reportData = {
                      'itemId': item.id,
                      'title': item.title,
                      'reportedBy': currentUser?.displayName ?? 'Anonymous',
                      'reportedByUid': currentUser?.uid ?? 'anonymous',
                      'ownerUid': ownerUid ?? 'anonymous',
                      'reason': selectedReason + (commentController.text.trim().isNotEmpty ? ': ${commentController.text.trim()}' : ''),
                      'status': 'PENDING',
                      'date': dateStr,
                      'isUserReport': false,
                      'createdAt': FieldValue.serverTimestamp(),
                    };

                    Navigator.pop(dialogContext); // Close dialog

                    try {
                      final db = FirebaseFirestore.instance;
                      
                      // 1. Submit the report to moderation queue
                      await db.collection('moderation_queue').add(reportData);
                      
                      // 2. Notify the post owner about the report
                      if (ownerUid != null && ownerUid.isNotEmpty) {
                        await db.collection('notifications').add({
                          'recipientId': ownerUid,
                          'title': 'Post Reported',
                          'description': 'Your post "${item.title}" has been reported for: $selectedReason.',
                          'type': 'report',
                          'relatedItemId': item.id,
                          'isRead': false,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }

                      // 3. Count pending reports for this itemId
                      final querySnapshot = await db
                          .collection('moderation_queue')
                          .where('itemId', isEqualTo: item.id)
                          .where('status', isEqualTo: 'PENDING')
                          .get();
                      
                      final reportsCount = querySnapshot.size;
                      
                      // 4. Auto-remove post if it gets 5 or more reports
                      if (reportsCount >= 5) {
                        // Delete the item report from reports collection
                        await db.collection('reports').doc(item.id).delete();
                        
                        // Notify the owner that it was removed
                        if (ownerUid != null && ownerUid.isNotEmpty) {
                          await db.collection('notifications').add({
                            'recipientId': ownerUid,
                            'title': 'Post Automatically Removed',
                            'description': 'Your post "${item.title}" was automatically removed after receiving 5 reports.',
                            'type': 'moderation',
                            'relatedItemId': item.id,
                            'isRead': false,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                        }
                        
                        // Resolve all these pending reports in moderation queue
                        final batch = db.batch();
                        for (var doc in querySnapshot.docs) {
                          batch.update(doc.reference, {'status': 'RESOLVED'});
                        }
                        await batch.commit();
                      }

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(reportsCount >= 5 
                              ? 'The item has been automatically removed due to multiple reports.' 
                              : 'Thank you. The item report has been submitted to moderators.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to submit report: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        border: Border(top: BorderSide(color: context.colors.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.colors.dividerColor,
                  width: 1.5,
                ),
                borderRadius: AppDimensions.borderMedium,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.outlined_flag,
                  color: context.colors.textLight,
                ),
                onPressed: () => _showReportDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: (item.createdBy == null || item.createdBy!.isEmpty)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                userName: reporterName,
                                partnerUid: item.createdBy!,
                                avatarUrl:
                                    'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                                itemId: item.id,
                                itemTitle: item.title,
                                itemImageUrl: item.imageUrl,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Contact $reporterName',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDimensions.borderMedium,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
