import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../profile/data/models/review_model.dart';
import '../../../profile/data/repositories/firebase_reviews_repository.dart';
import '../../../profile/presentation/profile_screen.dart';

class ReporterProfileCard extends StatelessWidget {
  final String reporterUid;
  final String reporterName;

  const ReporterProfileCard({
    super.key,
    required this.reporterUid,
    required this.reporterName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: FirebaseReviewsRepository().getReviews(reporterUid),
      builder: (context, snapshot) {
        double averageRating = 0.0;
        int reviewCount = 0;

        if (snapshot.hasData && snapshot.data != null) {
          final reviews = snapshot.data!;
          reviewCount = reviews.length;
          if (reviews.isNotEmpty) {
            final sum = reviews.fold<int>(0, (prev, element) => prev + element.rating);
            averageRating = sum / reviews.length;
          }
        }

        final ratingText = reviewCount > 0
            ? '${averageRating.toStringAsFixed(1)} ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})'
            : 'No reviews';

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: reporterUid),
              ),
            );
          },
          borderRadius: AppDimensions.borderMedium,
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: AppDimensions.borderMedium,
              border: Border.all(color: context.colors.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reporterName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.colors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since 2021 • 12 items found',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.star,
                  color: reviewCount > 0 ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  ratingText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: context.colors.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
