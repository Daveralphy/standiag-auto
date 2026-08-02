// User Profile tab — the car owner's account hub. Replaces the old drawer
// entirely: everything that used to be a drawer entry is a section here
// instead, since there's no longer anywhere else for it to live once
// Profile has its own tab.

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
import '../../../features/credits/providers/credits_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/log_out_dialog.dart';
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
      ref.read(creditsProvider.notifier).fetchBalance(authUser.uid);
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

  Future<void> _signOut() async {
    final confirmed = await LogOutDialog.show(context);
    if (!confirmed || !mounted) return;
    try {
      await ref.read(authControllerProvider).signOut();
      if (!mounted) return;
      context.go(RouteNames.login);
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace).message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(creditsProvider.select((s) => s.balance));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppScreenHeader(
              title: 'Your Profile',
              subtitle: 'Manage your account',
              trailingIcon: Icons.monetization_on_outlined,
              trailingWidget: GestureDetector(
                onTap: () => context.push(RouteNames.userCredits),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text('$balance',
                          style: AppTypography.bodyLarge
                              .copyWith(color: AppColors.primary),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(builder: (context) {
                if (_isLoading) return const _ProfileSkeletonView();
                if (_errorMessage != null) {
                  return _ProfileErrorView(message: _errorMessage!, onRetry: _load);
                }
                final user = _user!;
                final displayName = user.fullName.trim().isNotEmpty
                    ? user.fullName
                    : user.username;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                      AppSpacing.xl, AppSpacing.pageHorizontal, AppSpacing.navBarClearance),
                  child: Column(
                    children: [
                      AppAvatar(name: displayName, imageUrl: user.profilePhoto, size: 84),
                      const SizedBox(height: 12),
                      Text(displayName,
                          style: AppTypography.heading3,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      const SizedBox(height: 2),
                      Text('@${user.username}',
                          style: AppTypography.bodySmall,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      const SizedBox(height: 28),
                      _ProfileSection(
                        title: 'Account',
                        children: [
                          _ProfileMenuRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Profile',
                            onTap: () => context.push(RouteNames.userProfileEdit),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            onTap: () => context.push(RouteNames.userChangePassword),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete Account',
                            onTap: () => context.push(RouteNames.userDeleteAccount),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileSection(
                        title: 'Wallet',
                        children: [
                          _ProfileMenuRow(
                            icon: Icons.monetization_on_outlined,
                            label: 'Credits Balance',
                            trailingText: '$balance',
                            onTap: () => context.push(RouteNames.userCredits),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.add_card_outlined,
                            label: 'Buy Credits',
                            onTap: () => context.push(RouteNames.userBuyCredits),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.receipt_long_outlined,
                            label: 'Credits History',
                            onTap: () => context.push(RouteNames.userCreditsHistory),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileSection(
                        title: 'Activity',
                        children: [
                          _ProfileMenuRow(
                            icon: Icons.history_rounded,
                            label: 'Service/Job History',
                            onTap: () => context.push(RouteNames.serviceHistory),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileSection(
                        title: 'Preferences',
                        children: [
                          _ProfileMenuRow(
                            icon: Icons.notifications_outlined,
                            label: 'Notification Settings',
                            onTap: () => context.push(RouteNames.userNotificationSettings),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.language_outlined,
                            label: 'Language',
                            onTap: () => context.push(RouteNames.userLanguage),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.palette_outlined,
                            label: 'Appearance',
                            onTap: () => context.push(RouteNames.userAppearance),
                          ),
                          _ProfileMenuRow(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy',
                            onTap: () => context.push(RouteNames.userPrivacy),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _ProfileSection(
                        title: 'Support',
                        children: [
                          _ProfileMenuRow(
                            icon: Icons.help_outline_rounded,
                            label: AppStrings.drawerHelp,
                            onTap: () => context.push(RouteNames.userHelpSupport),
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ProfileMenuRow(
                        icon: Icons.logout_rounded,
                        label: AppStrings.drawerLogOut,
                        onTap: _signOut,
                        isDestructive: true,
                        isLast: true,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled group of menu rows in one pill-edged card, e.g. "Wallet" ->
/// Credits Balance / Buy Credits / Credits History.
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: AppTypography.captionLarge,
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isLast;

  const _ProfileMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
    this.isDestructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.primary : AppColors.textPrimary;
    final row = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl2, vertical: 16),
        decoration: isDestructive
            ? BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.primaryBorder),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: AppTypography.bodyLarge.copyWith(color: color),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
            if (trailingText != null) ...[
              Text(trailingText!,
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.primary),
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              const SizedBox(width: 6),
            ],
            if (!isDestructive)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textDisabled, size: 18),
          ],
        ),
      ),
    );
    if (isDestructive || isLast) return row;
    return Column(
      children: [
        row,
        const Divider(height: 1, color: AppColors.borderSubtle),
      ],
    );
  }
}

/// Mirrors the real layout (centered avatar/name, then sections) so the
/// skeleton never jumps once the real data arrives.
class _ProfileSkeletonView extends StatelessWidget {
  const _ProfileSkeletonView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.xl),
      child: Column(
        children: [
          AppSkeleton.circle(size: 84),
          SizedBox(height: 12),
          AppSkeleton(width: 140, height: 16, radius: AppRadius.xs),
          SizedBox(height: 8),
          AppSkeleton(width: 90, height: 11, radius: AppRadius.xs),
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
