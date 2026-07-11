// Mechanic Profile screen (own view) — mechanic views their own profile.
// Lives in profile/screens/ — different from the user-facing mechanic
// profile in mechanics/screens/mechanic_profile_screen.dart.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicProfileOwnScreen extends ConsumerStatefulWidget {
  const MechanicProfileOwnScreen({super.key});

  @override
  ConsumerState<MechanicProfileOwnScreen> createState() =>
      _MechanicProfileOwnScreenState();
}

class _MechanicProfileOwnScreenState
    extends ConsumerState<MechanicProfileOwnScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);
    final userAsync = ref.watch(userProfileProvider);
    final mechanicAsync =
        uid == null ? null : ref.watch(mechanicByIdProvider(uid));
    final user = userAsync.valueOrNull;
    final mechanic = mechanicAsync?.valueOrNull;
    final name = user != null ? '${user.firstName} ${user.lastName}'.trim() : '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('My Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: () => context.go(RouteNames.mechanicProfileEdit),
                  child: Text('Edit',
                      style: AppTypography.body.copyWith(
                          color: AppColors.primary),
                      overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(children: [
                  AppAvatar(name: name, size: 80),
                  const SizedBox(height: 12),
                  Text(name, style: AppTypography.heading2,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RatingStars(rating: mechanic?.rating ?? 0),
                      const SizedBox(width: 6),
                      Flexible(child: Text(
                          '${(mechanic?.rating ?? 0).toStringAsFixed(1)} · ${mechanic?.totalJobs ?? 0} jobs',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1)),
                    ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 6, runSpacing: 6,
                    children: (mechanic?.expertise ?? const [])
                        .map((e) => ExpertiseTag(label: e))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _InfoRow(label: 'Workshop', value: mechanic?.workshopAddress ?? ''),
                  _InfoRow(label: 'Experience',
                      value: '${mechanic?.yearsOfExperience ?? 0} years'),
                  _InfoRow(label: 'Phone', value: user?.phone ?? ''),
                  _InfoRow(label: 'Email', value: user?.email ?? ''),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        SizedBox(width: 80,
          child: Text(label, style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1)),
        Expanded(child: Text(value, style: AppTypography.body,
            overflow: TextOverflow.ellipsis, maxLines: 1)),
      ]),
    );
  }
}