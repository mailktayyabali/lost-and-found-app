import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'leave_review_screen.dart';
import '../../messages/presentation/chat_screen.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final reporterName = item.reporterName ?? 'Marcus Chen';

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
                  // Image Gallery Placeholder
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: context.colors.background, // Theme-aware background behind image
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main Image overlaying grey background
                        Image.network(
                          item.imageUrl,
                          fit: BoxFit.contain,
                          height: 200,
                        ),
                        // Pagination dots
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.textDark.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildDot(true),
                                _buildDot(false),
                                _buildDot(false),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                              child: _buildInfoCard(context, 
                                icon: Icons.calendar_today,
                                label: 'DATE LOST',
                                value: 'Oct 24, 2023',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInfoCard(context, 
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
                              ), // Fake map mockup
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.location_on,
                              color: context.colors.tagLostRed,
                              size: 48,
                            ), // Large red pin fallback
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
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          decoration: BoxDecoration(
                            color: context.colors.background, // Light grey
                            borderRadius: AppDimensions.borderMedium,
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reporterName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: context.colors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Member since 2021 • 12 items found',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.colors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Color(0xFFF59E0B),
                                size: 16,
                              ), // Yellow star
                              const SizedBox(width: 4),
                              Text(
                                '4.9',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: context.colors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Claim Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.verified,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Claim This Item',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
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
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(
        currentIndex: 0,
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 8 : 6,
      height: isActive ? 8 : 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: context.colors.primaryTeal),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.primaryTeal,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
