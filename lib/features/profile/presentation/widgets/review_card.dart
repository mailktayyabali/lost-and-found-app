import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.dividerColor),
        boxShadow: [
          BoxShadow(
            color: context.colors.textDark.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Reviewer info & rating stars
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.reviewerAvatarUrl.isNotEmpty
                    ? NetworkImage(review.reviewerAvatarUrl)
                    : null,
                backgroundColor: context.colors.primaryTeal.withValues(alpha: 0.1),
                child: review.reviewerAvatarUrl.isEmpty
                    ? Text(
                        review.reviewerName.isNotEmpty ? review.reviewerName[0].toUpperCase() : 'A',
                        style: TextStyle(
                          color: context.colors.primaryTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.colors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < review.rating ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
