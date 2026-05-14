import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import '../../core/widgets/app_overlay_dropdown.dart';
import 'register_step_contact.dart';

class RegisterStepDetails extends StatefulWidget {
  final RegisterState state;
  final void Function(RegisterState) onNext;
  final VoidCallback onBack;

  const RegisterStepDetails({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStepDetails> createState() => _RegisterStepDetailsState();
}

class _RegisterStepDetailsState extends State<RegisterStepDetails> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  String? _gender;
  bool _dobConfirmed = false;
  int _dobDay   = 15;
  int _dobMonth = 4;
  int _dobYear  = 1998;

  @override
  void initState() {
    super.initState();
    _firstCtrl.text = widget.state.firstName;
    _lastCtrl.text  = widget.state.lastName;
    _gender = widget.state.gender.isEmpty ? null : widget.state.gender;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_firstCtrl.text.trim().isEmpty ||
        _lastCtrl.text.trim().isEmpty ||
        _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final updated = widget.state.copyWith(
      firstName: _firstCtrl.text.trim(),
      lastName:  _lastCtrl.text.trim(),
      gender:    _gender,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterStepContact(
        state: updated,
        onNext: (s) => widget.onNext(s),
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Future.delayed(const Duration(milliseconds: 100),
                        widget.onBack);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 20),
                _StepTabs(currentStep: 1),
                const SizedBox(height: 40),
                Text('Let\u2019s get to\nknow you',
                    style: AppTypography.h1.copyWith(
                        fontSize: 28, letterSpacing: -0.6, height: 1.15)),
                const SizedBox(height: 8),
                Text('This is how you\u2019ll appear on your account.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                _FloatingField(
                  label: 'First Name',
                  hint: 'Enter first name',
                  controller: _firstCtrl,
                  icon: Icons.person_outline_rounded,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: 22),
                _FloatingField(
                  label: 'Last Name',
                  hint: 'Enter last name',
                  controller: _lastCtrl,
                  icon: Icons.person_outline_rounded,
                  inputAction: TextInputAction.done,
                ),
                const SizedBox(height: 22),
                AppSearchDropdown(
                  label: 'Gender',
                  hint: 'Select gender',
                  value: _gender,
                  icon: Icons.person_outline_rounded,
                  items: const ['Male', 'Female', 'Other'],
                  onSelected: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 22),
                AppDobDropdown(
                  label: 'Date of Birth',
                  day: _dobDay,
                  month: _dobMonth,
                  year: _dobYear,
                  confirmed: _dobConfirmed,
                  onChanged: (d, m, y) => setState(() {
                    _dobDay = d;
                    _dobMonth = m;
                    _dobYear = y;
                    _dobConfirmed = true;
                  }),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.lgAll,
                      boxShadow: AppShadows.primaryGlow,
                    ),
                    child: Center(
                      child: Text('NEXT',
                          style: AppTypography.button.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step tabs ─────────────────────────────────────────────────────
class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});
  static const _labels = [
    'Getting\nStarted', 'Your\nDetails', 'Contact\nInfo',
    'Vehicle /\nExpertise', 'Your\nIdentity',
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentStep;
        final isDone   = i < currentStep;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 24 : 8, height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : isDone
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : AppColors.border,
                      borderRadius: isActive
                          ? AppRadius.smAll
                          : AppRadius.fullAll,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_labels[i],
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 10, height: 1.3)),
                ]),
              ),
              if (i < _labels.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 8, height: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Floating label field ──────────────────────────────────────────
class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputAction inputAction;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.inputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textTertiary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: inputAction,
                style: AppTypography.body
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ]),
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}