import 'package:flutter/material.dart';
import 'section_header.dart';
import 'item_card.dart';

class RecentItemsList extends StatelessWidget {
  const RecentItemsList({super.key});

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
        const ItemCard(
          title: 'Sony WH-1000XM4 Headphones',
          timeAgo: '2m ago',
          location: 'Central Park Mall, Food Court',
          userAvatarUrl: '',
          userName: 'JD',
          status: ItemStatus.found,
          imageUrl: 'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&q=80&w=400',
        ),
        const SizedBox(height: 16),
        const ItemCard(
          title: 'Golden Retriever Puppy',
          timeAgo: '15m ago',
          location: 'Oakwood Residences Park',
          userAvatarUrl: '',
          userName: 'Sarah M.',
          status: ItemStatus.found,
          imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
        ),
        const SizedBox(height: 16),
        const ItemCard(
          title: 'Brown Leather Wallet',
          timeAgo: '1h ago',
          location: 'Grand Central Terminal Station',
          userAvatarUrl: '',
          userName: 'Mark T.',
          status: ItemStatus.lost,
          imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&q=80&w=400',
        ),
        const SizedBox(height: 24), // padding at bottom
      ],
    );
  }
}
