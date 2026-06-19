import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_field.dart';
import 'widgets/category_list.dart';
import 'widgets/section_header.dart';
import 'widgets/recent_items_list.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const HomeAppBar(),
      drawer: const HomeDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const SearchField(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Categories',
              actionText: 'See All',
              onActionTap: () {},
            ),
            const SizedBox(height: 16),
            CategoryList(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
            const SizedBox(height: 24),
            RecentItemsList(selectedCategory: _selectedCategory),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}


