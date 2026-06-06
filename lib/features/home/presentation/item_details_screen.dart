import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'leave_review_screen.dart';
import '../../messages/presentation/chat_screen.dart';
import '../../auth/domain/auth_service.dart';
import 'widgets/info_card.dart';
import 'widgets/reporter_profile_card.dart';
import 'widgets/item_image_gallery.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final reporterName = item.reporterName ?? 'Marcus Chen';
    final currentUserId = AuthService().currentUser?.uid;
    final isOwnItem = currentUserId != null && item.createdBy == currentUserId;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textDark),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Item Details',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: SavedItemsService(),
            builder: (context, _) {
              final isSaved = SavedItemsService().isSaved(item.id);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? context.colors.primaryTeal : context.colors.textDark,
                ),
                onPressed: () {
                  SavedItemsService().toggleSave(item);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: context.colors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemImageGallery(imageUrl: item.imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.tagLostRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: context.colors.tagLostRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'STATUS',
                                    style: TextStyle(
                                      color: context.colors.tagLostRed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Reported ${item.timeAgo}',
                              style: TextStyle(
                                color: context.colors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textDark,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Cards row
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                icon: Icons.calendar_today,
                                label: 'DATE LOST',
                                value: 'Oct 24, 2023',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InfoCard(
                                icon: Icons.category,
                                label: 'CATEGORY',
                                value: item.category,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Map Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Seen Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textDark,
                              ),
                            ),
                            Text(
                              'Get Directions',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.primaryTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: context.colors.surfaceWhite,
                            border: Border.all(color: context.colors.dividerColor),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://maps.googleapis.com/maps/api/staticmap?center=Dolores+Park,San+Francisco&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7CDolores+Park,San+Francisco&key=YOUR_API_KEY_MOCK',
                              ),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.location_on,
                              color: context.colors.tagLostRed,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.navigation_outlined,
                              size: 14,
                              color: context.colors.textLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Near ${item.location}',
                              style: TextStyle(
                                color: context.colors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Card
                        ReporterProfileCard(reporterName: reporterName),
                        const SizedBox(height: 24),

                        // Claim Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isOwnItem) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You cannot claim an item that you posted yourself.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Claim request for "${item.title}" submitted successfully!'),
                                    backgroundColor: context.colors.primaryTeal,
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isOwnItem ? Icons.info_outline : Icons.verified,
                              color: isOwnItem ? context.colors.textLight : Colors.white,
                            ),
                            label: Text(
                              isOwnItem ? 'You Posted This Item' : 'Claim This Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOwnItem ? context.colors.textLight : Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOwnItem ? context.colors.dividerColor : context.colors.primaryTeal,
                              foregroundColor: isOwnItem ? context.colors.textLight : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppDimensions.borderMedium,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rate Experience Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (isOwnItem) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You cannot rate yourself or leave a review on your own post.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LeaveReviewScreen(
                                      userName: reporterName,
                                      userAvatarUrl:
                                          'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.star,
                              color: isOwnItem ? context.colors.textLight : context.colors.primaryTeal,
                            ),
                            label: Text(
                              isOwnItem ? 'Cannot Rate Yourself' : 'Rate Experience',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOwnItem ? context.colors.textLight : context.colors.primaryTeal,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isOwnItem ? context.colors.dividerColor : context.colors.primaryTeal,
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Pinned Action Bar
          Container(
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
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (isOwnItem) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You cannot message yourself.'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  userName: reporterName,
                                  partnerUid: item.createdBy ?? '',
                                  avatarUrl:
                                      'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                                  isOnline: true,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          color: isOwnItem ? context.colors.textLight : Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          isOwnItem ? 'Your Listing (Cannot Chat)' : 'Contact $reporterName',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isOwnItem ? context.colors.textLight : Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isOwnItem ? context.colors.dividerColor : context.colors.primaryTeal,
                          foregroundColor: isOwnItem ? context.colors.textLight : Colors.white,
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
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
