import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/providers/auth_provider.dart';
import 'register_screen.dart';
import 'register_screen_step3.dart';
import 'register_helpers.dart';

class RegisterScreenStep2 extends ConsumerStatefulWidget {
  const RegisterScreenStep2({super.key});

  @override
  ConsumerState<RegisterScreenStep2> createState() =>
      _RegisterScreenStep2State();
}

class _RegisterScreenStep2State
    extends ConsumerState<RegisterScreenStep2> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCountry = '+234';
  String? _errorMessage;

  final List<String> _countryCodes = [
    '+234', '+1', '+44', '+91', '+86',
    '+81', '+33', '+49', '+27', '+254',
    '+233', '+225',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _next() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() =>
          _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() =>
          _errorMessage = 'Please enter a valid email address.');
      return;
    }
    ref.read(registrationProvider.notifier).setStep2(
        email, _phoneController.text.trim(), _selectedCountry);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const RegisterScreenStep3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const RegisterScreen()),
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.50),
              const SizedBox(height: 24),
              buildHeading('How do we', 'reach you?'),
              const SizedBox(height: 6),
              const Text("We'll never share your contact details.",
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              AppField(
                label: 'Email Address',
                hint: 'Enter your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Phone with country code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PHONE NUMBER',
                      style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCountry,
                          dropdownColor: AppColors.surfaceCard,
                          style: AppTextStyles.inputText,
                          onChanged: (v) {
                            if (v != null) {
                              setState(
                                  () => _selectedCountry = v);
                            }
                          },
                          items: _countryCodes
                              .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: AppTextStyles.hintText,
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  const Text(
                      'Your phone number is used for account recovery.',
                      style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 32),
              primaryButton('CONTINUE', _next),
            ],
          ),
        ),
      ),
    );
  }
}

