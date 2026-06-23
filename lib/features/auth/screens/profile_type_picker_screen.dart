// Profile Type Picker — shown after onboarding or after tapping
// "Create Account" / "Get Started".
// User selects Car Owner or Mechanic before signing up.
// Photo bleeds from top with gradient fade into dark background.
// "Who are you?" title with "you?" in red.
// Two selectable cards — tapping one activates it with red border.
// Continue button activates once a type is selected.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';

enum _ProfileType { carOwner, mechanic }

class ProfileTypePickerScreen extends StatefulWidget {
  const ProfileTypePickerScreen({super.key});

  @override
  State<ProfileTypePickerScreen> createState() =>
      _ProfileTypePickerScreenState();
}

class _ProfileTypePickerScreenState extends State<ProfileTypePickerScreen> {
  _ProfileType? _selected;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  void _continue() {
    if (_selected == null) return;
    if (_selected == _ProfileType.carOwner) {
      context.go(RouteNames.userSignupStepOne);
    } else {
      context.go(RouteNames.mechanicSignupStepOne);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Photo bleeding from top ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Stack(
              children: [
                Image.asset(
                  // Uses onboarding_1 image as the background photo
                  'assets/images/onboarding_1.png',
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                // Gradient fade to dark
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x80000000),
                        AppColors.background,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Safe area content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Space for photo area
                const SizedBox(height: 160),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      0,
                      AppSpacing.pageHorizontal,
                      32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Title ──────────────────────────────────────────
                        RichText(
                          text: TextSpan(
                            style: AppTypography.display,
                            children: const [
                              TextSpan(text: 'Who are '),
                              TextSpan(
                                text: 'you?',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.profileTypeSubtitle,
                          style: AppTypography.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 22),

                        // ─── Car Owner card ──────────────────────────────────
                        _TypeCard(
                          title: AppStrings.profileTypeCarOwner,
                          subtitle: AppStrings.profileTypeCarOwnerSub,
                          isSelected: _selected == _ProfileType.carOwner,
                          onTap: () =>
                              setState(() => _selected = _ProfileType.carOwner),
                        ),
                        const SizedBox(height: 10),

                        // ─── Mechanic card ───────────────────────────────────
                        _TypeCard(
                          title: AppStrings.profileTypeMechanic,
                          subtitle: AppStrings.profileTypeMechanicSub,
                          isSelected: _selected == _ProfileType.mechanic,
                          onTap: () =>
                              setState(() => _selected = _ProfileType.mechanic),
                        ),

                        const Spacer(),

                        // ─── Continue button ─────────────────────────────────
                        AppButton(
                          label: AppStrings.profileTypeContinue,
                          // Disabled until a type is selected
                          onTap: _selected != null ? _continue : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Type Card ─────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primarySubtle
              : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading3.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXSmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            // Selection indicator circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderActive,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}