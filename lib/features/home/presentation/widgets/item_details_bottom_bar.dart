import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/item_model.dart';
import '../../../messages/presentation/chat_screen.dart';

class ItemDetailsBottomBar extends StatelessWidget {
  final Item item;
  final String reporterName;

  const ItemDetailsBottomBar({
    super.key,
    required this.item,
    required this.reporterName,
  });

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
                // TODO: Implement reporting/flagging flow
                onPressed: null,
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
