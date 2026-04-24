import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import 'register_screen_step2.dart';
import 'register_screen_step4.dart';

class RegisterScreenStep3 extends ConsumerStatefulWidget {
  const RegisterScreenStep3({super.key});

  @override
  ConsumerState<RegisterScreenStep3> createState() =>
      _RegisterScreenStep3State();
}

class _RegisterScreenStep3State
    extends ConsumerState<RegisterScreenStep3> {
  late TextEditingController _ageController;
  String? _selectedGender;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_selectedGender == null) {
      setState(() => _errorMessage = 'Please select your gender.');
      return;
    }
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      setState(() => _errorMessage = 'Please enter your age.');
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age < 18) {
      setState(() =>
          _errorMessage = 'You must be at least 18 years old to use StanDiag.');
      return;
    }

    ref
        .read(registrationProvider.notifier)
        .setStep3(_selectedGender!, age);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreenStep4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = sw / 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16 * s),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: 22 * s),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (_) => const RegisterScreenStep2()),
            ),
            padding: EdgeInsets.zero,
            constraints:
                BoxConstraints(minWidth: 32 * s, minHeight: 32 * s),
          ),
        ),
        leadingWidth: 56 * s,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 24 * s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2 * s),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: const Color(0xFF2A2A2E),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                  ),
                ),
              ),
              SizedBox(height: 20 * s),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Tell us a bit\n',
                      style: TextStyle(
                        fontSize: 40 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    TextSpan(
                      text: 'more about you.',
                      style: TextStyle(
                        fontSize: 40 * s,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Inter',
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * s),
              Text('This helps us personalise your experience.',
                  style: TextStyle(
                    fontSize: 17 * s,
                    color: const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 28 * s),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12 * s),
                  decoration: BoxDecoration(
                    color: AppColors.criticalBg,
                    borderRadius: BorderRadius.circular(8 * s),
                    border: Border.all(color: AppColors.criticalBorder),
                  ),
                  child: Text(_errorMessage!,
                      style: TextStyle(
                        fontSize: 13 * s,
                        color: AppColors.primaryLight,
                        fontFamily: 'Inter',
                      )),
                ),
                SizedBox(height: 16 * s),
              ],

              Text('GENDER',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  _GenderButton(
                    s: s,
                    label: 'Male',
                    icon: Icons.male,
                    value: 'male',
                    selected: _selectedGender,
                    onTap: (v) =>
                        setState(() => _selectedGender = v),
                  ),
                  SizedBox(width: 12 * s),
                  _GenderButton(
                    s: s,
                    label: 'Female',
                    icon: Icons.female,
                    value: 'female',
                    selected: _selectedGender,
                    onTap: (v) =>
                        setState(() => _selectedGender = v),
                  ),
                  SizedBox(width: 12 * s),
                  _GenderButton(
                    s: s,
                    label: 'Other',
                    icon: Icons.more_horiz,
                    value: 'other',
                    selected: _selectedGender,
                    onTap: (v) =>
                        setState(() => _selectedGender = v),
                  ),
                ],
              ),
              SizedBox(height: 24 * s),
              Text('AGE',
                  style: TextStyle(
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF999999),
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  )),
              SizedBox(height: 8 * s),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 16 * s,
                    color: Colors.white,
                    fontFamily: 'Inter'),
                decoration: InputDecoration(
                  hintText: 'Enter your age',
                  hintStyle: TextStyle(
                      fontSize: 16 * s,
                      color: const Color(0xFF555555),
                      fontFamily: 'Inter'),
                  filled: true,
                  fillColor: const Color(0xFF161619),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8 * s),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16 * s, vertical: 16 * s),
                  suffixText: 'years old',
                  suffixStyle: TextStyle(
                    fontSize: 14 * s,
                    color: const Color(0xFF666666),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              SizedBox(height: 10 * s),
              Text(
                'You must be at least 18 years old to use StanDiag.',
                style: TextStyle(
                  fontSize: 13 * s,
                  color: const Color(0xFF666666),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32 * s),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 16 * s),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8 * s),
                    ),
                    elevation: 0,
                  ),
                  child: Text('CONTINUE',
                      style: TextStyle(
                        fontSize: 17 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final double s;
  final String label, value;
  final IconData icon;
  final String? selected;
  final ValueChanged<String> onTap;

  const _GenderButton({
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
        onTap: () => onTap(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * s),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFF161619),
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFF2A2A2E),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF666666),
                  size: 18 * s),
              SizedBox(width: 8 * s),
              Text(label,
                  style: TextStyle(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF999999),
                    fontFamily: 'Inter',
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
