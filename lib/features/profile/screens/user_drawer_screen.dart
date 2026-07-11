// User Drawer screen — side drawer for car owners.
// Shows profile summary, navigation links, and logout option.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/log_out_dialog.dart';

class UserDrawerScreen extends ConsumerStatefulWidget {
  const UserDrawerScreen({super.key});

  @override
  ConsumerState<UserDrawerScreen> createState() => _UserDrawerScreenState();
}

class _UserDrawerScreenState extends ConsumerState<UserDrawerScreen> {
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
    final authUser = FirebaseAuth.instance.currentUser;
    final displayName = authUser?.displayName?.trim().isNotEmpty == true
        ? authUser!.displayName!.trim()
        : (authUser?.email?.split('@').first ?? 'User');
    final email = authUser?.email ?? '';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.xl,
                  AppSpacing.pageHorizontal, AppSpacing.xl),
              child: Row(
                children: [
                  AppAvatar(name: displayName, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text(email.isNotEmpty ? email : '@user',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle),

            // Nav items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: AppStrings.drawerProfile,
                    onTap: () => context.push(RouteNames.userProfile),
                  ),
                  _DrawerItem(
                    icon: Icons.directions_car_outlined,
                    label: AppStrings.drawerMyVehicles,
                    onTap: () => context.go(RouteNames.myVehicles),
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    label: AppStrings.drawerServiceHistory,
                    onTap: () => context.go(RouteNames.serviceHistory),
                  ),
                  _DrawerItem(
                    icon: Icons.qr_code_scanner_rounded,
                    label: AppStrings.drawerScanHistory,
                    onTap: () => context.go(RouteNames.userScanHistory),
                  ),
                  _DrawerItem(
                    icon: Icons.monetization_on_outlined,
                    label: AppStrings.drawerCredits,
                    onTap: () => context.go(RouteNames.userCredits),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: AppStrings.drawerSettings,
                    onTap: () => context.go(RouteNames.userSettings),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: AppStrings.drawerHelp,
                    onTap: () => context.go(RouteNames.userHelpSupport),
                  ),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 0,
                  AppSpacing.pageHorizontal, AppSpacing.xl),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                label: AppStrings.drawerLogOut,
                onTap: _signOut,
                isDestructive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isDestructive
                    ? AppColors.primary
                    : AppColors.textMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(
                    color: isDestructive
                        ? AppColors.primary
                        : AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}