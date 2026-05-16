import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import 'widgets/post_item_card.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'My Posts',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: context.colors.buttonBlue,
            unselectedLabelColor: context.colors.textLight,
            indicatorColor: context.colors.buttonBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(text: 'My Lost Items'),
              Tab(text: 'My Found Items'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Lost Items Tab
            _LostItemsList(),
            
            // My Found Items Tab (Placeholder for now)
            Center(
              child: Text(
                'No found items yet.',
                style: TextStyle(color: context.colors.textLight),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: context.colors.buttonBlue,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _LostItemsList extends StatefulWidget {
  const _LostItemsList();

  @override
  State<_LostItemsList> createState() => _LostItemsListState();
}

class _LostItemsListState extends State<_LostItemsList> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 80, left: 20, right: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: ShimmerLoader(width: double.infinity, height: 120, borderRadius: 16),
          );
        },
      );
    }

    return ListView(
      padding: EdgeInsets.only(top: 16, bottom: 80), // Padding for FAB
      children: [
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
