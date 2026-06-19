import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/domain/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../../reports/data/repositories/firebase_reports_repository.dart';
import '../data/models/review_model.dart';
import '../data/repositories/firebase_reviews_repository.dart';
import 'widgets/review_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_actions.dart';
import 'widgets/activity_grid.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({
    super.key,
    this.userId,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Item> _userItems = [];
  List<Review> _reviews = [];
  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = false;
      });
    }
    _currentUser = _authService.currentUser;
    final currentUid = _currentUser?.uid;
    final targetUid = widget.userId ?? currentUid;

    if (targetUid != null) {
      final userData = await _authService.getUserData(targetUid);
      if (userData == null) {
        if (mounted) {
          setState(() {
            _userData = null;
            _loadError = true;
            _isLoading = false;
          });
        }
        return;
      }

      _userData = userData;
      final allItems = await FirebaseReportsRepository().getItems();
      
      // Filter items created by the target user
      _userItems = allItems.where((item) => item.createdBy == targetUid).toList();

      // Fetch reviews
      try {
        _reviews = await FirebaseReviewsRepository().getReviews(targetUid);
      } catch (e) {
        debugPrint('ProfileScreen: Error loading reviews: $e');
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.colors.surfaceWhite,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError) {
      return Scaffold(
        backgroundColor: context.colors.surfaceWhite,
        appBar: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.colors.textDark),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Error',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load user profile.',
                style: TextStyle(color: context.colors.textLight, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final currentUid = _authService.currentUser?.uid;
    final isOwnProfile = widget.userId == null || widget.userId == currentUid;
    final profileUid = widget.userId ?? currentUid;

    final name = _userData?['name'] ?? _currentUser?.displayName ?? 'User';
    final email = _userData?['email'] ?? _currentUser?.email ?? '';
    final bio = _userData?['bio'] ?? "Helping the community find what's lost. Dedicated to returning precious belongings to their rightful owners.";
    const fallbackUrl = 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200';
    final profileUrl = isOwnProfile
        ? (_currentUser?.photoURL ?? fallbackUrl)
        : ((_userData?['photoURL'] as String?) ?? fallbackUrl);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.surfaceWhite,
        drawer: isOwnProfile ? const HomeDrawer() : null,
        appBar: AppBar(
          backgroundColor: context.colors.surfaceWhite,
          elevation: 0,
          leading: isOwnProfile
              ? Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: context.colors.textDark),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.arrow_back, color: context.colors.textDark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
          centerTitle: true,
          title: Text(
            isOwnProfile ? 'My Profile' : 'Member Profile',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: isOwnProfile
              ? [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await _authService.signOut();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ]
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: _loadUserData,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileHeader(
                        name: name,
                        email: email,
                        bio: bio,
                        profileUrl: profileUrl,
                        isOwnProfile: isOwnProfile,
                        totalReportsCount: _userItems.length,
                        postsCount: _userItems.where((item) => item.status != 'RESOLVED').length,
                        claimsCount: _userItems.where((item) => item.status == 'RESOLVED').length,
                      ),
                      const SizedBox(height: 24),
                      ProfileActions(
                        isOwnProfile: isOwnProfile,
                        name: name,
                        bio: bio,
                        profileUid: profileUid,
                        profileUrl: profileUrl,
                        userId: widget.userId,
                        onProfileUpdated: _loadUserData,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: context.colors.primaryTeal,
                      indicatorWeight: 3,
                      labelColor: context.colors.primaryTeal,
                      unselectedLabelColor: context.colors.textLight,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.grid_view, size: 18),
                              SizedBox(width: 8),
                              Text('ACTIVITY'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star_border, size: 18),
                              SizedBox(width: 8),
                              Text('REVIEWS'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    context.colors.surfaceWhite,
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                ActivityGrid(userItems: _userItems),
                _buildReviewsList(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isOwnProfile ? const HomeBottomNavBar(currentIndex: 4) : null,
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context) {
    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(color: context.colors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(review: _reviews[index]);
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this._color);

  final TabBar _tabBar;
  final Color _color;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: _color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
