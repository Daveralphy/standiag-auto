// Notification Settings screen — toggle notification preferences.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _jobUpdates = true;
  bool _promotions = false;
  bool _newMechanics = true;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(child: Text(AppStrings.notificationsTitle,
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
                  _ToggleItem(
                    label: 'Job Updates',
                    subtitle: 'Get notified about your job status',
                    value: _jobUpdates,
                    onChanged: (v) => setState(() => _jobUpdates = v),
                  ),
                  _ToggleItem(
                    label: 'Promotions',
                    subtitle: 'Offers and credit bonuses',
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                  ),
                  _ToggleItem(
                    label: 'New Mechanics',
                    subtitle: 'When new mechanics join your area',
                    value: _newMechanics,
                    onChanged: (v) => setState(() => _newMechanics = v),
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

class _ToggleItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.label, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(
            color: AppColors.borderSubtle, width: 1))),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.body,
                overflow: TextOverflow.ellipsis, maxLines: 1),
            Text(subtitle, style: AppTypography.caption,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        )),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primarySubtle,
          inactiveTrackColor: const Color(0x1FFFFFFF),
          inactiveThumbColor: AppColors.textMuted,
        ),
      ]),
    );
  }
}