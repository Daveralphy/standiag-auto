// Settings screen — list of settings options with navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/system_ui_style.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
    final type = ref.watch(currentUserTypeProvider);
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
                  onTap: () => context.go(RouteNames.homeFor(type)),
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
                const Expanded(child: Text(AppStrings.settingsTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                children: [
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: AppStrings.settingsNotifications,
                    onTap: () =>
                        context.go(RouteNames.notificationSettingsFor(type)),
                  ),
                  _SettingsItem(
                    icon: Icons.language_outlined,
                    label: AppStrings.settingsLanguage,
                    onTap: () => context.go(RouteNames.languageFor(type)),
                  ),
                  _SettingsItem(
                    icon: Icons.dark_mode_outlined,
                    label: AppStrings.settingsAppearance,
                    onTap: () => context.go(RouteNames.appearanceFor(type)),
                  ),
                  _SettingsItem(
                    icon: Icons.lock_outline_rounded,
                    label: AppStrings.settingsPrivacy,
                    onTap: () => context.go(RouteNames.privacyFor(type)),
                  ),
                  _SettingsItem(
                    icon: Icons.key_outlined,
                    label: AppStrings.settingsChangePassword,
                    onTap: () =>
                        context.go(RouteNames.changePasswordFor(type)),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 8),
                  _SettingsItem(
                    icon: Icons.delete_outline_rounded,
                    label: AppStrings.settingsDeleteAccount,
                    onTap: () =>
                        context.go(RouteNames.deleteAccountFor(type)),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon, required this.label,
    required this.onTap, this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(
              color: AppColors.borderSubtle, width: 1))),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.primarySubtle
                  : const Color(0x0DFFFFFF),
              borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: Icon(icon,
                color: isDestructive ? AppColors.primary : AppColors.textMuted,
                size: 16)),
          const SizedBox(width: 13),
          Expanded(child: Text(label,
              style: AppTypography.body.copyWith(
                  color: isDestructive
                      ? AppColors.primary
                      : AppColors.textSecondary),
              overflow: TextOverflow.ellipsis, maxLines: 1)),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textDisabled, size: 18),
        ]),
      ),
    );
  }
}