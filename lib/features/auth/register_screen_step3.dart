import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/auth_provider.dart';
import 'register_screen_step2.dart';
import 'register_screen_step4.dart';
import 'register_helpers.dart';

class RegisterScreenStep3 extends ConsumerStatefulWidget {
  const RegisterScreenStep3({super.key});

  @override
  ConsumerState<RegisterScreenStep3> createState() =>
      _RegisterScreenStep3State();
}

class _RegisterScreenStep3State
    extends ConsumerState<RegisterScreenStep3> {
  final _ageController = TextEditingController();
  String? _selectedGender;
  String? _errorMessage;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_selectedGender == null) {
      setState(
          () => _errorMessage = 'Please select your gender.');
      return;
    }
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      setState(() => _errorMessage = 'Please enter your age.');
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 18) {
      setState(() => _errorMessage =
          'You must be at least 18 years old to use StanDiag.');
      return;
    }
    ref
        .read(registrationProvider.notifier)
        .setStep3(_selectedGender!, age);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const RegisterScreenStep4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const RegisterScreenStep2()),
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.75),
              const SizedBox(height: 24),
              buildHeading('Tell us a bit', 'more about you.'),
              const SizedBox(height: 6),
              const Text(
                  'This helps us personalise your experience.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              // Gender label
              const Text('GENDER',
                  style: AppTextStyles.fieldLabel),
              const SizedBox(height: 10),
              Row(children: [
                _GenderBtn(
                  s: 1.0,
                  label: 'Male',
                  icon: Icons.male,
                  value: 'male',
                  selected: _selectedGender,
                  onTap: (v) =>
                      setState(() => _selectedGender = v),
                ),
                const SizedBox(width: 10),
                _GenderBtn(
                  s: 1.0,
                  label: 'Female',
                  icon: Icons.female,
                  value: 'female',
                  selected: _selectedGender,
                  onTap: (v) =>
                      setState(() => _selectedGender = v),
                ),
                const SizedBox(width: 10),
                _GenderBtn(
                  s: 1.0,
                  label: 'Other',
                  icon: Icons.more_horiz,
                  value: 'other',
                  selected: _selectedGender,
                  onTap: (v) =>
                      setState(() => _selectedGender = v),
                ),
              ]),
              const SizedBox(height: 20),
              // Age
              const Text('AGE', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.inputText,
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  hintStyle: AppTextStyles.hintText,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 1.5),
                  ),
                  suffixText: 'years old',
                  suffixStyle: AppTextStyles.caption,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                  'You must be at least 18 years old to use StanDiag.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 32),
              primaryButton('CONTINUE', _next),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderBtn extends StatelessWidget {
  final double s;
  final String label, value;
  final IconData icon;
  final String? selected;
  final ValueChanged<String> onTap;

  const _GenderBtn({
    required this.s,
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
      ),
    );
  }
}


