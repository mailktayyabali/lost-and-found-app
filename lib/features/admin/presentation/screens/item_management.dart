import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../auth/presentation/login_screen.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/analytics_tab.dart';
import '../widgets/items_tab.dart';
import '../widgets/moderation_tab.dart';
import '../widgets/users_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 2; // Default active tab is ITEMS

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
      DashboardTab(
        signOut: _signOut,
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const AnalyticsTab(),
      const ItemsTab(),
      const ModerationTab(),
      const UsersTab(),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: tealColor, size: 26),
          tooltip: 'Menu',
          onPressed: () {},
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
          GestureDetector(
            onTap: _signOut,
            child: const Padding(
              padding: EdgeInsets.only(right: 16.0, left: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/32.jpg'),
              ),
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
          _buildBottomBarItem(1, Icons.trending_up_rounded, 'ANALYTICS', activeColor, inactiveColor),
          _buildBottomBarItem(2, Icons.inventory_2_outlined, 'ITEMS', activeColor, inactiveColor),
          _buildBottomBarItem(3, Icons.gavel_rounded, 'MODERATION', activeColor, inactiveColor),
          _buildBottomBarItem(4, Icons.people_outline_rounded, 'USERS', activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = _currentIndex == index;

    if (isSelected) {
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = index),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE2F0EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: activeColor, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: activeColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: inactiveColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
