import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/domain/auth_service.dart';
import '../../home/presentation/item_details_screen.dart';
import '../../reports/data/repositories/firebase_reports_repository.dart';
import 'widgets/post_item_card.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  List<Item> _userItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _currentUser = _authService.currentUser;
    try {
      if (_currentUser != null) {
        final allItems = await FirebaseReportsRepository().getItems();
        _userItems = allItems.where((item) =>
          item.createdBy == _currentUser!.uid ||
          (item.reporterEmail != null &&
              item.reporterEmail!.toLowerCase() == _currentUser!.email?.toLowerCase())
        ).toList();
      }
    } catch (e) {
      debugPrint('MyPostsScreen: Error loading posts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reports: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePost(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final themeColors = context.colors;
    await FirebaseReportsRepository().deleteReport(id);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Post deleted successfully'),
        backgroundColor: themeColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _loadUserPosts();
  }

  Future<void> _markRecovered(String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final themeColors = context.colors;
    await FirebaseReportsRepository().updateItemStatus(id, 'RESOLVED');
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Item marked as recovered!'),
        backgroundColor: themeColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _loadUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    final lostItems = _userItems.where((item) => item.isLost).toList();
    final foundItems = _userItems.where((item) => !item.isLost).toList();

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
            labelColor: context.colors.primaryTeal,
            unselectedLabelColor: context.colors.textLight,
            indicatorColor: context.colors.primaryTeal,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: const [
              Tab(text: 'My Lost Items'),
              Tab(text: 'My Found Items'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsList(lostItems),
            _buildItemsList(foundItems),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List<Item> items) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No posts in this category yet.',
              style: TextStyle(color: context.colors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PostItemCard(
          item: item,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(item: item),
              ),
            );
            _loadUserPosts();
          },
          onDelete: () => _deletePost(item.id),
          onRecovered: () => _markRecovered(item.id),
        );
      },
    );
  }
}
