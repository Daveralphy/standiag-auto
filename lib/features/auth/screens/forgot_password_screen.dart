// Forgot Password screen — user enters their email; if an account exists
// with that email, Firebase sends a password reset link to it.
//
// Note: the reset link opens Firebase's own hosted reset page in a browser,
// not this app directly — making it reopen the app requires domain-verified
// App Links/Universal Links, which is real infrastructure (a verified
// domain + native config) this build doesn't have set up. Once the user
// resets their password there, they come back and sign in normally.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/auth_floating_field.dart';
import '../../../shared/widget/system_ui_style.dart';

/// Forgot Password screen — request a reset link by email.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _emailError = null);
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).sendPasswordReset(email);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _sent = true;
      });
    } catch (error, stackTrace) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = ErrorHandler.handle(error, stackTrace).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: _sent ? _buildSentState() : _buildFormState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Forgot your\npassword?',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 30,
            fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            height: 1.12, letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the email on your account and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            color: AppColors.textSecondary, height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        AuthFloatingField(
          label: 'Email Address',
          hint: 'Enter your email address',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isLoading,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _isLoading ? null : _submit,
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
              child: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Send Reset Link',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w700, color: Colors.white,
                        letterSpacing: -0.3,
                      )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: Icon(Icons.mail_outline_rounded,
              color: AppColors.primary, size: 26),
        ),
        const SizedBox(height: 20),
        Text(
          'Check your email',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 26,
            fontWeight: FontWeight.w900, color: AppColors.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text.trim()}. Open it to set a new password, then come back here and sign in.',
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 15,
            color: AppColors.textSecondary, height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => context.go(RouteNames.login),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: AppColors.borderActive),
            ),
            child: Center(
              child: Text('Back to Sign In',
                  style: AppTypography.button),
            ),
          ),
        ),
      ],
    );
  }
}
