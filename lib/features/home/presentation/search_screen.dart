import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import 'item_details_screen.dart';
import 'widgets/home_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double _locationSliderValue = 15.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Find Items',
          style: TextStyle(
            color: AppColors.textDark,
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
                decoration: InputDecoration(
                  hintText: 'Search keys, wallets, pets...',
                  hintStyle: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textLight,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.fieldBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryTeal),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.dividerColor, thickness: 1, height: 1),
            const SizedBox(height: 20),

            // Category Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildChip('All Items', isSelected: true),
                  _buildChip('Electronics'),
                  _buildChip('Pets'),
                  _buildChip('Documents'),
                  _buildChip('Keys'),
                  _buildChip('Wallets'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Time Period Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'TIME PERIOD',
                style: TextStyle(
                  color: AppColors.textLight,
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
                  Expanded(child: _buildChip('Last 24h', isExpanded: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChip('This Week', isSelectedState2: true, isExpanded: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildChip('Select Date', isExpanded: true)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Location Range Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LOCATION RANGE',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${_locationSliderValue.toInt()} km',
                      style: const TextStyle(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.fieldBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.textLight, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'New York City, NY',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primaryTeal,
                        inactiveTrackColor: AppColors.fieldBorder,
                        thumbColor: AppColors.primaryTeal,
                        overlayColor: AppColors.primaryTeal.withValues(alpha: 0.2),
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
            const SizedBox(height: 24),
            const Divider(color: AppColors.dividerColor, thickness: 1, height: 1),
            const SizedBox(height: 16),

            // Results Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Found 24 Results',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.swap_vert, color: AppColors.textDark, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Sort by: Recent',
                        style: TextStyle(
                          color: AppColors.textDark,
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
            ListenableBuilder(
              listenable: SavedItemsService(),
              builder: (context, _) {
                return Column(
                  children: [
                    _buildResultItem(
                      item: Item(
                        id: '1',
                        title: 'Gold Rolex Watch',
                        isLost: true,
                        timeAgo: '2h ago',
                        location: 'Central Park, NY',
                        description: 'Found a gold rolex watch near the fountain.',
                        imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&q=80&w=200',
                        category: 'Electronics',
                      ),
                    ),
                    _buildResultItem(
                      item: Item(
                        id: '2',
                        title: 'Friendly Golden Retriever',
                        isLost: false,
                        timeAgo: '5h ago',
                        location: 'Brooklyn, NY',
                        description: 'Found a friendly golden retriever near the park.',
                        imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=200',
                        category: 'Pets',
                      ),
                    ),
                    _buildResultItem(
                      item: Item(
                        id: '3',
                        title: 'Brown Leather Wallet',
                        isLost: true,
                        timeAgo: '1d ago',
                        location: 'Grand Central Terminal',
                        description: 'Lost a brown leather wallet near the station.',
                        imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200',
                        category: 'Wallets',
                      ),
                    ),
                  ],
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

  Widget _buildChip(String label, {bool isSelected = false, bool isSelectedState2 = false, bool isExpanded = false}) {
    Color bgColor = AppColors.surfaceWhite;
    Color textColor = AppColors.textDark;
    Color borderColor = AppColors.fieldBorder;

    if (isSelected) {
      bgColor = AppColors.primaryTeal;
      textColor = Colors.white;
      borderColor = AppColors.primaryTeal;
    } else if (isSelectedState2) {
      bgColor = AppColors.primaryTeal.withValues(alpha: 0.1);
      textColor = AppColors.primaryTeal;
      borderColor = AppColors.primaryTeal.withValues(alpha: 0.2);
    }

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    final badgeColor = item.isLost ? AppColors.tagLostRed.withValues(alpha: 0.15) : AppColors.tagFoundGreen.withValues(alpha: 0.15);
    final badgeTextColor = item.isLost ? AppColors.tagLostRed : AppColors.tagFoundGreen;
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
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
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
                  color: AppColors.iconBackground,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.textLight, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: const TextStyle(
                          color: AppColors.textLight,
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
          const SizedBox(width: 12),
          // Bookmark Icon
          GestureDetector(
            onTap: () {
              SavedItemsService().toggleSave(item);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.primaryTeal : AppColors.textLight,
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
