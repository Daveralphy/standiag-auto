import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import 'register_screen_step3.dart';
import 'register_helpers.dart';
import '../vehicle/first_vehicle_screen.dart';

class RegisterScreenStep4 extends ConsumerStatefulWidget {
  const RegisterScreenStep4({super.key});

  @override
  ConsumerState<RegisterScreenStep4> createState() =>
      _RegisterScreenStep4State();
}

class _RegisterScreenStep4State
    extends ConsumerState<RegisterScreenStep4> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty) {
      setState(
          () => _errorMessage = 'Please enter a username.');
      return;
    }
    if (username.length < 3) {
      setState(() => _errorMessage =
          'Username must be at least 3 characters.');
      return;
    }
    if (password.isEmpty) {
      setState(
          () => _errorMessage = 'Please enter a password.');
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage =
          'Password must be at least 8 characters.');
      return;
    }
    if (password != confirm) {
      setState(
          () => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final regData = ref.read(registrationProvider);
      final authService = AuthService();

      final response = await authService.signUp(
        email: regData.email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        setState(() => _errorMessage =
            'Account creation failed. Please try again.');
        return;
      }

      if (response.session == null) {
        await authService.signIn(
          emailOrUsername: regData.email,
          password: password,
        );
      }

      await authService.createProfile(
        userId: user.id,
        email: regData.email,
        firstName: regData.firstName,
        lastName: regData.lastName,
        username: username,
        phone: '${regData.countryCode}${regData.phone}',
        gender: regData.gender,
        age: regData.age,
      );

      await NotificationService()
          .createWelcomeNotification(user.id);

      ref.read(registrationProvider.notifier).reset();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (_) => const FirstVehicleScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage =
          'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(context, () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => const RegisterScreenStep3()),
        );
      }),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProgress(1.0),
              const SizedBox(height: 24),
              buildHeading('Secure your', 'account.'),
              const SizedBox(height: 6),
              const Text(
                  'Choose a username and a strong password.',
                  style: AppTextStyles.authSubheading),
              const SizedBox(height: 28),
              if (_errorMessage != null) ...[
                errorBanner(_errorMessage!),
                const SizedBox(height: 16),
              ],
              AppField(
                label: 'Username',
                hint: 'Choose a username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              AppField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                obscure: true,
              ),
              const SizedBox(height: 16),
              AppField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmController,
                obscure: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Password must be at least 8 characters.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 32),
              primaryButton(
                  'CREATE MY ACCOUNT', _createAccount,
                  isLoading: _isLoading),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'By creating an account, you agree to our\nTerms of Service and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

