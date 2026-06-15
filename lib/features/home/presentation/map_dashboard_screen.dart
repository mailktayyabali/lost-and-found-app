import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/widgets/mock_map_widget.dart';
import '../../reports/presentation/providers/reports_provider.dart';
import 'widgets/item_card.dart';

class MapDashboardScreen extends ConsumerStatefulWidget {
  const MapDashboardScreen({super.key});

  @override
  ConsumerState<MapDashboardScreen> createState() => _MapDashboardScreenState();
}

class _MapDashboardScreenState extends ConsumerState<MapDashboardScreen> {
  Item? _selectedItem;
  String _searchQuery = '';
  
  // Default map center (Central Park, NYC)
  LatLng _mapCenter = const LatLng(40.785091, -73.968285);

  List<Item> _filterItems(List<Item> items) {
    if (_searchQuery.trim().isEmpty) {
      return items;
    }
    return items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.location.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsListProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Map View',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.colors.textDark),
            onPressed: () {
              ref.invalidate(reportsListProvider);
            },
          )
        ],
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading reports: $err', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(reportsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allItems) {
          final mapItems = allItems.where((item) => item.latitude != null && item.longitude != null).toList();
          
          // Post-frame callback to safely set the initial selection if not set yet
          if (_selectedItem == null && mapItems.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedItem = mapItems.first;
                  _mapCenter = LatLng(_selectedItem!.latitude!, _selectedItem!.longitude!);
                });
              }
            });
          }

          final filtered = _filterItems(mapItems);

          // Construct custom Marker widgets for the items
          final List<Marker> markers = filtered.map((item) {
            final isSelected = _selectedItem?.id == item.id;
            return Marker(
              point: LatLng(item.latitude!, item.longitude!),
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItem = item;
                    _mapCenter = LatLng(item.latitude!, item.longitude!);
                  });
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primaryTeal : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : context.colors.primaryTeal,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      item.isLost ? Icons.search : Icons.check_circle_outline,
                      color: isSelected ? Colors.white : context.colors.primaryTeal,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              // Full screen map displaying custom item markers
              Positioned.fill(
                child: MockMapWidget(
                  height: double.infinity,
                  locationName: _selectedItem?.displayLocation ?? 'Nearby Items',
                  center: _mapCenter,
                  customMarkers: markers,
                  showUserLocationButton: true,
                ),
              ),
              
              // Search overlay
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search items in this area...',
                      hintStyle: TextStyle(color: context.colors.textLight),
                      prefixIcon: Icon(Icons.search, color: context.colors.primaryTeal),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
              ),

              // Bottom card overlay for selected item
              if (_selectedItem != null)
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: ItemCard(
                    title: _selectedItem!.title,
                    timeAgo: _selectedItem!.timeAgo,
                    location: _selectedItem!.displayLocation,
                    userAvatarUrl: '',
                    userName: _selectedItem!.reporterName ?? 'Anonymous',
                    status: _selectedItem!.isLost ? ItemStatus.lost : ItemStatus.found,
                    imageUrl: _selectedItem!.imageUrl,
                  ),
                ),
              
              // Emptystate overlay if no items match query
              if (filtered.isEmpty)
                Center(
                  child: Card(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Text(
                        'No items found on the map.',
                        style: TextStyle(
                          color: context.colors.textLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedItem != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 280), // Above the card if selected
              child: FloatingActionButton(
                heroTag: 'mapCenterBtn',
                onPressed: () {
                  if (_selectedItem != null) {
                    setState(() {
                      _mapCenter = LatLng(_selectedItem!.latitude!, _selectedItem!.longitude!);
                    });
                  }
                },
                backgroundColor: Colors.white,
                child: Icon(Icons.center_focus_strong, color: context.colors.primaryTeal),
              ),
            )
          : null,
    );
  }
}
