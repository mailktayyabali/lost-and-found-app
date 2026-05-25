import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _users;
  late List<Map<String, dynamic>> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _users = [
      {
        'id': '1',
        'name': 'Admin',
        'email': 'admin@findit.com',
        'joined': '5/24/2026',
        'status': 'ACTIVE',
        'avatar': 'AD',
        'isImage': false,
      },
      {
        'id': '2',
        'name': 'Alishba Asif',
        'email': 'alishbaasif1266@gmail.com',
        'joined': '4/3/2026',
        'status': 'ACTIVE',
        'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=100',
        'isImage': true,
      },
      {
        'id': '3',
        'name': 'Rajab Ali',
        'email': 'rajab10312@gmail.com',
        'joined': '2/16/2026',
        'status': 'ACTIVE',
        'avatar': 'RA',
        'isImage': false,
      },
      {
        'id': '4',
        'name': 'zuhran',
        'email': 'zuhrayousaf1234@gmail.com',
        'joined': '2/12/2026',
        'status': 'ACTIVE',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100',
        'isImage': true,
      },
    ];
    _applyFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users.where((user) {
          final name = user['name'].toString().toLowerCase();
          final email = user['email'].toString().toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();
      }
    });
  }

  void _toggleBan(String id, String name) {
    setState(() {
      final index = _users.indexWhere((u) => u['id'] == id);
      if (index != -1) {
        final currentStatus = _users[index]['status'];
        _users[index]['status'] = currentStatus == 'BANNED' ? 'ACTIVE' : 'BANNED';
      }
      _applyFilter();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated ban status for $name.')),
    );
  }

  void _deleteUser(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        title: Text('Delete User', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete user "$name"?', style: TextStyle(color: context.colors.textLight)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.colors.textLight)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.tagLostRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _users.removeWhere((u) => u['id'] == id);
                _applyFilter();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $name deleted.')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      children: [
        Row(
          children: [
            Icon(Icons.group_rounded, color: context.colors.primaryTeal, size: 28),
            const SizedBox(width: 8),
            Text(
              'User Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.colors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'View and moderate registered users within the Meridian ecosystem.',
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
              child: _buildSimpleStatCard(
                context,
                'TOTAL ACTIVE',
                '1,284',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSimpleStatCard(
                context,
                'NEW THIS WEEK',
                '+12',
                accentColor: context.colors.tagFoundGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.menu_open_rounded, color: context.colors.textLight),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                    _applyFilter();
                  },
                  style: TextStyle(color: context.colors.textDark),
                  decoration: InputDecoration(
                    hintText: 'Search registered users...',
                    hintStyle: TextStyle(color: context.colors.textLight, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_filteredUsers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No users match query.',
                style: TextStyle(color: context.colors.textLight, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          ..._filteredUsers.map((user) => _buildUserCard(user)),

        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Text(
              'Load More Users',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            label: const Icon(Icons.keyboard_arrow_down_rounded),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.primaryTeal,
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildSimpleStatCard(
    BuildContext context,
    String title,
    String value, {
    Color? accentColor,
  }) {
    final activeColor = accentColor ?? context.colors.primaryTeal;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
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
              left: BorderSide(color: activeColor, width: 5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.colors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final statusColor = user['status'] == 'ACTIVE' ? context.colors.tagFoundGreen : context.colors.tagLostRed;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFFFE0B2),
                backgroundImage: user['isImage'] ? NetworkImage(user['avatar']) : null,
                child: !user['isImage']
                    ? Text(
                        user['avatar'],
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user['email'],
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user['status'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOINED',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['joined'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _toggleBan(user['id'], user['name']),
                    icon: Icon(
                      user['status'] == 'BANNED' ? Icons.check_circle_outline_rounded : Icons.block_flipped,
                      color: context.colors.textLight,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _deleteUser(user['id'], user['name']),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.colors.tagLostRed,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F3F5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
