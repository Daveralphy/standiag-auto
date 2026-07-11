// User Signup Step Three — username, password, confirm password.
// Back navigates to step two. Create Account completes signup.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/signup_draft_provider.dart';

class UserSignupStepThreeScreen extends ConsumerStatefulWidget {
  const UserSignupStepThreeScreen({super.key});

  @override
  ConsumerState<UserSignupStepThreeScreen> createState() =>
      _UserSignupStepThreeScreenState();
}

class _UserSignupStepThreeScreenState
    extends ConsumerState<UserSignupStepThreeScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

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
    if (username.isEmpty || password.length < 6) {
      AppErrorToast.showMessage(
          context, 'Choose a username and a password of at least 6 characters.');
      return;
    }
    if (password != _confirmController.text) {
      AppErrorToast.showMessage(context, 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    ref
        .read(signupDraftProvider.notifier)
        .updateCredentials(username: username, password: password);

    try {
      await ref.read(authControllerProvider).signUp(ref.read(signupDraftProvider));
      if (!mounted) return;
      context.go(RouteNames.otpEmail);
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppErrorToast.showMessage(
        context,
        ErrorHandler.handle(error, stackTrace).message,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                Image.asset('assets/images/onboarding_3.png',
                    width: double.infinity, height: double.infinity,
                    fit: BoxFit.cover, alignment: Alignment.topCenter),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                        onTap: () => context.go(RouteNames.userSignupStepTwo),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x14FFFFFF)),
                          ),
                          child: const Center(child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 11, color: Colors.white)),
                        ),
                      ),
                      const Expanded(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StepDot(active: false),
                            SizedBox(width: 5),
                            _StepDot(active: false),
                            SizedBox(width: 5),
                            _StepDot(active: true),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 28,
                        child: Text('3 of 3',
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
                      Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                            TextSpan(text: 'Secure your\n'),
                            TextSpan(text: 'account.',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose a username and a strong password.',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          color: Color(0x47FFFFFF), height: 1.5,
                        ),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 22),
                      _FloatingField(
                        label: 'Username',
                        hint: 'Choose a username',
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 22),
                      _FloatingField(
                        label: 'Password',
                        hint: 'Create a password',
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _showPassword = !_showPassword),
                          child: Icon(
                            _showPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 14,
                            color: const Color(0x66FFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _FloatingField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        controller: _confirmController,
                        obscureText: !_showConfirm,
                        suffix: GestureDetector(
                          onTap: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          child: Icon(
                            _showConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 14,
                            color: const Color(0x66FFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _PrimaryButton(
                        label: 'Create Account',
                        onTap: _createAccount,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
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

// ─── Shared Widgets ────────────────────────────────────────────────────────

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
  final bool obscureText;
  final Widget? suffix;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        fontFamily: 'Inter', fontSize: 16,
        color: Colors.white, fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 15,
          color: Color(0x80FFFFFF), fontWeight: FontWeight.w500,
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
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(
            minWidth: 40, minHeight: 48),
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
  final bool isLoading;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            BoxShadow(color: Color(0x1AE8281E), blurRadius: 24,
                offset: Offset(0, 10)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w700, color: Colors.white,
                    letterSpacing: -0.3,
                  )),
        ),
      ),
    );
  }
}