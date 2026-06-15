import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/item_model.dart';

class AdminItemDetailsSheet extends StatelessWidget {
  final Item item;
  final ScrollController scrollController;
  final VoidCallback onResolve;

  const AdminItemDetailsSheet({
    super.key,
    required this.item,
    required this.scrollController,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: context.colors.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: context.colors.background,
                child: Icon(Icons.image_not_supported_rounded, color: context.colors.textLight),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.isLost
                      ? context.colors.tagLostRed.withValues(alpha: 0.1)
                      : context.colors.tagFoundGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    color: item.isLost
                        ? context.colors.tagLostRed
                        : context.colors.tagFoundGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                item.timeAgo,
                style: TextStyle(color: context.colors.textLight, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${item.category}  |  Location: ${item.displayLocation}',
            style: TextStyle(
              color: context.colors.primaryTeal,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Description',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: TextStyle(
              color: context.colors.textLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Reporter Information',
            style: TextStyle(
              color: context.colors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Community Member',
                    style: TextStyle(
                      color: context.colors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reporter',
                    style: TextStyle(
                      color: context.colors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (item.status != 'RESOLVED')
            ElevatedButton(
              onPressed: onResolve,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Mark Case as Resolved',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
