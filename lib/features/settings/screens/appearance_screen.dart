// Appearance screen — theme and text size settings.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/system_ui_style.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _theme = 'Dark';
  double _textSize = 2;

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
                  onTap: () => context.go(RouteNames.userSettings),
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
                const Expanded(child: Text(AppStrings.appearanceTitle,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(AppStrings.appearanceTheme,
                        style: AppTypography.bodyLarge,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 12),
                    Row(children: ['Dark', 'Light'].map((t) {
                      final isSelected = t == _theme;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _theme = t),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: t == 'Dark' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primarySubtle
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border)),
                            child: Center(child: Text(t,
                                style: AppTypography.body.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1)),
                          ),
                        ),
                      );
                    }).toList()),
                    const SizedBox(height: 28),
                    const Text(AppStrings.appearanceTextSize,
                        style: AppTypography.bodyLarge,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.primary,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _textSize,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (v) => setState(() => _textSize = v),
                      ),
                    ),
                    const Center(child: Text(AppStrings.appearanceDefault,
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis, maxLines: 1)),
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