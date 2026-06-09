import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';

class ModerationTab extends StatefulWidget {
  const ModerationTab({super.key});

  @override
  State<ModerationTab> createState() => _ModerationTabState();
}

class _ModerationTabState extends State<ModerationTab> {
  String _activeFilter = 'PENDING';
  Stream<QuerySnapshot<Map<String, dynamic>>>? _moderationStream;

  Future<void> _updateStatus(String id, String newStatus, String snackbarMsg, Color color) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('moderation_queue').doc(id);
      
      if (newStatus == 'RESOLVED') {
        final docSnapshot = await docRef.get();
        final itemId = docSnapshot.data()?['itemId'];
        if (itemId != null && itemId.toString().isNotEmpty) {
          await FirebaseFirestore.instance.collection('reports').doc(itemId).delete();
        }
      }
      
      await docRef.update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackbarMsg),
            backgroundColor: color,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _moderationStream ??= FirebaseFirestore.instance.collection('moderation_queue').snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _moderationStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reports: ${snapshot.error}',
              style: TextStyle(color: context.colors.textDark),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final filteredItems = docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'itemId': data['itemId'] ?? '',
            'title': data['title'] ?? 'Untitled Item',
            'reportedBy': data['reportedBy'] ?? 'Anonymous',
            'date': data['date'] ?? 'N/A',
            'reason': data['reason'] ?? '',
            'status': data['status'] ?? 'PENDING',
            'isUserReport': data['isUserReport'] ?? false,
            'createdAt': data['createdAt'],
          };
        }).where((item) => item['status'] == _activeFilter).toList();

        // Sort by createdAt descending
        filteredItems.sort((a, b) {
          final aTime = a['createdAt'] as Timestamp?;
          final bTime = b['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: context.colors.primaryTeal, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Moderation Queue',
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
                    'Review user reports and flagged content across the ecosystem.',
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

            _buildFilterChips(),
            const SizedBox(height: 24),

            if (filteredItems.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all_rounded, size: 64, color: context.colors.tagFoundGreen),
                    const SizedBox(height: 16),
                    Text(
                      'Moderation queue is empty',
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
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return _buildModerationCard(filteredItems[index]);
                },
              ),

            _buildPaginationFooter(filteredItems.length),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final filters = ['PENDING', 'RESOLVED', 'DISMISSED'];
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
                setState(() => _activeFilter = filter);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryTeal : context.colors.fieldBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : context.colors.dividerColor,
                    width: 1,
                  ),
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

  Widget _buildModerationCard(Map<String, dynamic> item) {
    final leftBorderColor = item['isUserReport'] ? context.colors.primaryTeal : const Color(0xFFD32F2F);
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: context.colors.dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: leftBorderColor, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.colors.background,
                    child: Icon(
                      item['isUserReport'] ? Icons.person_rounded : Icons.wallet_giftcard_rounded,
                      color: context.colors.textLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: context.colors.textLight, fontSize: 11),
                            children: [
                              const TextSpan(text: 'Reported by: '),
                              TextSpan(
                                text: item['reportedBy'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'DATE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textLight,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['date'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.colors.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REASON',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${item['reason']}"',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: context.colors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (_activeFilter == 'PENDING') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(
                          item['id'],
                          'DISMISSED',
                          'Report dismissed successfully.',
                          context.colors.textLight,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.textDark,
                          side: BorderSide(color: context.colors.dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(
                          item['id'],
                          'RESOLVED',
                          'Report resolved successfully.',
                          context.colors.primaryTeal,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        label: const Text('Resolve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primaryTeal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationFooter(int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page 1 of 1 ($count items)',
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton('Previous', onPressed: null),
              const SizedBox(width: 8),
              _buildPaginationButton('Next', onPressed: null),
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
          backgroundColor: context.colors.surfaceWhite,
          disabledBackgroundColor: context.colors.background,
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
