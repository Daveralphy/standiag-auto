// Mechanic Signup Step One — first name, last name, gender, date of birth.
// Identical structure to user signup step one but routes to mechanic step two.

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

class MechanicSignupStepOneScreen extends StatefulWidget {
  const MechanicSignupStepOneScreen({super.key});

  @override
  State<MechanicSignupStepOneScreen> createState() =>
      _MechanicSignupStepOneScreenState();
}

class _MechanicSignupStepOneScreenState
    extends State<MechanicSignupStepOneScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
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
                    onTap: () => context.go(RouteNames.profileTypePicker),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mechanic Signup',
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        Text('Step 1 of 3',
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
                        color: i == 0
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
                    const Text('Tell us about\nyourself',
                        style: AppTypography.display,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    const Text('Fill in your personal details to get started.',
                        style: AppTypography.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 28),
                    AppTextField(
                        label: AppStrings.fieldFirstName,
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldLastName,
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldGender,
                        controller: _genderController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldDob,
                        controller: _dobController,
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Continue',
                      onTap: () =>
                          context.go(RouteNames.mechanicSignupStepTwo),
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