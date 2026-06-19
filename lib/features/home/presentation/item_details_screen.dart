import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/geocoding_service.dart';
import '../../../shared/widgets/heartbeat_bookmark_button.dart';
import '../../../shared/widgets/mock_map_widget.dart';
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
  String _displayLocation = '';
  double? _parsedLatitude;
  double? _parsedLongitude;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    _displayLocation = _currentItem.displayLocation;
    _parsedLatitude = _currentItem.latitude;
    _parsedLongitude = _currentItem.longitude;
    _loadPendingClaim();
    _resolveLocationAddress();
  }

  Future<void> _resolveLocationAddress() async {
    // 1. If coordinates are null, parse them directly from the location string
    if (_parsedLatitude == null || _parsedLongitude == null) {
      final match = RegExp(
        r'(?:Latitude|Lat):\s*([-\d.]+),\s*(?:Longitude|Lon|Lng):\s*([-\d.]+)',
        caseSensitive: false,
      ).firstMatch(_currentItem.location);

      if (match != null) {
        _parsedLatitude = double.tryParse(match.group(1) ?? '');
        _parsedLongitude = double.tryParse(match.group(2) ?? '');
      } else {
        final matchRaw = RegExp(r'^\s*([-\d.]+)\s*,\s*([-\d.]+)\s*$').firstMatch(_currentItem.location);
        if (matchRaw != null) {
          _parsedLatitude = double.tryParse(matchRaw.group(1) ?? '');
          _parsedLongitude = double.tryParse(matchRaw.group(2) ?? '');
        }
      }
    }

    // 2. If we have coordinates, reverse geocode to resolve a clean address
    if (_parsedLatitude != null && _parsedLongitude != null) {
      final resolvedAddress = await GeocodingService.reverseGeocode(
        _parsedLatitude!,
        _parsedLongitude!,
      );
      if (resolvedAddress != null) {
        if (mounted) {
          setState(() {
            _displayLocation = resolvedAddress;
          });
        }
      } else {
        // Fallback to formatted coordinates offline
        if (mounted) {
          setState(() {
            _displayLocation = _formatCoordinates(_parsedLatitude!, _parsedLongitude!);
          });
        }
      }
    } else {
      // Keep displaying the parsed/original displayLocation
      if (mounted) {
        setState(() {
          _displayLocation = _currentItem.displayLocation;
        });
      }
    }
  }

  String _formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}° $latDir, ${lng.abs().toStringAsFixed(4)}° $lngDir';
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
          HeartbeatBookmarkButton(item: _currentItem),
          IconButton(
            icon: Icon(Icons.share, color: context.colors.textDark),
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: 'lostandfound://item/${_currentItem.id}'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Post link copied to clipboard!'),
                  backgroundColor: context.colors.primaryTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
                  ItemImageGallery(imageUrls: _currentItem.imageUrls),
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
                        MockMapWidget(
                          height: 180,
                          isPicker: false,
                          locationName: _displayLocation,
                          center: _parsedLatitude != null && _parsedLongitude != null
                              ? LatLng(_parsedLatitude!, _parsedLongitude!)
                              : null,
                          radiusKm: null,
                          showUserLocationButton: false,
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
                            Expanded(
                              child: Text(
                                'Near $_displayLocation',
                                style: TextStyle(
                                  color: context.colors.textLight,
                                  fontSize: 13,
                                ),
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
