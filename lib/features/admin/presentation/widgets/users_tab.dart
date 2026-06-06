import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'admin_user_card.dart';
import 'admin_user_stat_card.dart';
import 'delete_user_dialog.dart';

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

  void _deleteUserConfirm(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteUserDialog(
        userName: name,
        onDeleteConfirm: () {
          setState(() {
            _users.removeWhere((u) => u['id'] == id);
            _applyFilter();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User $name deleted.')),
          );
        },
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
              child: AdminUserStatCard(
                title: 'TOTAL ACTIVE',
                value: '1,284',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AdminUserStatCard(
                title: 'NEW THIS WEEK',
                value: '+12',
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
                    hintText: 'Search user by name or email...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: context.colors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear_rounded, color: context.colors.textLight, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _applyFilter();
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        if (_filteredUsers.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.person_off_rounded, size: 48, color: context.colors.textLight.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  'No users match your query',
                  style: TextStyle(
                    fontSize: 14,
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
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return AdminUserCard(
                user: user,
                onToggleBan: () => _toggleBan(user['id'], user['name']),
                onDelete: () => _deleteUserConfirm(user['id'], user['name']),
              );
            },
          ),
      ],
    );
  }
}
