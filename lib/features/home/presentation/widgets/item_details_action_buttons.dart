import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/item_model.dart';
import '../../../../shared/models/claim_request_model.dart';
import '../../../reports/presentation/create_report_screen.dart';
import '../../../reports/data/repositories/firebase_reports_repository.dart';
import '../../../reports/data/repositories/firebase_claim_repository.dart';
import '../../../auth/domain/auth_service.dart';
import '../leave_review_screen.dart';

class ItemDetailsActionButtons extends StatelessWidget {
  final Item item;
  final bool isOwnItem;
  final String reporterName;
  final ClaimRequest? pendingClaimRequest;
  final VoidCallback onClaimSubmitted;
  final ValueChanged<Item> onUpdated;

  const ItemDetailsActionButtons({
    super.key,
    required this.item,
    required this.isOwnItem,
    required this.reporterName,
    required this.pendingClaimRequest,
    required this.onClaimSubmitted,
    required this.onUpdated,
  });

  void _showClaimDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final themeColors = context.colors;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: themeColors.surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Claim This Item',
            style: TextStyle(color: themeColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide a detailed description to prove your ownership (e.g., specific markings, serial number, location lost detail).',
                style: TextStyle(color: themeColors.textLight, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter description or proof here...',
                  hintStyle: TextStyle(color: themeColors.textLight.withValues(alpha: 0.6), fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeColors.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: themeColors.primaryTeal, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: TextStyle(color: themeColors.textDark, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: themeColors.textLight, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final text = descriptionController.text.trim();
                if (text.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a description for your claim.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop(); // Close dialog

                final currentUser = AuthService().currentUser;
                final requesterName = currentUser?.displayName ?? currentUser?.email?.split('@').first ?? 'Anonymous';

                final request = ClaimRequest(
                  id: '',
                  itemId: item.id,
                  itemTitle: item.title,
                  itemImageUrl: item.imageUrl,
                  requesterUid: currentUser?.uid ?? 'anonymous',
                  requesterName: requesterName,
                  ownerUid: item.createdBy ?? 'anonymous',
                  description: text,
                  status: 'PENDING',
                  createdAt: DateTime.now(),
                );

                try {
                  await FirebaseClaimRepository().submitClaimRequest(request);
                  onClaimSubmitted();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Claim request submitted successfully!'),
                      backgroundColor: themeColors.primaryTeal,
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit claim request: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isOwnItem) {
      return Column(
        children: [
          // Edit Post Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final themeColors = context.colors;

                final updatedItem = await Navigator.push<Item>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateReportScreen(itemToEdit: item),
                  ),
                );
                if (updatedItem != null) {
                  onUpdated(updatedItem);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('Post updated successfully!'),
                      backgroundColor: themeColors.primaryTeal,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Edit Post',
                style: TextStyle(
                  fontSize: 16,
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
          const SizedBox(height: 16),

          // Delete Post Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final themeColors = context.colors;

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: context.colors.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'Delete Post',
                        style: TextStyle(
                          color: context.colors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to permanently delete this post for "${item.title}"? This action cannot be undone.',
                        style: TextStyle(
                          color: context.colors.textLight,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: context.colors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.tagLostRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  try {
                    await FirebaseReportsRepository().deleteReport(item.id);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('"${item.title}" has been successfully deleted.'),
                        backgroundColor: themeColors.tagLostRed,
                      ),
                    );
                    navigator.pop();
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete post: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: Icon(Icons.delete_outline, color: context.colors.tagLostRed),
              label: Text(
                'Delete Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.tagLostRed,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: context.colors.tagLostRed,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } else {
      final currentUserId = AuthService().currentUser?.uid;
      final isMyPendingClaim = pendingClaimRequest != null && pendingClaimRequest!.requesterUid == currentUserId;

      return Column(
        children: [
          // Claim Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: pendingClaimRequest != null
                ? ElevatedButton.icon(
                    onPressed: null,
                    icon: Icon(
                      Icons.lock_clock,
                      color: context.colors.textLight.withValues(alpha: 0.6),
                    ),
                    label: Text(
                      isMyPendingClaim ? 'Claim Requested (Pending)' : 'Claim Pending by Other User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textLight.withValues(alpha: 0.6),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.dividerColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderMedium,
                      ),
                      elevation: 0,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () => _showClaimDialog(context),
                    icon: const Icon(
                      Icons.verified,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Claim This Item',
                      style: TextStyle(
                        fontSize: 16,
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
          const SizedBox(height: 16),

          // Rate Experience Button
          if (item.createdBy != null && item.createdBy!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LeaveReviewScreen(
                        revieweeUid: item.createdBy!,
                        userName: reporterName,
                        userAvatarUrl:
                            'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.star,
                  color: context.colors.primaryTeal,
                ),
                label: Text(
                  'Rate Experience',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primaryTeal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: context.colors.primaryTeal,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Let others know about your interaction with $reporterName',
                style: TextStyle(
                  fontSize: 11,
                  color: context.colors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      );
    }
  }
}
