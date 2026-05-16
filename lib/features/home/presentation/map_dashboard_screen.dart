import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/presentation/widgets/mock_map_widget.dart';
import 'widgets/item_card.dart';

class MapDashboardScreen extends StatefulWidget {
  const MapDashboardScreen({super.key});

  @override
  State<MapDashboardScreen> createState() => _MapDashboardScreenState();
}

class _MapDashboardScreenState extends State<MapDashboardScreen> {
  String _selectedLocation = 'Nearby Items';

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.filter_list, color: context.colors.textDark),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filters coming soon')),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Full screen mock map
          Positioned.fill(
            child: MockMapWidget(
              height: double.infinity,
              locationName: _selectedLocation,
              onTap: () {
                setState(() {
                  _selectedLocation = 'Tapped location point';
                });
              },
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
                decoration: InputDecoration(
                  hintText: 'Search this area...',
                  hintStyle: TextStyle(color: context.colors.textLight),
                  prefixIcon: Icon(Icons.search, color: context.colors.primaryTeal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),

          // Bottom card overlay for selected item
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: const ItemCard(
              title: 'Sony WH-1000XM4 Headphones',
              timeAgo: '2m ago',
              location: 'Central Park Mall, Food Court',
              userAvatarUrl: '',
              userName: 'JD',
              status: ItemStatus.found,
              imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=400',
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 280), // Above the card
        child: FloatingActionButton(
          heroTag: 'mapLocationBtn',
          onPressed: () {
            setState(() {
              _selectedLocation = 'My Current Location';
            });
          },
          backgroundColor: Colors.white,
          child: Icon(Icons.my_location, color: context.colors.primaryTeal),
        ),
      ),
    );
  }
}
