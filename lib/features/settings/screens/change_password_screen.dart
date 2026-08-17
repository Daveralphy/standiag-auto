// Change Password screen — current, new, confirm password fields with strength bar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _newController.addListener(() {
      setState(() =>
          _strength = Validators.passwordStrength(_newController.text));
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _continue() {
    final current = _currentController.text;
    final next = _newController.text;
    if (current.isEmpty || next.length < 6) {
      AppErrorToast.showMessage(context,
          'Enter your current password and a new one of at least 6 characters.');
      return;
    }
    if (next != _confirmController.text) {
      AppErrorToast.showMessage(context, 'New passwords do not match.');
      return;
    }
    final type = ref.read(currentUserTypeProvider);
    context.push(RouteNames.verifyPasswordChangeFor(type),
        extra: {'current': current, 'new': next});
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1: return Colors.redAccent;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return AppColors.success;
      default: return AppColors.borderSubtle;
    }
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
                Expanded(child: Text(AppStrings.changePasswordTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal, 20,
                    AppSpacing.pageHorizontal, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.changePasswordSubtitle,
                        style: AppTypography.body,
                        maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 24),
                    AppTextField(label: AppStrings.changePasswordCurrent,
                        controller: _currentController,
                        obscureText: true,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.changePasswordNew,
                        controller: _newController,
                        obscureText: true,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 10),
                    if (_newController.text.isNotEmpty) ...[
                      Row(children: [
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: _strength / 4,
                            backgroundColor: AppColors.borderSubtle,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _strengthColor),
                            minHeight: 3,
                          ),
                        )),
                        const SizedBox(width: 8),
                        Text(Validators.passwordStrengthLabel(_strength),
                            style: AppTypography.captionSmall.copyWith(
                                color: _strengthColor),
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ]),
                      const SizedBox(height: 10),
                    ],
                    AppTextField(label: AppStrings.changePasswordConfirm,
                        controller: _confirmController,
                        obscureText: true,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: AppStrings.changePasswordSave,
                      onTap: _continue,
                    ),
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