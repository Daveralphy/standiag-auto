// Language screen — select app language.

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
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widget/system_ui_style.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  static const List<String> _languages = [
    'English', 'French', 'Yoruba', 'Igbo', 'Hausa', 'Pidgin',
  ];

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
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
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.settingsFor(type));
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(AppStrings.languageTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                itemCount: _languages.length,
                separatorBuilder: (_, __) => Divider(
                    color: AppColors.borderSubtle, height: 1),
                itemBuilder: (_, i) {
                  final lang = _languages[i];
                  final isSelected = lang == settings.language;
                  return GestureDetector(
                    onTap: () => ref.read(settingsProvider.notifier).setLanguage(lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(children: [
                        Expanded(child: Text(lang,
                            style: AppTypography.body.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis, maxLines: 1)),
                        if (isSelected)
                          Icon(Icons.check_rounded,
                              color: AppColors.primary, size: 18),
                      ]),
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
