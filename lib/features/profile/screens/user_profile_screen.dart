// User Profile screen — view mode showing user details and vehicles.
// Matches design/profile_screens.html Screen 1: back + title + edit-pencil
// header, centered avatar/name/username, then a divided field list.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/profile_field_row.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isLoading = true;
  UserModel? _user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _load();
  }

  // Deliberately a single one-time fetch instead of watching the app-wide
  // profile stream — a profile *view* isn't one of the project's real-time
  // cases (only incoming-calls/active-job/mechanic-location are), and a
  // plain future here is far easier to reason about than a long-lived
  // stream shared with every screen in the app.
  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'You need to be signed in to view this.';
        });
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .get();
      final user = doc.exists
          ? UserModel.fromFirestore(doc)
          : UserModel.fromFirebaseUser(authUser);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
      ref.read(profileProvider.notifier).fetchVehicles(authUser.uid);
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorHandler.handle(e, stackTrace,
                screen: 'UserProfileScreen', userId: FirebaseAuth.instance.currentUser?.uid)
            .message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(profileProvider).vehicles;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                      width: 30,
                      height: 30,
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
                    onTap: () => context.go(RouteNames.userProfileEdit),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(builder: (context) {
                if (_isLoading) return const _ProfileSkeletonView();
                if (_errorMessage != null) {
                  return _ProfileErrorView(
                    message: _errorMessage!,
                    onRetry: _load,
                  );
                }

                final user = _user!;
                final vehicleSummary = vehicles.isNotEmpty
                    ? '${vehicles.first.displayName}${vehicles.length > 1 ? ' +${vehicles.length - 1} more' : ''}'
                    : 'No vehicles added';

                return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        AppAvatar(
                          name: user.fullName.trim().isNotEmpty
                              ? user.fullName
                              : user.username,
                          imageUrl: user.profilePhoto,
                          size: 84,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.fullName.trim().isNotEmpty
                              ? user.fullName
                              : user.username,
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${user.username}',
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0x0FFFFFFF)),
                        ProfileFieldRow(
                            label: AppStrings.fieldFullName,
                            value: user.fullName),
                        ProfileFieldRow(
                            label: AppStrings.fieldUsername,
                            value: '@${user.username}'),
                        ProfileFieldRow(
                            label: AppStrings.fieldEmail, value: user.email),
                        ProfileFieldRow(
                            label: AppStrings.fieldPhone, value: user.phone),
                        ProfileFieldRow(
                            label: AppStrings.fieldAddress, value: user.address),
                        ProfileFieldRow(
                          label: AppStrings.profileMyVehicles,
                          value: vehicleSummary,
                          dimmed: true,
                          onTap: () => context.push(RouteNames.myVehicles),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the real layout exactly (centered name/username, then divider,
/// then six field rows each with a tiny label-shaped bar over a
/// value-shaped bar) so the skeleton never jumps or resizes once the
/// real data arrives — it's the same shapes, just shimmering placeholders.
class _ProfileSkeletonView extends StatelessWidget {
  const _ProfileSkeletonView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const AppSkeleton.circle(size: 84),
          const SizedBox(height: 12),
          const AppSkeleton(width: 120, height: 16, radius: AppRadius.xs),
          const SizedBox(height: 8),
          const AppSkeleton(width: 80, height: 11, radius: AppRadius.xs),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x0FFFFFFF)),
          for (int i = 0; i < 6; i++)
            ProfileFieldRowSkeleton(valueWidth: i.isEven ? 160 : 120),
        ],
      ),
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
