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
  int _currentIndex = 0;

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        title: Text('Sign Out', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out from the Admin Panel?', style: TextStyle(color: context.colors.textLight)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.colors.textLight)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.tagLostRed),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
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
    final textLight = context.colors.textLight;
    final cardBg = context.colors.surfaceWhite;
    final bg = context.colors.background;

    final tabs = [
      _DashboardTab(signOut: _signOut),
      _UsersTab(),
      _ReportsTab(),
      _StatsTab(),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          tooltip: 'Sign Out',
          onPressed: _signOut,
        ),
        title: Text(
          'Precision Curator',
          style: TextStyle(
            color: tealColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.dividerColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: cardBg,
          selectedItemColor: tealColor,
          unselectedItemColor: textLight.withValues(alpha: 0.6),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded),
              label: 'USERS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'REPORTS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'STATS',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. DASHBOARD TAB
// ==========================================
class _DashboardTab extends StatelessWidget {
  final VoidCallback signOut;
  const _DashboardTab({required this.signOut});

  @override
  Widget build(BuildContext context) {
    final tealColor = context.colors.primaryTeal;
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Inventory Overview',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: context.colors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor regional recovery metrics and user verification workflows with curated precision.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textLight,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        // Broadcast / Export Buttons
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
        // Stat Cards List
        _buildLeftBorderStatCard(context, 'TOTAL REPORTS', '1,482', '+12%', true),
        _buildLeftBorderStatCard(context, 'ACTIVE USERS', '8,921', '+4.2%', true),
        _buildLeftBorderStatCard(context, 'PENDING VERIFICATIONS', '43', 'Urgent', false, isUrgent: true),
        _buildLeftBorderStatCard(context, 'RETURNED ITEMS', '612', '89% rate', false),
        const SizedBox(height: 28),
        // Recent Activity Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textDark),
            ),
            TextButton(
              onPressed: () {},
              child: Text('View All', style: TextStyle(color: tealColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRecentActivityTable(context),
        const SizedBox(height: 28),
        // Hotspots Section
        Text(
          'HOTSPOTS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.colors.textLight, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        _buildHotspotsCard(context),
        const SizedBox(height: 24),
        // Promo Banner
        _buildPromoBanner(context),
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

  Widget _buildRecentActivityTable(BuildContext context) {
    final headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.dividerColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ITEM', style: headerStyle),
                Text('REPORTER', style: headerStyle),
              ],
            ),
          ),
          // List Items
          _buildActivityRow(context, 'Apple Watch Series 8', 'Lost in Central Park', 'Julian Vance', Icons.watch_rounded),
          _buildActivityRow(context, 'Tesla Key Fob', 'Found at Library Cafe', 'Sarah Jenkins', Icons.directions_car_rounded),
          _buildActivityRow(context, 'Leather Wallet', 'Lost at West Station', 'Mike Donahue', Icons.account_balance_wallet_rounded),
          _buildActivityRow(context, 'MacBook Air M2', 'Found in Hallway B', 'Admin System', Icons.laptop_chromebook_rounded),
        ],
      ),
    );
  }

  Widget _buildActivityRow(BuildContext context, String item, String subtitle, String reporter, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primaryTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: context.colors.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: context.colors.textLight, fontSize: 11)),
              ],
            ),
          ),
          Text(reporter, style: TextStyle(color: context.colors.textLight, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildHotspotsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        children: [
          // Map Placeholder Visual
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.colors.dividerColor),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Minimal blueprint grids
                Opacity(
                  opacity: 0.1,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
                    itemCount: 24,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.textDark),
                      ),
                    ),
                  ),
                ),
                // Center location pulse
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: context.colors.primaryTeal.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Hotspot progress bars
          _buildProgressHotspot(context, 'Downtown Hub', '42 Reports', 0.7),
          const SizedBox(height: 12),
          _buildProgressHotspot(context, 'East Terminal', '18 Reports', 0.3),
        ],
      ),
    );
  }

  Widget _buildProgressHotspot(BuildContext context, String name, String count, double percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 13)),
            Text(count, style: TextStyle(color: context.colors.textLight, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: context.colors.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primaryTeal),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primaryTeal, context.colors.primaryTeal.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Verification AI',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Our latest model improves facial recognition for lost ID cards by 24%.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.colors.primaryTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('LEARN MORE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.shield_rounded, color: Colors.white.withValues(alpha: 0.2), size: 80),
        ],
      ),
    );
  }
}

// ==========================================
// 2. USERS TAB
// ==========================================
class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tealColor = context.colors.primaryTeal;
    return Scaffold(
      backgroundColor: context.colors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: tealColor,
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('New Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text(
            'Directory Management',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage global user accounts and permission states.',
            style: TextStyle(fontSize: 14, color: context.colors.textLight),
          ),
          const SizedBox(height: 20),
          // Search Input
          TextField(
            style: TextStyle(color: context.colors.textDark),
            decoration: InputDecoration(
              hintText: 'Search by name, email or role...',
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
          // Metrics Row
          _buildUsersMetric(context, 'TOTAL ACCOUNTS', '12,482', '+12% from last month', Icons.trending_up_rounded),
          _buildUsersMetric(context, 'ACTIVE NOW', '842', 'Real-time session monitoring', Icons.bolt_rounded),
          _buildUsersMetric(context, 'PENDING ROLES', '18', 'Requires immediate review', Icons.notifications_rounded, isWarning: true),
          const SizedBox(height: 28),
          // User Profile List
          _buildUsersDirectoryTable(context),
          const SizedBox(height: 80), // extra padding for FAB
        ],
      ),
    );
  }

  Widget _buildUsersMetric(BuildContext context, String title, String val, String sub, IconData icon, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Text(val, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 16, color: isWarning ? context.colors.tagLostRed : context.colors.primaryTeal),
              const SizedBox(width: 6),
              Text(sub, style: TextStyle(fontSize: 12, color: context.colors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersDirectoryTable(BuildContext context) {
    final headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.dividerColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('USER PROFILE', style: headerStyle),
                Text('ROLE', style: headerStyle),
              ],
            ),
          ),
          _buildUserRow(context, 'Elena Mitchell', 'elena.m@curator.io', 'ADMIN', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=100'),
          _buildUserRow(context, 'Julian Hayes', 'j.hayes@curator.io', 'USER', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100'),
          _buildUserRow(context, 'Sarah Reed', 'reed.s@curator.io', 'USER', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100'),
          _buildUserRow(context, 'Kevin Lowery', 'k.lowery@curator.io', 'USER', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=100'),
          // Pagination Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Showing 1 to 4 of 12,482 users', style: TextStyle(color: context.colors.textLight, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: Text('Previous', style: TextStyle(color: context.colors.textDark)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Next Page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildUserRow(BuildContext context, String name, String email, String role, String avatarUrl) {
    final isAdmin = role == 'ADMIN';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(email, style: TextStyle(color: context.colors.textLight, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? context.colors.primaryTeal.withValues(alpha: 0.1) : context.colors.dividerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isAdmin ? context.colors.primaryTeal : context.colors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. REPORTS TAB
// ==========================================
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
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Review & Moderate',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage lost and found reports with surgical precision. Review items, verify flags, and maintain community integrity.',
          style: TextStyle(fontSize: 14, color: context.colors.textLight, height: 1.4),
        ),
        const SizedBox(height: 20),
        // Filters chips row
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
        // Search
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
        // Card List
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
        _buildReportVisualCard(
          context,
          'Red Running Shoes',
          'FOUND • CENTRAL PARK NORTH',
          'Gareth Lee',
          'Oct 24, 2025',
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=200',
          isNew: true,
          isApprove: true,
        ),
        // Manual Entry Dotted Border Card
        _buildDottedManualCard(context),
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
          // Image block
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

  Widget _buildDottedManualCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.textLight.withValues(alpha: 0.3),
          style: BorderStyle.solid, // solid representation in default styling
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: context.colors.textDark, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            'Manual Report',
            style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Manually insert a report if received\nvia physical counter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.colors.textLight, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.primaryTeal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Create Entry', style: TextStyle(color: context.colors.primaryTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. STATS TAB
// ==========================================
class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Performance Analytics',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          'Real-time operational efficiency and data curation metrics.',
          style: TextStyle(fontSize: 14, color: context.colors.textLight),
        ),
        const SizedBox(height: 24),
        // Metrics Stack
        _buildStatsMetric(context, 'TOTAL ITEMS LOGGED', '128,492', '+12.5%'),
        _buildStatsMetric(context, 'ACTIVE RETURNS', '3,841', '-2.4%', isNegative: true),
        _buildStatsMetric(context, 'RECOVERY TIME', '42m', 'Optimal', isGreenChip: true),
        const SizedBox(height: 28),
        // Bar Chart Section
        _buildBarChartSection(context),
        const SizedBox(height: 28),
        // Donut Chart Section
        _buildDonutChartSection(context),
        const SizedBox(height: 28),
        // Regions Table
        _buildRegionsTable(context),
      ],
    );
  }

  Widget _buildStatsMetric(BuildContext context, String title, String val, String chipText, {bool isNegative = false, bool isGreenChip = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: context.colors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isNegative
                      ? context.colors.tagLostRed.withValues(alpha: 0.1)
                      : context.colors.tagFoundGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isNegative ? context.colors.tagLostRed : context.colors.tagFoundGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reports vs Returns',
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 15),
              ),
              Row(
                children: [
                  _buildLegendDot(context, 'REPORTS', context.colors.primaryTeal),
                  const SizedBox(width: 12),
                  _buildLegendDot(context, 'RETURNS', context.colors.textLight),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Chart Graphic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBarGroup(context, 'MON', 0.6, 0.3),
              _buildBarGroup(context, 'TUE', 0.8, 0.4),
              _buildBarGroup(context, 'WED', 0.5, 0.45),
              _buildBarGroup(context, 'THU', 0.95, 0.3),
              _buildBarGroup(context, 'FRI', 0.75, 0.4),
              _buildBarGroup(context, 'SAT', 0.4, 0.1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(BuildContext context, String text, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.textLight)),
      ],
    );
  }

  Widget _buildBarGroup(BuildContext context, String day, double p1, double p2) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: 120 * p1,
              decoration: BoxDecoration(
                color: context.colors.primaryTeal,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: 120 * p2,
              decoration: BoxDecoration(
                color: context.colors.dividerColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.textLight)),
      ],
    );
  }

  Widget _buildDonutChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 15),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Custom Donut Circle representation
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 0.7,
                      strokeWidth: 16,
                      backgroundColor: context.colors.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(context.colors.primaryTeal),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '3.2k',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textDark),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: context.colors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildDonutLegendRow(context, 'Industrial', '70%', context.colors.primaryTeal),
                    const SizedBox(height: 10),
                    _buildDonutLegendRow(context, 'Consumer', '15%', context.colors.primaryTeal.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    _buildDonutLegendRow(context, 'Logistics', '10%', Colors.brown),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonutLegendRow(BuildContext context, String category, String percent, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(category, style: TextStyle(color: context.colors.textDark, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(percent, style: TextStyle(color: context.colors.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRegionsTable(BuildContext context) {
    final headerStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colors.textLight);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Top Performing Regions', style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 15)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: context.colors.dividerColor.withValues(alpha: 0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('REGION', style: headerStyle)),
                Text('STATUS', style: headerStyle),
                const SizedBox(width: 40),
                Text('GROWTH', style: headerStyle),
              ],
            ),
          ),
          _buildRegionRow(context, 'North America East', 'ACTIVE', '+21%', isPositive: true),
          _buildRegionRow(context, 'Western Europe', 'ACTIVE', '+18%', isPositive: true),
          _buildRegionRow(context, 'East Asia', 'MAINTENANCE', '-2%', isPositive: false),
          _buildRegionRow(context, 'Latin America', 'ACTIVE', '+3%', isPositive: true),
        ],
      ),
    );
  }

  Widget _buildRegionRow(BuildContext context, String region, String status, String growth, {required bool isPositive}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(region, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textDark, fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'ACTIVE' ? context.colors.primaryTeal.withValues(alpha: 0.1) : context.colors.dividerColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: status == 'ACTIVE' ? context.colors.primaryTeal : context.colors.textLight,
              ),
            ),
          ),
          const SizedBox(width: 28),
          Text(
            growth,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isPositive ? context.colors.tagFoundGreen : context.colors.tagLostRed,
            ),
          ),
        ],
      ),
    );
  }
}
