import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/signup_draft_provider.dart';

class UserSignupStepOneScreen extends ConsumerStatefulWidget {
  const UserSignupStepOneScreen({super.key});

  @override
  ConsumerState<UserSignupStepOneScreen> createState() =>
      _UserSignupStepOneScreenState();
}

class _UserSignupStepOneScreenState
    extends ConsumerState<UserSignupStepOneScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  final _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _gender == null ||
        _dobController.text.trim().isEmpty) {
      AppErrorToast.showMessage(
        context,
        'Please fill in every field to continue.',
      );
      return;
    }
    ref
        .read(signupDraftProvider.notifier)
        .updateUserStepOne(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          gender: _gender!,
          dob: _dobController.text.trim(),
        );
    context.push(RouteNames.userSignupStepTwo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(RouteNames.profileTypePicker);
                      }
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 11,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StepDot(active: true),
                        SizedBox(width: 5),
                        _StepDot(active: false),
                        SizedBox(width: 5),
                        _StepDot(active: false),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '1 of 3',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTag,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.12,
                          letterSpacing: -1,
                        ),
                        children: [
                          const TextSpan(text: 'Tell us about\n'),
                          TextSpan(
                            text: 'yourself.',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We need a few personal details to get started.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _FloatingField(
                            label: 'First Name',
                            hint: 'Enter your first name',
                            controller: _firstNameController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _FloatingField(
                            label: 'Last Name',
                            hint: 'Enter your last name',
                            controller: _lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Gender — plain dropdown, no floating label on border
                    Container(
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderActive),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          hint: Text(
                            'Select your gender',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          dropdownColor: AppColors.surfaceElevated,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textTag,
                            size: 20,
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                          isExpanded: true,
                          items: ['Male', 'Female', 'Prefer not to say']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _FloatingField(
                      label: 'Date of Birth',
                      hint: 'Select your date of birth',
                      controller: _dobController,
                      keyboardType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 28),
                    _PrimaryButton(label: 'Continue', onTap: _continue),
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

class _StepDot extends StatelessWidget {
  final bool active;
  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 28 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.borderActive,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}

class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.textDim,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.borderSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderActive),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderActive),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      cursorColor: AppColors.primary,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              color: Color(0x99820F0A),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x40C81E14),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
