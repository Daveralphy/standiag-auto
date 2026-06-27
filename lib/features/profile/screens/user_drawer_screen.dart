// User Drawer screen — side drawer for car owners.
// Shows profile summary, navigation links, and logout option.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserDrawerScreen extends StatefulWidget {
  const UserDrawerScreen({super.key});

  @override
  State<UserDrawerScreen> createState() => _UserDrawerScreenState();
}

class _UserDrawerScreenState extends State<UserDrawerScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.xl,
                  AppSpacing.pageHorizontal, AppSpacing.xl),
              child: Row(
                children: [
                  const AppAvatar(name: 'John Doe', size: 52),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('John Doe',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        Text('@johndoe',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.userHome),
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
                    onTap: () => context.go(RouteNames.userProfile),
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
                onTap: () => context.go(RouteNames.onboarding),
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