// Mechanic Signup Step Two — phone, email, workshop address, years of experience.
// Step 2 of 3.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicSignupStepTwoScreen extends StatefulWidget {
  const MechanicSignupStepTwoScreen({super.key});

  @override
  State<MechanicSignupStepTwoScreen> createState() =>
      _MechanicSignupStepTwoScreenState();
}

class _MechanicSignupStepTwoScreenState
    extends State<MechanicSignupStepTwoScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _workshopController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _workshopController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0x12FFFFFF),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mechanic Signup',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        Text('Step 2 of 3',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i <= 1
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workshop\nDetails',
                        style: AppTypography.display,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text('Tell us where you work.',
                        style: AppTypography.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 28),
                    AppTextField(
                        label: AppStrings.fieldPhone,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldWorkshop,
                        controller: _workshopController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldExperience,
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Continue',
                      onTap: () =>
                          context.go(RouteNames.mechanicSignupStepThree),
                    ),
                    const SizedBox(height: 24),
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