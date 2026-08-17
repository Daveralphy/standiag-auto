// User Rate Mechanic screen â€” user taps stars and leaves optional comment.
// Map background, user nav Mechanics active, search icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/notched_nav_bar.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/job_provider.dart';

class UserRateMechanicScreen extends ConsumerStatefulWidget {
  final String jobId;
  const UserRateMechanicScreen({super.key, required this.jobId});

  @override
  ConsumerState<UserRateMechanicScreen> createState() =>
      _UserRateMechanicScreenState();
}

class _UserRateMechanicScreenState
    extends ConsumerState<UserRateMechanicScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppErrorToast.showMessage(context, 'Tap a star to rate the mechanic.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(jobProvider.notifier).submitRating(
            widget.jobId,
            _rating.toDouble(),
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
      if (!mounted) return;
      context.go(RouteNames.userHome);
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppErrorToast.showMessage(
          context, ErrorHandler.handle(error, stackTrace).message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(jobProvider.select((s) => s.activeJob));
    final mechanicAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.mechanicId));
    final mechanicName = mechanicAsync?.valueOrNull != null
        ? '${mechanicAsync!.valueOrNull!.firstName} ${mechanicAsync.valueOrNull!.lastName}'
            .trim()
        : 'Mechanic';
    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: Stack(
        children: [
          Container(color: AppColors.mapBackground,
              child: Center(child: Icon(Icons.map_outlined,
                  size: 80, color: AppColors.borderSubtle))),

          Positioned(top: 0, left: 0, right: 0, height: 140,
            child: Container(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.background.withValues(alpha: 0.9), Colors.transparent])))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                const AppAvatar(name: 'John Doe', size: 36),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate Mechanic', style: AppTypography.heading3,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text('How was the job?', style: AppTypography.body,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                )),
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.surfaceElevated.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.borderActive)),
                  child: Icon(Icons.search_rounded,
                      size: 16, color: AppColors.textPrimary)),
              ]),
            ),
          ),

          Positioned(
            bottom: AppSpacing.navBarClearance + 12,
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  AppAvatar(name: mechanicName, size: 46),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mechanicName, style: AppTypography.heading4,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text(job?.issue ?? '',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  )),
                ]),
                const SizedBox(height: 16),
                Text('Tap a star to rate',
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 12),
                // Star selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: i < _rating
                              ? AppColors.primary
                              : AppColors.textDisabled,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Comment (optional)',
                  controller: _commentController,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: AppButton(
                    label: 'Skip',
                    onTap: () => context.go(RouteNames.userHome),
                    variant: AppButtonVariant.ghost,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: AppButton(
                    label: 'Submit',
                    onTap: _submit,
                    isLoading: _isLoading,
                  )),
                ]),
              ]),
            ),
          ),

          NotchedNavBar(
            activeIndex: 1,
            onScanTap: () => context.go(RouteNames.userVehicle),
            items: [
              AppNavItem(icon: Icons.home_rounded, label: 'Home',
                  onTap: () => context.go(RouteNames.userHome)),
              AppNavItem(icon: Icons.build_rounded, label: 'Mechanics',
                  onTap: () {}),
              AppNavItem(icon: Icons.directions_car_rounded, label: 'Vehicle',
                  onTap: () => context.go(RouteNames.userVehicle)),
              AppNavItem(icon: Icons.person_rounded, label: 'Profile',
                  onTap: () => context.go(RouteNames.userProfile)),
            ],
          ),
        ],
      ),
    );
  }
}