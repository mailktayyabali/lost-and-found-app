import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _statusFilter = 'All'; // 'All', 'Lost', 'Found', 'Resolved'

  Future<void> _toggleReportResolution(String reportId, String currentStatus) async {
    final nextStatus = currentStatus == 'resolved' ? 'active' : 'resolved';
    try {
      await _firestore.collection('reports').doc(reportId).update({'status': nextStatus});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report successfully marked as $nextStatus.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _deleteReport(String reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceWhite,
        title: Text('Delete Report', style: TextStyle(color: context.colors.textDark, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this report permanently? This action cannot be undone.',
            style: TextStyle(color: context.colors.textLight)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: context.colors.textLight)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.tagLostRed),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('reports').doc(reportId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report successfully deleted.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primaryTeal),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Content Moderation',
          style: TextStyle(
            color: context.colors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 56,
            color: context.colors.surfaceWhite,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: ['All', 'Lost', 'Found', 'Resolved'].map((tab) {
                final isSelected = _statusFilter == tab;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _statusFilter = tab;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? context.colors.primaryTeal : context.colors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : context.colors.dividerColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : context.colors.textLight,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('reports').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading reports: ${snapshot.error}'));
                }

                final docs = snapshot.data?.docs ?? [];

                // Filter on client side
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'active';
                  final isLost = data['isLost'] ?? true;
                  final type = isLost ? 'Lost' : 'Found';

                  if (_statusFilter == 'All') return true;
                  if (_statusFilter == 'Resolved') return status == 'resolved';
                  if (_statusFilter == 'Lost') return type == 'Lost' && status != 'resolved';
                  if (_statusFilter == 'Found') return type == 'Found' && status != 'resolved';
                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: context.colors.textLight),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(fontSize: 16, color: context.colors.textLight, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final reportId = doc.id;
                    final itemName = data['itemName'] ?? 'Unnamed Item';
                    final category = data['category'] ?? 'Other';
                    final location = data['location'] ?? 'No Location';
                    final description = data['description'] ?? 'No Description';
                    final isLost = data['isLost'] ?? true;
                    final status = data['status'] ?? 'active';

                    return Card(
                      color: context.colors.surfaceWhite,
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: context.colors.dividerColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLost
                                        ? context.colors.tagLostRed.withValues(alpha: 0.1)
                                        : context.colors.tagFoundGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isLost ? 'LOST' : 'FOUND',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isLost ? context.colors.tagLostRed : context.colors.tagFoundGreen,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'resolved'
                                        ? context.colors.tagFoundGreen.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: status == 'resolved' ? context.colors.tagFoundGreen : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              itemName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: $category | Location: $location',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.colors.textDark,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Divider(color: context.colors.dividerColor, height: 1),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: Icon(
                                    status == 'resolved' ? Icons.replay_rounded : Icons.check_circle_outline_rounded,
                                    size: 16,
                                    color: status == 'resolved' ? Colors.orange : context.colors.tagFoundGreen,
                                  ),
                                  label: Text(
                                    status == 'resolved' ? 'Mark Active' : 'Mark Resolved',
                                    style: TextStyle(
                                      color: status == 'resolved' ? Colors.orange : context.colors.tagFoundGreen,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: status == 'resolved' ? Colors.orange : context.colors.tagFoundGreen,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _toggleReportResolution(reportId, status),
                                ),
                                OutlinedButton.icon(
                                  icon: Icon(Icons.delete_outline_rounded, size: 16, color: context.colors.tagLostRed),
                                  label: Text(
                                    'Delete',
                                    style: TextStyle(color: context.colors.tagLostRed, fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: context.colors.tagLostRed),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => _deleteReport(reportId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
