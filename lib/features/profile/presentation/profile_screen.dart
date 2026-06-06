import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../home/presentation/item_details_screen.dart';
import '../../../shared/models/item_model.dart';
import '../../auth/domain/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/widgets/home_drawer.dart';
import '../../reports/data/repositories/firebase_reports_repository.dart';
import '../../messages/presentation/chat_screen.dart';
import '../data/models/review_model.dart';
import '../data/repositories/firebase_reviews_repository.dart';
import 'edit_profile_screen.dart';
import 'widgets/review_card.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _currentUser = _authService.currentUser;
    final currentUid = _currentUser?.uid;
    final targetUid = widget.userId ?? currentUid;

    if (targetUid != null) {
      _userData = await _authService.getUserData(targetUid);
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

    final currentUid = _authService.currentUser?.uid;
    final isOwnProfile = widget.userId == null || widget.userId == currentUid;

    final name = _userData?['name'] ?? _currentUser?.displayName ?? 'User';
    final email = _userData?['email'] ?? _currentUser?.email ?? '';
    final bio = _userData?['bio'] ?? "Helping the community find what's lost. Dedicated to returning precious belongings to their rightful owners.";
    final profileUrl = isOwnProfile
        ? (_currentUser?.photoURL ?? 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200')
        : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200';

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
                      const SizedBox(height: 16),
                      // Profile Image
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.primaryTeal.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundImage: NetworkImage(profileUrl),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: context.colors.primaryTeal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.colors.surfaceWhite, width: 2),
                                ),
                                child: const Icon(Icons.verified, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        name,
                        style: TextStyle(
                          color: context.colors.textDark,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      if (isOwnProfile)
                        Text(
                          email,
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Stats
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingExtraLarge),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(context, _userItems.length.toString(), 'TOTAL REPORTS'),
                            _buildStatColumn(context, _userItems.where((item) => item.status != 'RESOLVED').length.toString(), 'POSTS'),
                            _buildStatColumn(context, _userItems.where((item) => item.status == 'RESOLVED').length.toString(), 'TOTAL CLAIMS'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Bio
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            if (isOwnProfile) ...[
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          initialName: name,
                                          initialBio: bio,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadUserData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.primaryTeal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: context.colors.textDark,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Share Profile',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ] else
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          userName: name,
                                          partnerUid: widget.userId!,
                                          avatarUrl: profileUrl,
                                          isOnline: true,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                                  label: const Text(
                                    'Contact Member',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.primaryTeal,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                _buildActivityGrid(context),
                _buildReviewsList(context),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isOwnProfile ? const HomeBottomNavBar(currentIndex: 4) : null,
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: context.colors.textLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityGrid(BuildContext context) {
    final items = _userItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(color: context.colors.textLight),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLost = item.isLost;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(item: item),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(item.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLost ? context.colors.tagLostRed : context.colors.primaryTeal,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLost ? 'LOST' : 'FOUND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
