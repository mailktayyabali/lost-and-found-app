import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../auth/presentation/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Set default tab to 2 (ITEMS) to match the reference image's active state
  int _currentIndex = 2;

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out from the Admin Panel?', style: TextStyle(color: context.colors.textLight)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.colors.textLight, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.tagLostRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tealColor = context.colors.primaryTeal;
    final cardBg = context.colors.surfaceWhite;
    final bg = context.colors.background;

    final tabs = [
      _DashboardTab(signOut: _signOut),
      _ReportsTab(),
      const _ItemsTab(),
      const _AlertsTab(),
      _ProfileTab(signOut: _signOut),
    ];

    return Scaffold(
      backgroundColor: bg,
      // No side drawer is set (drawer: null) as per requirements
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: tealColor, size: 26),
          tooltip: 'Menu',
          onPressed: () {
            // Static Menu button - no side drawer will be triggered
          },
        ),
        title: Text(
          'Meridian Curator',
          style: TextStyle(
            color: tealColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: tealColor, size: 24),
            tooltip: 'Search',
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: context.colors.dividerColor,
            height: 1,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _buildCustomBottomBar(),
    );
  }

  Widget _buildCustomBottomBar() {
    final activeColor = context.colors.primaryTeal;
    final inactiveColor = context.colors.textLight.withValues(alpha: 0.6);

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: context.colors.dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomBarItem(0, Icons.grid_view_rounded, 'DASHBOARD', activeColor, inactiveColor),
          _buildBottomBarItem(1, Icons.assignment_outlined, 'REPORTS', activeColor, inactiveColor),
          _buildBottomBarItem(2, Icons.stars_rounded, 'ITEMS', activeColor, inactiveColor, isSpecial: true),
          _buildBottomBarItem(3, Icons.notifications_outlined, 'ALERTS', activeColor, inactiveColor),
          _buildBottomBarItem(4, Icons.person_outline_rounded, 'PROFILE', activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor, {
    bool isSpecial = false,
  }) {
    final isSelected = _currentIndex == index;

    if (isSpecial) {
      if (isSelected) {
        // Special premium active capsule styling for the selected 'ITEMS' tab
        return GestureDetector(
          onTap: () => setState(() => _currentIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0EF), // light teal capsule background
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: activeColor, size: 22),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Special inactive standard look
        return GestureDetector(
          onTap: () => setState(() => _currentIndex = index),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: inactiveColor, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: inactiveColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// NEW ITEMS TAB - MATCHING REFERENCE DESIGN
// ==========================================
class _ItemsTab extends StatefulWidget {
  const _ItemsTab();

  @override
  State<_ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<_ItemsTab> {
  String _activeFilter = 'ALL';
  late List<Map<String, dynamic>> _allItems;
  late List<Map<String, dynamic>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _allItems = [
      {
        'id': '1',
        'title': 'Leather Wallet',
        'status': 'FOUND',
        'category': 'ACCESSORIES',
        'location': 'PETS AREA',
        'reporter': 'Testing',
        'reporterAvatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100',
        'date': '2/12/2026',
        'imageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200',
        'description': 'A premium brown leather bi-fold wallet containing multiple store cards, cash receipts, and a small metal token. Found under the benches.',
      },
      {
        'id': '2',
        'title': 'Blue Backpack',
        'status': 'LOST',
        'category': 'TRAVEL',
        'location': 'BAGS',
        'reporter': 'Tayyab Ali',
        'reporterAvatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&q=80&w=100',
        'date': '2/10/2026',
        'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&q=80&w=200',
        'description': 'A standard blue canvas school backpack with yellow zip accents. Contains an empty thermos flask and several notebooks.',
      },
      {
        'id': '3',
        'title': 'Nike Sports Shoe',
        'status': 'LOST',
        'category': 'APPAREL',
        'location': 'FOOTWEAR',
        'reporter': 'Sarah Connor',
        'reporterAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
        'date': '2/08/2026',
        'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=200',
        'description': 'A single red Nike zoom trainer shoe, size US 9. Left behind near the lockers inside gym court B.',
      },
    ];
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      if (_activeFilter == 'ALL') {
        _filteredItems = List.from(_allItems);
      } else {
        _filteredItems = _allItems.where((item) => item['status'] == _activeFilter).toList();
      }
    });
  }

  void _deleteItemConfirm(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Listing',
          style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete this listing for "${item['title']}"? This action cannot be undone.',
          style: TextStyle(color: context.colors.textLight),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.colors.textLight, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.tagLostRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _allItems.removeWhere((x) => x['id'] == item['id']);
                _applyFilter();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item['title']}" has been successfully moderated and deleted.'),
                  backgroundColor: context.colors.tagLostRed,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _viewItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: context.colors.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item['imageUrl'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item['status'] == 'FOUND'
                          ? context.colors.tagFoundGreen.withValues(alpha: 0.1)
                          : context.colors.tagLostRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'],
                      style: TextStyle(
                        color: item['status'] == 'FOUND'
                            ? context.colors.tagFoundGreen
                            : context.colors.tagLostRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    item['date'],
                    style: TextStyle(color: context.colors.textLight, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                item['title'],
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${item['category']}  |  Location: ${item['location']}',
                style: TextStyle(
                  color: context.colors.primaryTeal,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Reporter Information',
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(item['reporterAvatar']),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['reporter'],
                        style: TextStyle(
                          color: context.colors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Verified Community Member',
                        style: TextStyle(
                          color: context.colors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    item['status'] = 'RESOLVED';
                    _applyFilter();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${item['title']}" successfully marked as Resolved.'),
                      backgroundColor: context.colors.tagFoundGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Mark Case as Resolved',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        // Title Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Moderate lost and found listings',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Horizontal filter chips
        _buildFilterChips(),
        const SizedBox(height: 28),

        // Stats Cards Row
        _buildStatsRow(),
        const SizedBox(height: 28),

        // Items Moderation Listing
        if (_filteredItems.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive_outlined, size: 64, color: context.colors.textLight.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  'No listings available in this category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              return _buildListingCard(_filteredItems[index]);
            },
          ),

        // Pagination Footer
        _buildPaginationFooter(_filteredItems.length),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['ALL', 'LOST', 'FOUND', 'RESOLVED'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _activeFilter = filter;
                });
                _applyFilter();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryTeal : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : context.colors.dividerColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : context.colors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'ACTIVE CASES',
              value: '1,284',
              accentColor: context.colors.primaryTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'RESOLVED',
              value: '942',
              accentColor: context.colors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> item) {
    final isFound = item['status'] == 'FOUND';
    final badgeColor = isFound ? context.colors.tagFoundGreen : context.colors.tagLostRed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['imageUrl'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 90,
                      color: context.colors.dividerColor,
                      child: Icon(Icons.image_not_supported_rounded, color: context.colors.textLight),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['category']} • ${item['location']}',
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          item['reporterAvatar'],
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 20,
                            height: 20,
                            color: context.colors.dividerColor,
                            child: Center(
                              child: Text(
                                item['reporter'][0],
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item['reporter'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colors.textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['date'],
                        style: TextStyle(
                          color: context.colors.textLight.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.visibility_rounded, color: context.colors.primaryTeal, size: 20),
                  onPressed: () => _viewItemDetails(item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  splashRadius: 20,
                ),
                IconButton(
                  icon: Icon(Icons.delete_rounded, color: context.colors.tagLostRed, size: 20),
                  onPressed: () => _deleteItemConfirm(item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  splashRadius: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(int totalItems) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page 1 of 1 ($totalItems items)',
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton('PREV', onPressed: null),
              const SizedBox(width: 8),
              _buildPaginationButton('NEXT', onPressed: null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String label, {VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFF1F3F5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isDisabled ? Colors.transparent : context.colors.dividerColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.black26 : context.colors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// NEW SECURITY ALERTS TAB
// ==========================================
class _AlertsTab extends StatelessWidget {
  const _AlertsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Security Alerts',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Track system flags and notifications',
          style: TextStyle(fontSize: 14, color: context.colors.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 24),
        _buildAlertItem(
          context,
          'Flagged Item Report',
          'A user flagged a listing (Leather Wallet) as spam or duplication.',
          '10 mins ago',
          Icons.flag_rounded,
          context.colors.tagLostRed,
        ),
        _buildAlertItem(
          context,
          'New Admin Assigned',
          'Elena Mitchell has been granted primary admin rights by Owner.',
          '2 hours ago',
          Icons.admin_panel_settings_rounded,
          context.colors.primaryTeal,
        ),
        _buildAlertItem(
          context,
          'High Recovery Alert',
          'Found items matching rate exceeded 85% in West Terminal!',
          '1 day ago',
          Icons.trending_up_rounded,
          context.colors.tagFoundGreen,
        ),
      ],
    );
  }

  Widget _buildAlertItem(BuildContext context, String title, String body, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 14)),
                    Text(time, style: TextStyle(color: context.colors.textLight, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(color: context.colors.textLight, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// NEW PROFILE TAB
// ==========================================
class _ProfileTab extends StatelessWidget {
  final VoidCallback signOut;
  const _ProfileTab({required this.signOut});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Admin Profile',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your moderator account settings',
          style: TextStyle(fontSize: 14, color: context.colors.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primaryTeal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Admin Moderator',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textDark),
          ),
        ),
        Center(
          child: Text(
            'Primary Platform Moderator',
            style: TextStyle(fontSize: 13, color: context.colors.textLight, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 32),
        _buildProfileTile(context, 'Account Details', 'Edit username, email, phone', Icons.person_rounded),
        _buildProfileTile(context, 'Moderation Statistics', 'View your actions log and metrics', Icons.analytics_rounded),
        _buildProfileTile(context, 'Privacy & Security', 'Change password, two-factor auth', Icons.shield_rounded),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: signOut,
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          label: const Text('SIGN OUT FROM PANEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.tagLostRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.primaryTeal.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.colors.primaryTeal, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: context.colors.textLight, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textLight),
        onTap: () {},
      ),
    );
  }
}

// ==========================================
// RETAINED ORIGINAL TABS
// ==========================================
class _DashboardTab extends StatelessWidget {
  final VoidCallback signOut;
  const _DashboardTab({required this.signOut});

  @override
  Widget build(BuildContext context) {
    final tealColor = context.colors.primaryTeal;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Inventory Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor regional recovery metrics and statistics.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.podcasts_rounded, color: context.colors.textDark, size: 18),
                label: Text('Broadcast', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.dividerColor.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white, size: 18),
                label: const Text('Export Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tealColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildLeftBorderStatCard(context, 'TOTAL REPORTS', '1,482', '+12%', true),
        _buildLeftBorderStatCard(context, 'ACTIVE USERS', '8,921', '+4.2%', true),
        _buildLeftBorderStatCard(context, 'PENDING VERIFICATIONS', '43', 'Urgent', false, isUrgent: true),
        _buildLeftBorderStatCard(context, 'RETURNED ITEMS', '612', '89% rate', false),
      ],
    );
  }

  Widget _buildLeftBorderStatCard(BuildContext context, String title, String val, String sub, bool isPositive, {bool isUrgent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: context.colors.primaryTeal, width: 4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                val,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.textDark),
              ),
              const SizedBox(width: 8),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUrgent
                      ? context.colors.tagLostRed
                      : (isPositive ? context.colors.tagFoundGreen : context.colors.textLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatefulWidget {
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  String _activeFilter = 'All Reports';

  @override
  Widget build(BuildContext context) {
    final tealColor = context.colors.primaryTeal;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Review & Moderate',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage and review community flagged reports',
          style: TextStyle(fontSize: 14, color: context.colors.textLight, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All Reports', 'Lost', 'Found', 'Pending'].map((filter) {
              final isSelected = _activeFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? tealColor : context.colors.dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : context.colors.textLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          style: TextStyle(color: context.colors.textDark),
          decoration: InputDecoration(
            hintText: 'Search reports...',
            hintStyle: TextStyle(color: context.colors.textLight),
            prefixIcon: Icon(Icons.search, color: context.colors.textLight),
            filled: true,
            fillColor: context.colors.surfaceWhite,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.colors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: tealColor),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildReportVisualCard(
          context,
          'Black Leather Wallet',
          'LOST • TERMINAL 4 LOUNGE',
          'Jonathan Doe',
          'Oct 24, 2025',
          'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=200',
          isNew: true,
          isWarning: true,
        ),
        _buildReportVisualCard(
          context,
          'MacBook Pro 16"',
          'FOUND • KITZBUEHEL SKI RESORT',
          'Alice Smith',
          'Oct 23, 2025',
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=200',
          isNew: false,
          isApprove: false,
        ),
        _buildReportVisualCard(
          context,
          'Gold Digital Watch',
          'LOST • FITNESS CENTER',
          'Mark Kira',
          'Oct 22, 2025',
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=200',
          isNew: false,
          isApprove: true,
          isWatch: true,
        ),
      ],
    );
  }

  Widget _buildReportVisualCard(
    BuildContext context,
    String item,
    String location,
    String reporter,
    String date,
    String imageUrl, {
    required bool isNew,
    bool isWarning = false,
    bool isApprove = true,
    bool isWatch = false,
  }) {
    final tealColor = context.colors.primaryTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (isNew)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: tealColor, borderRadius: BorderRadius.circular(4)),
                    child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textDark),
                      ),
                    ),
                    Icon(
                      isWarning
                          ? Icons.warning_rounded
                          : (isWatch ? Icons.watch_later_outlined : Icons.check_circle_rounded),
                      color: isWarning
                          ? context.colors.tagLostRed
                          : (isWatch ? context.colors.textLight : context.colors.tagFoundGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(location, style: TextStyle(color: context.colors.textLight, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: tealColor.withValues(alpha: 0.1),
                      child: Text(reporter[0], style: TextStyle(color: tealColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(reporter, style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.textDark, fontSize: 12)),
                    const Spacer(),
                    Text('Reported $date', style: TextStyle(color: context.colors.textLight, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isApprove ? 'Approve' : 'Flag for Review',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.dividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(isApprove ? Icons.delete_outline_rounded : Icons.flag_rounded, color: context.colors.textDark),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
