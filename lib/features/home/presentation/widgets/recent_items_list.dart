import 'package:flutter/material.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
          ...List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
            child: ShimmerLoader(width: double.infinity, height: 280, borderRadius: 16),
          ))
        else ...[
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(
                  item: Item(
                    id: 'rec_1',
                    title: 'Sony WH-1000XM4 Headphones',
                    timeAgo: '2m ago',
                    location: 'Central Park Mall, Food Court',
                    description: 'Found Sony headphones in the food court area. Black color, slightly scratched.',
                    isLost: false,
                    imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
                    category: 'Electronics',
                  ),
                ),
              ),
            ),
            child: const ItemCard(
              title: 'Sony WH-1000XM4 Headphones',
              timeAgo: '2m ago',
              location: 'Central Park Mall, Food Court',
              userAvatarUrl: '',
              userName: 'JD',
              status: ItemStatus.found,
              imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=400',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(
                  item: Item(
                    id: 'rec_2',
                    title: 'Golden Retriever Puppy',
                    timeAgo: '15m ago',
                    location: 'Oakwood Residences Park',
                    description: 'Answers to "Cooper". Very friendly, found near the children\'s playground.',
                    isLost: false,
                    imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
                    category: 'Pets',
                  ),
                ),
              ),
            ),
            child: const ItemCard(
              title: 'Golden Retriever Puppy',
              timeAgo: '15m ago',
              location: 'Oakwood Residences Park',
              userAvatarUrl: '',
              userName: 'Sarah M.',
              status: ItemStatus.found,
              imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(
                  item: Item(
                    id: 'rec_3',
                    title: 'Brown Leather Wallet',
                    timeAgo: '1h ago',
                    location: 'Grand Central Terminal Station',
                    description: 'Lost a brown leather wallet. Contains transit cards and some cash.',
                    isLost: true,
                    imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=400',
                    category: 'Wallets',
                  ),
                ),
              ),
            ),
            child: const ItemCard(
              title: 'Brown Leather Wallet',
              timeAgo: '1h ago',
              location: 'Grand Central Terminal Station',
              userAvatarUrl: '',
              userName: 'Mark T.',
              status: ItemStatus.lost,
              imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=400',
            ),
          ),
          const SizedBox(height: 24), // padding at bottom
        ],
      ],
    );
  }
}
