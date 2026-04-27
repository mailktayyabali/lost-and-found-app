import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/post_item_card.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'My Posts',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppColors.buttonBlue,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.buttonBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(text: 'My Lost Items'),
              Tab(text: 'My Found Items'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // My Lost Items Tab
            _LostItemsList(),
            
            // My Found Items Tab (Placeholder for now)
            Center(
              child: Text(
                'No found items yet.',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.buttonBlue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _LostItemsList extends StatelessWidget {
  const _LostItemsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 80), // Padding for FAB
      children: const [
        PostItemCard(
          title: 'Golden Retriever',
          dateStr: 'Lost on Oct 12, 2023',
          location: 'Central Park, NYC',
          imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=200',
        ),
        PostItemCard(
          title: 'Black Leather Wallet',
          dateStr: 'Lost on Sep 28, 2023',
          location: 'Subway Station L',
          imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200',
        ),
        PostItemCard(
          title: 'Car Keys',
          dateStr: 'Lost on Aug 15, 2023',
          location: '',
          imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?auto=format&fit=crop&q=80&w=200',
          isRecovered: true,
        ),
      ],
    );
  }
}
