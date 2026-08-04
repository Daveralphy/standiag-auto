// A compact mechanic preview card — avatar, name, rating, distance — used
// wherever a short list of nearby mechanics needs to be shown inline rather
// than on the full map (Home's "Nearby Mechanics" preview, the Mechanics
// tab's "Nearby Mechanics" list).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/route_names.dart';
import '../../features/mechanics/providers/mechanics_provider.dart';
import 'app_avatar.dart';
import 'app_skeleton.dart';

class MiniMechanicCard extends ConsumerWidget {
  final NearbyMechanic entry;

  const MiniMechanicCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanic = entry.mechanic;
    final userAsync = ref.watch(mechanicUserProvider(mechanic.uid));

    return GestureDetector(
      onTap: () =>
          context.push(RouteNames.mechanicProfile, extra: mechanic.uid),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            userAsync.when(
              data: (user) => AppAvatar(
                name: user != null
                    ? '${user.firstName} ${user.lastName}'.trim()
                    : 'Mechanic',
                imageUrl: user?.profilePhoto,
                size: 44,
              ),
              loading: () => const AppSkeleton.circle(size: 44),
              error: (_, __) => const AppAvatar(name: 'Mechanic', size: 44),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsync.when(
                    data: (user) => Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'.trim()
                          : 'Mechanic',
                      style: AppTypography.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    loading: () => Container(
                      width: 100,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (_, __) =>
                        const Text('Mechanic', style: AppTypography.bodyLarge),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        mechanic.rating.toStringAsFixed(1),
                        style: AppTypography.caption,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.distanceKm != null
                              ? '${entry.distanceKm!.toStringAsFixed(1)} km away'
                              : 'Distance unknown',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class MiniMechanicCardSkeleton extends StatelessWidget {
  const MiniMechanicCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 13,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 70,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0x0AFFFFFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
