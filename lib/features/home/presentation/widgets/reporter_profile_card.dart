import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../profile/data/models/review_model.dart';
import '../../../profile/data/repositories/firebase_reviews_repository.dart';
import '../../../profile/presentation/profile_screen.dart';
import '../../../auth/domain/auth_service.dart';
import '../../../reports/data/repositories/firebase_reports_repository.dart';
import '../../../../shared/models/item_model.dart';

class ReporterProfileCard extends StatelessWidget {
  final String? reporterUid;
  final String reporterName;

  const ReporterProfileCard({
    super.key,
    this.reporterUid,
    required this.reporterName,
  });

  Future<Map<String, dynamic>> _fetchReporterData(String uid) async {
    final results = await Future.wait([
      AuthService().getUserData(uid),
      FirebaseReviewsRepository().getReviews(uid),
      FirebaseReportsRepository().getItems(),
    ]);

    return {
      'profile': results[0] as Map<String, dynamic>?,
      'reviews': results[1] as List<Review>,
      'items': (results[2] as List<Item>).where((item) => item.createdBy == uid).toList(),
    };
  }

  Widget _buildDisabledState(BuildContext context) {
    return Container(
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
                    color: context.colors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No details available',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.star,
            color: Color(0xFFCBD5E1),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'No reviews',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: context.colors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(color: context.colors.dividerColor.withValues(alpha: 0.5)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (reporterUid == null || reporterUid!.isEmpty) {
      return _buildDisabledState(context);
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchReporterData(reporterUid!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(context);
        }

        final profile = snapshot.data?['profile'] as Map<String, dynamic>?;
        final reviews = (snapshot.data?['reviews'] as List<Review>?) ?? [];
        final items = (snapshot.data?['items'] as List<Item>?) ?? [];

        double averageRating = 0.0;
        final reviewCount = reviews.length;
        if (reviews.isNotEmpty) {
          final sum = reviews.fold<int>(0, (prev, element) => prev + element.rating);
          averageRating = sum / reviews.length;
        }

        final ratingText = reviewCount > 0
            ? '${averageRating.toStringAsFixed(1)} ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})'
            : 'No reviews';

        const fallbackUrl = 'https://img.freepik.com/free-psd/3d-illustration-person-with-sunglasses_23-2149436188.jpg';
        final avatarUrl = profile?['photoURL'] as String? ?? fallbackUrl;

        int joinedYear = 2021;
        final createdAt = profile?['createdAt'];
        if (createdAt is Timestamp) {
          joinedYear = createdAt.toDate().year;
        } else if (createdAt is String) {
          joinedYear = DateTime.tryParse(createdAt)?.year ?? 2021;
        }
        final itemsCount = items.length;

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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatarUrl),
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
                        'Member since $joinedYear • $itemsCount ${itemsCount == 1 ? 'item' : 'items'} found',
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
