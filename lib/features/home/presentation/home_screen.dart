import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/search_field.dart';
import 'widgets/category_list.dart';
import 'widgets/section_header.dart';
import 'widgets/recent_items_list.dart';
import 'widgets/home_bottom_nav_bar.dart';
import 'widgets/home_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            const CategoryList(),
            const SizedBox(height: 24),
            const RecentItemsList(),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}


