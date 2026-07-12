// Mechanic Drawer screen — side drawer for mechanics.
// Shows profile summary, navigation links, and logout option.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/log_out_dialog.dart';

class MechanicDrawerScreen extends ConsumerStatefulWidget {
  const MechanicDrawerScreen({super.key});

  @override
  ConsumerState<MechanicDrawerScreen> createState() =>
      _MechanicDrawerScreenState();
}

class _MechanicDrawerScreenState extends ConsumerState<MechanicDrawerScreen> {
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
        : (authUser?.email?.split('@').first ?? 'Mechanic');
    final email = authUser?.email ?? '';

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.xl,
                  AppSpacing.pageHorizontal, AppSpacing.xl),
              child: Row(
                children: [
                  AppAvatar(name: displayName, size: 60),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: 3),
                        Text(email.isNotEmpty ? email : '@mechanic',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 24),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: AppStrings.drawerProfile,
                    onTap: () => context.push(RouteNames.mechanicProfileView),
                  ),
                  _DrawerItem(
                    icon: Icons.work_outline_rounded,
                    label: AppStrings.drawerMyJobs,
                    onTap: () => context.push(RouteNames.myJobs),
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    label: AppStrings.drawerJobHistory,
                    onTap: () => context.push(RouteNames.jobHistory),
                  ),
                  _DrawerItem(
                    icon: Icons.monetization_on_outlined,
                    label: AppStrings.drawerCredits,
                    onTap: () => context.push(RouteNames.mechanicCredits),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: AppStrings.drawerSettings,
                    onTap: () => context.push(RouteNames.mechanicSettings),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: AppStrings.drawerHelp,
                    onTap: () => context.push(RouteNames.mechanicHelpSupport),
                  ),
                ],
              ),
            ),
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
            horizontal: AppSpacing.pageHorizontal, vertical: 16),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: isDestructive
                    ? AppColors.primary
                    : AppColors.textMuted),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
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