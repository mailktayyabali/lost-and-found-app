import 'package:flutter/material.dart';
import '../../../reports/data/repositories/mock_reports_repository.dart';
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
  final MockReportsRepository _reportsRepository = MockReportsRepository();
  List<Item> _foundItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentFoundItems();
  }

  Future<void> _loadRecentFoundItems() async {
    final list = await _reportsRepository.getItems();
    // Filter to found items only
    final found = list.where((item) => !item.isLost && item.status == 'FOUND').toList();
    if (mounted) {
      setState(() {
        _foundItems = found;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recently Found',
          actionText: 'Latest updates',
          onActionTap: () {},
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 16, left: 20, right: 20),
            child: ShimmerLoader(width: double.infinity, height: 280, borderRadius: 16),
          ))
        else if (_foundItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text('No recently found items'),
            ),
          )
        else
          ..._foundItems.take(3).map((item) {
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
                  userName: 'Reporter',
                  status: ItemStatus.found,
                  imageUrl: item.imageUrl,
                ),
              ),
            );
          }),
      ],
    );
  }
}
