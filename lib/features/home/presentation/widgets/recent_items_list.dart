import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reports/data/repositories/firebase_reports_repository.dart';
import '../item_details_screen.dart';
import '../../../../shared/models/item_model.dart';
import 'section_header.dart';
import 'item_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class RecentItemsList extends StatefulWidget {
  const RecentItemsList({super.key});

  @override
  State<RecentItemsList> createState() => _RecentItemsListState();
}

class _RecentItemsListState extends State<RecentItemsList> {
  final FirebaseReportsRepository _reportsRepository = FirebaseReportsRepository();
  List<Item> _allItems = [];
  String _filter = 'ALL'; // 'ALL' | 'FOUND' | 'LOST'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentItems();
  }

  Future<void> _loadRecentItems() async {
    try {
      final list = await _reportsRepository.getItems();
      if (mounted) {
        setState(() {
          _allItems = list;
        });
      }
    } catch (e) {
      debugPrint('RecentItemsList: Error loading items: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildFilterPill(String value, String label) {
    final isSelected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.colors.primaryTeal.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : context.colors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _allItems.where((item) {
      if (_filter == 'ALL') {
        return item.status == 'LOST' || item.status == 'FOUND';
      }
      return item.status == _filter;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Reports',
          actionText: 'Latest updates',
          onActionTap: () {},
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: context.colors.fieldBorder.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                _buildFilterPill('ALL', 'All Reports'),
                _buildFilterPill('FOUND', 'Found'),
                _buildFilterPill('LOST', 'Lost'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 20, right: 20),
            child: ShimmerLoader(width: double.infinity, height: 280, borderRadius: 16),
          ))
        else if (activeList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: context.colors.textLight.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No recent items found',
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...activeList.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailsScreen(item: item),
                  ),
                ),
                child: ItemCard(
                  title: item.title,
                  timeAgo: item.timeAgo,
                  location: item.location,
                  userAvatarUrl: '',
                  userName: item.reporterName ?? 'Reporter',
                  status: item.isLost ? ItemStatus.lost : ItemStatus.found,
                  imageUrl: item.imageUrl,
                ),
              ),
            );
          }),
      ],
    );
  }
}
