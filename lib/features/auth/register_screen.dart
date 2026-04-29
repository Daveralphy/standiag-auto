import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen_step2.dart';
import 'register_helpers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _next() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    if (firstName.isEmpty || lastName.isEmpty) {
      AppToast.error(context, 'Please enter your full name.');
      return;
    }
    ref.read(registrationProvider.notifier).setStep1(firstName, lastName);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreenStep2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(0.25),
              const SizedBox(height: 24),
              buildHeading("What's your", 'name?'),
              const SizedBox(height: 6),
              const Text("This is how you'll appear on your account.",
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              AppField(
                label: 'First Name',
                hint: 'Enter your first name',
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),
              AppField(
                label: 'Last Name',
                hint: 'Enter your last name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 8),
              const Text('Use the name on your official ID.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 28),
              primaryButton('NEXT', _next),
            ],
          ),
        ),
      ),
    );
  }
}
