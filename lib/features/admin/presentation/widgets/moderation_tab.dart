import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ModerationTab extends StatefulWidget {
  const ModerationTab({super.key});

  @override
  State<ModerationTab> createState() => _ModerationTabState();
}

class _ModerationTabState extends State<ModerationTab> {
  String _activeFilter = 'PENDING';
  late List<Map<String, dynamic>> _moderationItems;
  late List<Map<String, dynamic>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _moderationItems = [
      {
        'id': '1',
        'title': 'Testing',
        'reportedBy': 'Tayyab Ali',
        'date': '5/24/2026',
        'reason': 'fsds',
        'status': 'PENDING',
        'isUserReport': true,
      },
      {
        'id': '2',
        'title': 'wallet',
        'reportedBy': 'Tayyab Ali',
        'date': '5/24/2026',
        'reason': 'thsdf',
        'status': 'PENDING',
        'isUserReport': false,
      },
    ];
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filteredItems = _moderationItems.where((item) => item['status'] == _activeFilter).toList();
    });
  }

  void _updateStatus(String id, String newStatus, String snackbarMsg, Color color) {
    setState(() {
      final index = _moderationItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _moderationItems[index]['status'] = newStatus;
      }
      _applyFilter();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackbarMsg),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        if (_filteredItems.isEmpty)
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
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              return _buildModerationCard(_filteredItems[index]);
            },
          ),

        _buildPaginationFooter(),
      ],
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
                _applyFilter();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryTeal : const Color(0xFFE9ECEF),
                  borderRadius: BorderRadius.circular(20),
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
        color: Colors.white,
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
                    backgroundColor: const Color(0xFFE9ECEF),
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
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
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

  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      child: Column(
        children: [
          Text(
            'PAGE 1 OF 1 (${_filteredItems.length} ITEMS)',
            style: TextStyle(
              color: context.colors.textLight.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowButton(Icons.chevron_left_rounded, onPressed: null),
              const SizedBox(width: 16),
              _buildArrowButton(Icons.chevron_right_rounded, onPressed: null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, {VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: isDisabled ? Colors.black26 : context.colors.textDark,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
