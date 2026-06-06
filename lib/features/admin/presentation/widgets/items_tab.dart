import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/item_model.dart';
import '../../../reports/data/repositories/firebase_reports_repository.dart';
import 'admin_stat_card.dart';
import 'admin_item_card.dart';
import 'delete_listing_dialog.dart';
import 'admin_item_details_sheet.dart';

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  final FirebaseReportsRepository _reportsRepository = FirebaseReportsRepository();
  String _activeFilter = 'ALL';
  List<Item> _allItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final list = await _reportsRepository.getItems();
    setState(() {
      _allItems = list;
      _isLoading = false;
    });
  }

  List<Item> get _filteredItems {
    if (_activeFilter == 'ALL') {
      return _allItems;
    }
    return _allItems.where((item) => item.status == _activeFilter).toList();
  }

  int get _countActive {
    return _allItems.where((item) => item.status == 'LOST' || item.status == 'FOUND' || item.status == 'ACTIVE').length;
  }

  int get _countResolved {
    return _allItems.where((item) => item.status == 'RESOLVED').length;
  }

  void _deleteItemConfirm(Item item) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteListingDialog(
        item: item,
        onDeleteConfirm: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final lostRedColor = context.colors.tagLostRed;
          await _reportsRepository.deleteReport(item.id);
          await _loadItems();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('"${item.title}" has been successfully moderated and deleted.'),
              backgroundColor: lostRedColor,
            ),
          );
        },
      ),
    );
  }

  void _viewItemDetails(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => AdminItemDetailsSheet(
          item: item,
          scrollController: scrollController,
          onResolve: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final foundGreenColor = context.colors.tagFoundGreen;
            Navigator.of(context).pop();
            await _reportsRepository.updateItemStatus(item.id, 'RESOLVED');
            await _loadItems();
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('"${item.title}" successfully marked as Resolved.'),
                backgroundColor: foundGreenColor,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Management',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Moderate lost and found listings',
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
        const SizedBox(height: 28),

        _buildStatsRow(),
        const SizedBox(height: 28),

        if (_filteredItems.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive_outlined, size: 64, color: context.colors.textLight.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  'No listings available in this category',
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
              return AdminItemCard(
                item: _filteredItems[index],
                onViewDetails: () => _viewItemDetails(_filteredItems[index]),
                onDelete: () => _deleteItemConfirm(_filteredItems[index]),
              );
            },
          ),

        _buildPaginationFooter(_filteredItems.length),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['ALL', 'LOST', 'FOUND', 'RESOLVED'];
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
                setState(() {
                  _activeFilter = filter;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryTeal : Colors.white,
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

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: AdminStatCard(
              title: 'ACTIVE CASES',
              value: _countActive.toString(),
              accentColor: context.colors.primaryTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AdminStatCard(
              title: 'RESOLVED',
              value: _countResolved.toString(),
              accentColor: context.colors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(int totalItems) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page 1 of 1 ($totalItems items)',
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              _buildPaginationButton('PREV', onPressed: null),
              const SizedBox(width: 8),
              _buildPaginationButton('NEXT', onPressed: null),
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
          backgroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFF1F3F5),
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
