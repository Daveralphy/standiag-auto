// Mechanic Signup Step Three — username, password, confirm password.
// Same structure as user step three but routes to mechanic home on completion.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicSignupStepThreeScreen extends StatefulWidget {
  const MechanicSignupStepThreeScreen({super.key});

  @override
  State<MechanicSignupStepThreeScreen> createState() =>
      _MechanicSignupStepThreeScreenState();
}

class _MechanicSignupStepThreeScreenState
    extends State<MechanicSignupStepThreeScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int _strength = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _passwordController.addListener(() {
      setState(() =>
          _strength = Validators.passwordStrength(_passwordController.text));
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1:
        return Colors.redAccent;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return AppColors.success;
      default:
        return AppColors.borderSubtle;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(RouteNames.mechanicSignupStepTwo),
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
                        Text('Step 3 of 3',
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
                        color: AppColors.primary,
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
                    const Text('Secure your\nAccount',
                        style: AppTypography.display,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    const Text('Create a username and strong password.',
                        style: AppTypography.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 28),
                    AppTextField(
                        label: AppStrings.fieldUsername,
                        controller: _usernameController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(
                        label: AppStrings.fieldPassword,
                        controller: _passwordController,
                        obscureText: true,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 10),
                    if (_passwordController.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              child: LinearProgressIndicator(
                                value: _strength / 4,
                                backgroundColor: AppColors.borderSubtle,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _strengthColor),
                                minHeight: 3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Validators.passwordStrengthLabel(_strength),
                            style: AppTypography.captionSmall
                                .copyWith(color: _strengthColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    AppTextField(
                        label: AppStrings.fieldConfirmPassword,
                        controller: _confirmController,
                        obscureText: true,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Create Account',
                      onTap: () {
                        setState(() => _isLoading = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) setState(() => _isLoading = false);
                        });
                      },
                      isLoading: _isLoading,
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