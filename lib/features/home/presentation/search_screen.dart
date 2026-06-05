import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import '../../reports/data/repositories/firebase_reports_repository.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/search_category_chips.dart';
import 'widgets/search_location_range.dart';
import 'widgets/search_result_item.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseReportsRepository _reportsRepository = FirebaseReportsRepository();
  final TextEditingController _searchController = TextEditingController();
  
  double _locationSliderValue = 15.0;
  String _searchQuery = '';
  String _selectedCategory = 'All Items';
  String _selectedTimePeriod = 'Last 24h';
  String _selectedLocationName = 'New York City, NY';

  List<Item> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final list = await _reportsRepository.getItems();
      if (mounted) {
        setState(() {
          _allItems = list;
        });
      }
    } catch (e) {
      debugPrint('SearchScreen: Error loading items: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Item> get _filteredItems {
    return _allItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Items' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All Items';
      _selectedTimePeriod = 'Last 24h';
      _locationSliderValue = 15.0;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
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
                  setState(() {
                    _searchQuery = value;
                  });
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
              selectedCategory: _selectedCategory,
              onCategoryChanged: (cat) {
                setState(() => _selectedCategory = cat);
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
              sliderValue: _locationSliderValue,
              onSliderChanged: (value) {
                setState(() => _locationSliderValue = value);
              },
              locationName: _selectedLocationName,
              onMapTap: () {
                setState(() => _selectedLocationName = 'Mock Pin Location');
              },
            ),
            const SizedBox(height: 24),
            Divider(color: context.colors.dividerColor, thickness: 1, height: 1),
            const SizedBox(height: 16),

            // Results Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Found ${_filteredItems.length} Results',
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

            // List of Items
            _isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ))
                : ListenableBuilder(
                    listenable: SavedItemsService(),
                    builder: (context, _) {
                      final filtered = _filteredItems;
                      if (filtered.isEmpty) {
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
                        children: filtered.map((item) => SearchResultItem(
                          item: item,
                          onBookmarkToggled: () => setState(() {}),
                        )).toList(),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
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
