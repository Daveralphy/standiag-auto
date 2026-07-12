// Mechanic Candidate Profile screen — full profile view of a mechanic the
// car owner is considering, shown from the mechanic card or search results.
// Not to be confused with profile/screens/mechanic_profile_screen.dart,
// which is a mechanic's view of their OWN profile.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/mechanics_provider.dart';
import '../../jobs/providers/job_provider.dart';

class MechanicCandidateProfileScreen extends ConsumerStatefulWidget {
  final String mechanicId;
  const MechanicCandidateProfileScreen({super.key, required this.mechanicId});

  @override
  ConsumerState<MechanicCandidateProfileScreen> createState() =>
      _MechanicCandidateProfileScreenState();
}

class _MechanicCandidateProfileScreenState
    extends ConsumerState<MechanicCandidateProfileScreen> {
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _callMechanic() async {
    setState(() => _isCalling = true);
    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;
    final jobId = await ref.read(jobProvider.notifier).createJob(
          carOwnerId: carOwnerId,
          mechanicId: widget.mechanicId,
          vehicleId: '',
          issue: 'General car issue',
        );
    if (!mounted) return;
    context.go(RouteNames.inAppCall,
        extra: {'jobId': jobId, 'mechanicId': widget.mechanicId});
  }

  @override
  Widget build(BuildContext context) {
    final mechanicAsync = ref.watch(mechanicByIdProvider(widget.mechanicId));
    final mechanicUserAsync =
        ref.watch(mechanicUserProvider(widget.mechanicId));
    final mechanic = mechanicAsync.valueOrNull;
    final mechanicUser = mechanicUserAsync.valueOrNull;
    final mechanicName = mechanicUser != null
        ? '${mechanicUser.firstName} ${mechanicUser.lastName}'.trim()
        : 'Mechanic';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.mechanicCard,
                          extra: widget.mechanicId);
                    }
                  },
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
                const Expanded(child: Text('Mechanic Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border)),
                      child: Column(children: [
                        AppAvatar(name: mechanicName, size: 72),
                        const SizedBox(height: 12),
                        Text(mechanicName,
                            style: AppTypography.heading2,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingStars(rating: mechanic?.rating ?? 0),
                            const SizedBox(width: 6),
                            Flexible(child: Text(
                                '${(mechanic?.rating ?? 0).toStringAsFixed(1)} · ${mechanic?.totalJobs ?? 0} jobs · ${mechanic?.yearsOfExperience ?? 0} yrs',
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis, maxLines: 1)),
                          ]),
                        const SizedBox(height: 12),
                        Wrap(spacing: 6, runSpacing: 6,
                          children: (mechanic?.expertise ?? const [])
                              .map((e) => ExpertiseTag(label: e))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(
                              mechanic?.workshopAddress ?? '',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                        const SizedBox(height: 6),
                        const Row(children: [
                          StatusDot(isOnline: true, size: 8),
                          SizedBox(width: 6),
                          Text('Online',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Call Mechanic',
                      onTap: _callMechanic,
                      isLoading: _isCalling,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}