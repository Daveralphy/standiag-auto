import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class UserSignupStepOneScreen extends StatefulWidget {
  const UserSignupStepOneScreen({super.key});

  @override
  State<UserSignupStepOneScreen> createState() =>
      _UserSignupStepOneScreenState();
}

class _UserSignupStepOneScreenState extends State<UserSignupStepOneScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
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
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.30,
            child: Stack(
              children: [
                Image.asset('assets/images/onboarding_1.png',
                    width: double.infinity, height: double.infinity,
                    fit: BoxFit.cover, alignment: Alignment.topCenter),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x80000000), Colors.transparent,
                        Color(0xA60A0A0A), AppColors.background,
                      ],
                      stops: [0.0, 0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(RouteNames.profileTypePicker),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x14FFFFFF)),
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 11, color: Colors.white),
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
                      const SizedBox(
                        width: 28,
                        child: Text('1 of 3',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0x4DFFFFFF),
                            )),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 30,
                            fontWeight: FontWeight.w900, color: Colors.white,
                            height: 1.12, letterSpacing: -1,
                          ),
                          children: [
                            TextSpan(text: 'Tell us about\n'),
                            TextSpan(text: 'yourself.',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'We need a few personal details to get started.',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          color: Color(0x47FFFFFF), fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: _FloatingField(
                            label: 'First Name',
                            hint: 'Enter your first name',
                            controller: _firstNameController,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _FloatingField(
                            label: 'Last Name',
                            hint: 'Enter your last name',
                            controller: _lastNameController,
                          )),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Gender — plain dropdown, no floating label on border
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0x0AFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _gender,
                            hint: const Text('Select your gender',
                                style: TextStyle(
                                  fontFamily: 'Inter', fontSize: 15,
                                  color: Color(0x66FFFFFF),
                                  fontWeight: FontWeight.w400,
                                )),
                            dropdownColor: const Color(0xFF161616),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0x4DFFFFFF), size: 20),
                            style: const TextStyle(
                              fontFamily: 'Inter', fontSize: 15,
                              color: Colors.white, fontWeight: FontWeight.w400,
                            ),
                            isExpanded: true,
                            items: ['Male', 'Female', 'Prefer not to say']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
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
                      _PrimaryButton(
                        label: 'Continue',
                        onTap: () => context.go(RouteNames.userSignupStepTwo),
                      ),
                    ],
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
        color: active ? AppColors.primary : const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: active
            ? [BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.7),
                blurRadius: 8)]
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
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 16,
        color: Colors.white, fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 15,
          color: Color(0x66FFFFFF), fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 13,
          color: AppColors.primary, fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 15,
          color: Color(0x40FFFFFF), fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: const Color(0x0AFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFF03328), Color(0xFFC41F16)],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x99820F0A), blurRadius: 8,
                offset: Offset(0, 4)),
            BoxShadow(color: Color(0x40C81E14), blurRadius: 16,
                offset: Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 17,
                fontWeight: FontWeight.w700, color: Colors.white,
                letterSpacing: -0.3,
              )),
        ),
      ),
    );
  }
}