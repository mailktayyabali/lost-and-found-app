import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import '../../shared/presentation/widgets/mock_map_widget.dart';
import 'item_details_screen.dart';
import 'widgets/home_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _locationSliderValue = 15.0;
  String _searchQuery = '';
  String _selectedCategory = 'All Items';
  String _selectedTimePeriod = 'Last 24h';
  String _selectedLocationName = 'New York City, NY';

  final List<Item> _allItems = [
    Item(
      id: '1',
      title: 'Gold Rolex Watch',
      isLost: true,
      timeAgo: '2h ago',
      location: 'Central Park, NY',
      description: 'Found a gold rolex watch near the fountain.',
      imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&q=80&w=200',
      category: 'Electronics',
    ),
    Item(
      id: '2',
      title: 'Friendly Golden Retriever',
      isLost: false,
      timeAgo: '5h ago',
      location: 'Brooklyn, NY',
      description: 'Found a friendly golden retriever near the park.',
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=200',
      category: 'Pets',
    ),
    Item(
      id: '3',
      title: 'Brown Leather Wallet',
      isLost: true,
      timeAgo: '1d ago',
      location: 'Grand Central Terminal',
      description: 'Lost a brown leather wallet near the station.',
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200',
      category: 'Wallets',
    ),
    Item(
      id: '4',
      title: 'iPhone 13 Pro - Blue',
      isLost: true,
      timeAgo: '3h ago',
      location: 'Times Square, NY',
      description: 'Lost my blue iPhone 13 Pro in Times Square.',
      imageUrl: 'https://images.unsplash.com/photo-1633114128174-2f8aa49759b0?auto=format&fit=crop&q=80&w=200',
      category: 'Electronics',
    ),
    Item(
      id: '5',
      title: 'Keys with Red Keychain',
      isLost: false,
      timeAgo: '1h ago',
      location: 'Chelsea Market',
      description: 'Found a set of keys with a red keychain.',
      imageUrl: 'https://images.unsplash.com/photo-1619183495208-0f04e137286a?auto=format&fit=crop&q=80&w=200',
      category: 'Keys',
    ),
    Item(
      id: '6',
      title: 'Blue Passport Cover',
      isLost: false,
      timeAgo: '4h ago',
      location: 'JFK Airport Terminal 4',
      description: 'Found a blue passport cover near the gate.',
      imageUrl: 'https://images.unsplash.com/photo-1544027993-37dbfe43562a?auto=format&fit=crop&q=80&w=200',
      category: 'Documents',
    ),
  ];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            Navigator.pop(context);
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
            SizedBox(height: 8),
            // Search Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
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
            SizedBox(height: 20),
            Divider(color: context.colors.dividerColor, thickness: 1, height: 1),
            SizedBox(height: 20),

            // Category Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CATEGORY',
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: context.colors.primaryTeal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildChip('All Items', isSelected: _selectedCategory == 'All Items', onTap: () {
                    setState(() => _selectedCategory = 'All Items');
                  }),
                  _buildChip('Electronics', isSelected: _selectedCategory == 'Electronics', onTap: () {
                    setState(() => _selectedCategory = 'Electronics');
                  }),
                  _buildChip('Pets', isSelected: _selectedCategory == 'Pets', onTap: () {
                    setState(() => _selectedCategory = 'Pets');
                  }),
                  _buildChip('Documents', isSelected: _selectedCategory == 'Documents', onTap: () {
                    setState(() => _selectedCategory = 'Documents');
                  }),
                  _buildChip('Keys', isSelected: _selectedCategory == 'Keys', onTap: () {
                    setState(() => _selectedCategory = 'Keys');
                  }),
                  _buildChip('Wallets', isSelected: _selectedCategory == 'Wallets', onTap: () {
                    setState(() => _selectedCategory = 'Wallets');
                  }),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Time Period Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
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
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(child: _buildChip('Last 24h', isSelected: _selectedTimePeriod == 'Last 24h', isExpanded: true, onTap: () {
                    setState(() => _selectedTimePeriod = 'Last 24h');
                  })),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('This Week', isSelected: _selectedTimePeriod == 'This Week', isExpanded: true, onTap: () {
                    setState(() => _selectedTimePeriod = 'This Week');
                  })),
                  SizedBox(width: 8),
                  Expanded(child: _buildChip('Select Date', isSelected: _selectedTimePeriod == 'Select Date', isExpanded: true, onTap: () {
                    setState(() => _selectedTimePeriod = 'Select Date');
                  })),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Location Range Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOCATION RANGE',
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_locationSliderValue.toInt()} km',
                      style: TextStyle(
                        color: context.colors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.fieldBorder),
                ),
                child: Column(
                  children: [
                    MockMapWidget(
                      height: 120,
                      locationName: _selectedLocationName,
                      onTap: () {
                        setState(() {
                          _selectedLocationName = 'Mock Pin Location';
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: context.colors.textLight, size: 20),
                        SizedBox(width: 8),
                        Text(
                          _selectedLocationName,
                          style: TextStyle(
                            color: context.colors.textDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: context.colors.primaryTeal,
                        inactiveTrackColor: context.colors.fieldBorder,
                        thumbColor: context.colors.primaryTeal,
                        overlayColor: context.colors.primaryTeal.withValues(alpha: 0.2),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                      ),
                      child: Slider(
                        value: _locationSliderValue,
                        min: 1,
                        max: 50,
                        onChanged: (value) {
                          setState(() {
                            _locationSliderValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Divider(color: context.colors.dividerColor, thickness: 1, height: 1),
            SizedBox(height: 16),

            // Results Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                      SizedBox(width: 4),
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
            SizedBox(height: 16),

            // List of Items
            ListenableBuilder(
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
                          SizedBox(height: 16),
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
                  children: filtered.map((item) => _buildResultItem(item: item)).toList(),
                );
              },
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false, bool isExpanded = false, VoidCallback? onTap}) {
    Color bgColor = context.colors.surfaceWhite;
    Color textColor = context.colors.textDark;
    Color borderColor = context.colors.fieldBorder;

    if (isSelected) {
      bgColor = context.colors.primaryTeal;
      textColor = Colors.white;
      borderColor = context.colors.primaryTeal;
    }

    Widget chip = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

    if (isExpanded) {
      return chip;
    }

    return chip;
  }

  Widget _buildResultItem({
    required Item item,
  }) {
    final isSaved = SavedItemsService().isSaved(item.id);
    final badgeColor = item.isLost ? context.colors.tagLostRed.withValues(alpha: 0.15) : context.colors.tagFoundGreen.withValues(alpha: 0.15);
    final badgeTextColor = item.isLost ? context.colors.tagLostRed : context.colors.tagFoundGreen;
    final badgeText = item.isLost ? 'LOST' : 'FOUND';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(item: item),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: context.colors.iconBackground,
                );
              },
            ),
          ),
          SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      item.timeAgo,
                      style: TextStyle(
                        color: context.colors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  item.title,
                  style: TextStyle(
                    color: context.colors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: context.colors.textLight, size: 14),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: TextStyle(
                          color: context.colors.textLight,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Bookmark Icon
          GestureDetector(
            onTap: () {
              SavedItemsService().toggleSave(item);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? context.colors.primaryTeal : context.colors.textLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
