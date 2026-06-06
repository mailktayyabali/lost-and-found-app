import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/info_card.dart';
import 'widgets/reporter_profile_card.dart';
import 'widgets/item_image_gallery.dart';
import 'widgets/item_details_action_buttons.dart';
import 'widgets/item_details_bottom_bar.dart';
import '../../auth/domain/auth_service.dart';
import '../../../shared/models/claim_request_model.dart';
import '../../reports/data/repositories/firebase_claim_repository.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Item item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late Item _currentItem;
  ClaimRequest? _pendingClaimRequest;
  bool _isLoadingClaim = true;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _loadPendingClaim();
  }

  Future<void> _loadPendingClaim() async {
    try {
      final request = await FirebaseClaimRepository().getPendingRequestForItem(_currentItem.id);
      if (mounted) {
        setState(() {
          _pendingClaimRequest = request;
          _isLoadingClaim = false;
        });
      }
    } catch (e) {
      debugPrint('ItemDetailsScreen: Error loading pending claim: $e');
      if (mounted) {
        setState(() {
          _isLoadingClaim = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporterName = _currentItem.reporterName ?? 'Marcus Chen';
    final currentUserId = AuthService().currentUser?.uid;
    final isOwnItem = currentUserId != null && _currentItem.createdBy == currentUserId;

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
              final isSaved = SavedItemsService().isSaved(_currentItem.id);
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? context.colors.primaryTeal : context.colors.textDark,
                ),
                onPressed: () {
                  SavedItemsService().toggleSave(_currentItem);
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
                  ItemImageGallery(imageUrl: _currentItem.imageUrl),
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
                              'Reported ${_currentItem.timeAgo}',
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
                          _currentItem.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          _currentItem.description,
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
                                value: _currentItem.category,
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
                              'Near ${_currentItem.location}',
                              style: TextStyle(
                                color: context.colors.textLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Profile Card
                        ReporterProfileCard(
                          reporterUid: _currentItem.createdBy,
                          reporterName: reporterName,
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons (Edit/Delete or Claim/Rate)
                        _isLoadingClaim
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : ItemDetailsActionButtons(
                                item: _currentItem,
                                isOwnItem: isOwnItem,
                                reporterName: reporterName,
                                pendingClaimRequest: _pendingClaimRequest,
                                onClaimSubmitted: _loadPendingClaim,
                                onUpdated: (updatedItem) {
                                  setState(() {
                                    _currentItem = updatedItem;
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pinned Bottom Bar (Contact & Flag) - Hidden for owner
          if (!isOwnItem)
            ItemDetailsBottomBar(
              item: _currentItem,
              reporterName: reporterName,
            ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(
        currentIndex: 0,
      ),
    );
  }
}
