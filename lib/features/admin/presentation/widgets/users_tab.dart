import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  Stream<QuerySnapshot<Map<String, dynamic>>>? _usersStream;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleBan(String id, bool currentBannedStatus, String name) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(id).update({
        'isBanned': !currentBannedStatus,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ban status for $name.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ban status for $name: $e')),
        );
      }
    }
  }

  void _deleteUserConfirm(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteUserDialog(
        userName: name,
        onDeleteConfirm: () async {
          try {
            await FirebaseFirestore.instance.collection('users').doc(id).delete();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $name deleted.')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete user $name: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _usersStream ??= FirebaseFirestore.instance.collection('users').snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users: ${snapshot.error}',
              style: TextStyle(color: context.colors.textDark),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final allUsers = docs.map((doc) {
          final data = doc.data();
          final createdAt = data['createdAt'] as Timestamp?;
          final joinedStr = createdAt != null
              ? DateFormat('M/d/yyyy').format(createdAt.toDate())
              : 'N/A';
          final name = data['name'] ?? 'No Name';

          return {
            'id': doc.id,
            'name': name,
            'email': data['email'] ?? '',
            'role': data['role'] ?? 'user',
            'joined': joinedStr,
            'status': data['isBanned'] == true ? 'BANNED' : 'ACTIVE',
            'avatar': name.isNotEmpty
                ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase()
                : 'U',
            'isImage': false,
            'createdAt': createdAt,
          };
        }).toList();

        // Calculate stats
        final now = DateTime.now();
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        final activeUsers = allUsers.where((u) => u['status'] != 'BANNED').length;
        final newThisWeek = allUsers.where((u) {
          final createdAt = u['createdAt'] as Timestamp?;
          if (createdAt == null) return false;
          return createdAt.toDate().isAfter(oneWeekAgo);
        }).length;

        // Apply search query
        final filteredUsers = allUsers.where((user) {
          if (_searchQuery.isEmpty) return true;
          final name = user['name'].toString().toLowerCase();
          final email = user['email'].toString().toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

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
                    value: activeUsers.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AdminUserStatCard(
                    title: 'NEW THIS WEEK',
                    value: '+$newThisWeek',
                    accentColor: context.colors.tagFoundGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.fieldBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colors.fieldBorder),
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
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (filteredUsers.isEmpty)
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
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return AdminUserCard(
                    user: user,
                    onToggleBan: () => _toggleBan(user['id'], user['status'] == 'BANNED', user['name']),
                    onDelete: () => _deleteUserConfirm(user['id'], user['name']),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
