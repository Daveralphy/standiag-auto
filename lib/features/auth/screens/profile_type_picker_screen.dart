// Profile Type Picker — photo bleeds top 180px, "Who are you?" headline,
// two selectable cards (Car Owner / Mechanic), Continue button at bottom.
// Back button top-left navigates to login.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../models/user_model.dart';
import '../providers/signup_draft_provider.dart';

enum _ProfileType { carOwner, mechanic }

class ProfileTypePickerScreen extends ConsumerStatefulWidget {
  const ProfileTypePickerScreen({super.key});

  @override
  ConsumerState<ProfileTypePickerScreen> createState() =>
      _ProfileTypePickerScreenState();
}

class _ProfileTypePickerScreenState
    extends ConsumerState<ProfileTypePickerScreen> {
  _ProfileType _selected = _ProfileType.carOwner;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  void _continue() {
    if (_selected == _ProfileType.carOwner) {
      ref.read(signupDraftProvider.notifier).setType(UserType.carOwner);
      context.push(RouteNames.userSignupStepOne);
    } else {
      ref.read(signupDraftProvider.notifier).setType(UserType.mechanic);
      context.push(RouteNames.mechanicSignupStepOne);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button — top left
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: GestureDetector(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.login);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Bottom content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                      children: [
                        TextSpan(
                          text: 'Who are ',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        TextSpan(
                          text: 'you?',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your account type to get started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textTag,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Car Owner card
                  _TypeCard(
                    title: 'Car Owner',
                    subtitle: 'I need a mechanic',
                    selected: _selected == _ProfileType.carOwner,
                    onTap: () =>
                        setState(() => _selected = _ProfileType.carOwner),
                  ),
                  const SizedBox(height: 12),

                  // Mechanic card
                  _TypeCard(
                    title: 'Mechanic',
                    subtitle: 'I fix cars',
                    selected: _selected == _ProfileType.mechanic,
                    onTap: () =>
                        setState(() => _selected = _ProfileType.mechanic),
                  ),
                  const SizedBox(height: 24),

                  // Continue button
                  GestureDetector(
                    onTap: _continue,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF03328), Color(0xFFC41F16)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x38E8281E),
                            blurRadius: 20,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
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

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: selected ? AppColors.textMuted : AppColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderActive,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
