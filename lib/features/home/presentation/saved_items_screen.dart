import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../../shared/services/saved_items_service.dart';
import 'item_details_screen.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/home_drawer.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All Items', 'Lost', 'Found', 'Pets', 'Accessories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: context.colors.textDark),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          'Saved Items',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: context.colors.primaryTeal),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: Column(
        children: [
          SizedBox(height: 16),
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.primaryTeal : context.colors.surfaceWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? context.colors.primaryTeal : context.colors.fieldBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.colors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24),
          // Saved Items List
          Expanded(
            child: ListenableBuilder(
              listenable: SavedItemsService(),
              builder: (context, _) {
                final allSavedItems = SavedItemsService().savedItems;
                final filteredItems = allSavedItems.where((item) {
                  if (_selectedCategoryIndex == 0) return true; // All Items
                  final category = _categories[_selectedCategoryIndex];
                  if (category == 'Lost') return item.isLost;
                  if (category == 'Found') return !item.isLost;
                  return item.category == category;
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 64, color: context.colors.textLight.withValues(alpha: 0.5)),
                        SizedBox(height: 16),
                        Text(
                          'No saved items yet',
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 24),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _buildSavedItemCard(item: item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavBar(currentIndex: 0), // Adjust currentIndex based on where this fits, but since it's not a tab, maybe don't highlight any or keep home
    );
  }

  Widget _buildSavedItemCard({
    required Item item,
  }) {
    final badgeColor = item.isLost ? context.colors.tagLostRed.withValues(alpha: 0.15) : context.colors.tagFoundGreen.withValues(alpha: 0.15);
    final badgeTextColor = item.isLost ? context.colors.tagLostRed : context.colors.tagFoundGreen;
    final badgeText = item.isLost ? 'LOST' : 'FOUND';
    final actionText = item.isLost ? 'VIEW DETAILS' : 'CLAIM ITEM';
    final isFilledAction = !item.isLost;

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
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.fieldBorder),
          boxShadow: [
            BoxShadow(
              color: context.colors.textDark.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  item.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      width: double.infinity,
                      color: context.colors.iconBackground,
                    );
                  },
                ),
              ),
              // Top Left Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Top Right Bookmark Icon (to remove)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    SavedItemsService().toggleSave(item);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: context.colors.textDark.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: context.colors.surfaceWhite,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Details Section
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: context.colors.textLight, size: 14),
                        SizedBox(width: 4),
                        Text(
                          item.displayLocation,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textLight,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 20),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFilledAction ? context.colors.primaryTeal : Colors.transparent,
                      foregroundColor: isFilledAction ? Colors.white : context.colors.primaryTeal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isFilledAction 
                            ? BorderSide.none 
                            : BorderSide(color: context.colors.primaryTeal, width: 1.5),
                      ),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
