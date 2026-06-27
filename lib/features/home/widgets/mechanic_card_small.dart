// Mechanic Card Small widget — compact mechanic card shown in the
// home screen nearby mechanics list and search results.

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';

class MechanicCardSmall extends StatelessWidget {
  final String name;
  final String? profilePhoto;
  final List<String> expertise;
  final double rating;
  final int totalJobs;
  final String distanceLabel;
  final bool isOnline;
  final VoidCallback? onTap;

  const MechanicCardSmall({
    super.key,
    required this.name,
    this.profilePhoto,
    required this.expertise,
    required this.rating,
    required this.totalJobs,
    required this.distanceLabel,
    required this.isOnline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AppAvatar(name: name, imageUrl: profilePhoto, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      RatingStars(rating: rating, starSize: 11),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$rating · $totalJobs jobs',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (expertise.isNotEmpty)
                    Text(
                      expertise.take(2).join(' · '),
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  distanceLabel,
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                StatusDot(isOnline: isOnline, size: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}