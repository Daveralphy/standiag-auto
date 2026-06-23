// Login screen — shared entry for both car owners and mechanics.
// Username/email field, password field with eye toggle,
// forgot password link, login button, phone login option,
// social login buttons (Google, Apple), and sign up link.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    super.dispose();
  }

  void _login() {
    // Auth logic goes in auth_provider — stub for now
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───────────────────────────────────────────────────
              Text(
                AppStrings.login,
                style: AppTypography.display,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back to StanDiag Auto.',
                style: AppTypography.body,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              // ─── Fields ───────────────────────────────────────────────────
              AppTextField(
                label: AppStrings.loginUsername,
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppStrings.loginPassword,
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: _login,
              ),
              const SizedBox(height: 12),

              // ─── Forgot password ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    AppStrings.loginForgotPassword,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Login button ─────────────────────────────────────────────
              AppButton(
                label: AppStrings.login,
                onTap: _login,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),

              // ─── Phone login ──────────────────────────────────────────────
              AppButton(
                label: AppStrings.loginWithPhone,
                onTap: () => context.go(RouteNames.otpPhone),
                variant: AppButtonVariant.ghost,
              ),
              const SizedBox(height: 24),

              // ─── OR divider ───────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.borderSubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      AppStrings.loginOrDivider,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.borderSubtle)),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Social buttons row ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _SocialButton(
                      label: AppStrings.loginGoogle,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SocialButton(
                      label: AppStrings.loginApple,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Sign up link ─────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => context.go(RouteNames.profileTypePicker),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.body,
                      children: [
                        TextSpan(text: AppStrings.loginNoAccount),
                        TextSpan(
                          text: AppStrings.loginSignUp,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social Button ─────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.buttonSecondary,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}