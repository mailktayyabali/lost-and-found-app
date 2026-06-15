import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/services/saved_items_service.dart';
import '../../reports/presentation/providers/reports_provider.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/search_category_chips.dart';
import 'widgets/search_location_range.dart';
import 'widgets/search_result_item.dart';
import 'home_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTimePeriod = 'Last 24h';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedCategoryProvider.notifier).state = 'All Items';
    ref.read(searchRadiusProvider.notifier).state = 15.0;
    ref.read(selectedLocationNameProvider.notifier).state = 'New York City, NY';
    ref.read(searchCenterProvider.notifier).state = const LatLng(40.785091, -73.968285);
    _searchController.clear();
    setState(() {
      _selectedTimePeriod = 'Last 24h';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch Riverpod states
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final locationSliderValue = ref.watch(searchRadiusProvider);
    final selectedLocationName = ref.watch(selectedLocationNameProvider);
    final searchCenter = ref.watch(searchCenterProvider);
    final filteredReportsAsync = ref.watch(filteredReportsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.colors.textDark, size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
        ),
        title: Text(
          'Find Items',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reportsListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Search keys, wallets, pets...',
                    hintStyle: TextStyle(
                      color: context.colors.textLight,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.colors.textLight,
                      size: 22,
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceWhite,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.colors.fieldBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.colors.primaryTeal),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(color: context.colors.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 20),

              // Category Section (Modularized)
              SearchCategoryChips(
                selectedCategory: selectedCategory,
                onCategoryChanged: (cat) {
                  ref.read(selectedCategoryProvider.notifier).state = cat;
                },
                onClear: _clearFilters,
              ),
              const SizedBox(height: 24),

              // Time Period Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'TIME PERIOD',
                  style: TextStyle(
                    color: context.colors.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(child: _buildTimeChip('Last 24h')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTimeChip('This Week')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTimeChip('Select Date')),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location Range Section (Modularized)
              SearchLocationRange(
                sliderValue: locationSliderValue,
                onSliderChanged: (value) {
                  ref.read(searchRadiusProvider.notifier).state = value;
                },
                locationName: selectedLocationName,
                center: searchCenter,
                onLocationChanged: (point, address) {
                  ref.read(searchCenterProvider.notifier).state = point;
                  ref.read(selectedLocationNameProvider.notifier).state = address;
                },
                onMapTap: () {},
              ),
              const SizedBox(height: 24),
              Divider(color: context.colors.dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 16),

              // Results Header & List
              filteredReportsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text('Error loading items: $err', style: const TextStyle(color: Colors.red)),
                ),
                data: (filteredItems) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Found ${filteredItems.length} Results',
                              style: TextStyle(
                                color: context.colors.textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.swap_vert, color: context.colors.textDark, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Sort by: Recent',
                                  style: TextStyle(
                                    color: context.colors.textDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListenableBuilder(
                        listenable: SavedItemsService(),
                        builder: (context, _) {
                          if (filteredItems.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.search_off, size: 64, color: context.colors.textLight.withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No items match your search',
                                      style: TextStyle(color: context.colors.textLight, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: filteredItems.map((item) => SearchResultItem(
                              item: item,
                              onBookmarkToggled: () => setState(() {}),
                            )).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTimeChip(String label) {
    final isSelected = _selectedTimePeriod == label;
    Color bgColor = isSelected ? context.colors.primaryTeal : context.colors.surfaceWhite;
    Color textColor = isSelected ? Colors.white : context.colors.textDark;
    Color borderColor = isSelected ? context.colors.primaryTeal : context.colors.fieldBorder;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTimePeriod = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
