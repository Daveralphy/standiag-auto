// User Profile screen — view mode showing user details and vehicles.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(userProfileProvider, (_, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          AppErrorToast.showMessage(
            context,
            ErrorHandler.handle(error, stackTrace).message,
          );
        },
      );
    });

    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          loading: () => const _ProfileSkeletonView(),
          error: (error, stackTrace) => _ProfileErrorView(
            message: ErrorHandler.handle(error, stackTrace).message,
            onRetry: () => ref.invalidate(userProfileProvider),
          ),
          data: (user) {
            if (user == null) {
              return _ProfileErrorView(
                message: 'You need to be signed in to view this.',
                onRetry: () => ref.invalidate(userProfileProvider),
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(RouteNames.userHome);
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          AppStrings.profileTitle,
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.userSettings),
                        child: Text(
                          AppStrings.profileEdit,
                          style: AppTypography.body.copyWith(
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        AppAvatar(name: user.fullName, size: 80),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName,
                          style: AppTypography.heading2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: AppTypography.body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(label: AppStrings.fieldEmail, value: user.email),
                        _InfoRow(label: AppStrings.fieldPhone, value: user.phone),
                        _InfoRow(label: AppStrings.fieldAddress, value: user.address),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.myVehicles),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppStrings.profileMyVehicles,
                                    style: AppTypography.bodyLarge,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileSkeletonView extends StatelessWidget {
  const _ProfileSkeletonView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
              child: Row(
            children: [
              AppSkeleton(width: 32, height: 32, radius: AppRadius.full),
              SizedBox(width: 12),
              Expanded(child: AppSkeleton.wide(height: 14)),
              SizedBox(width: 12),
              AppSkeleton(width: 36, height: 12),
            ],
          ),
        ),
        SizedBox(height: 24),
        AppSkeleton.circle(size: 80),
        SizedBox(height: 12),
        AppSkeleton(width: 140, height: 20),
        SizedBox(height: 4),
        AppSkeleton(width: 90, height: 12),
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: Column(
            children: [
                AppSkeleton.wide(height: 14),
              SizedBox(height: 14),
              AppSkeleton.wide(height: 14),
              SizedBox(height: 14),
              AppSkeleton.wide(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.textMuted, size: 32),
            const SizedBox(height: 12),
            Text(message,
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(AppStrings.errorTryAgain,
                  style: AppTypography.body.copyWith(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
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
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
