import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_field.dart';
import '../../core/services/auth_service.dart';
import 'register_screen.dart';
import '../navigation/main_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(
          () => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService()
          .signIn(emailOrUsername: email, password: password);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainNavigation()),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() =>
          _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Heading ───────────────────────────────
                const Text('Welcome back.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authHeading),
                const SizedBox(height: 8),
                const Text(
                    'Sign in to your StanDiag account',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.authSubheading),
                const SizedBox(height: 36),

                // ── Error ─────────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.criticalBorder),
                    ),
                    child: Text(_errorMessage!,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryLight,
                            fontFamily: 'Inter')),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Fields ────────────────────────────────
                AppField(
                  label: 'Email or Username',
                  hint: 'Enter your email or username',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AppField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscure: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('Forgot your password?',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            fontFamily: 'Inter')),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Sign In Button ────────────────────────
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2))
                      : const Text('SIGN IN',
                          style: AppTextStyles.buttonLabel),
                ),
                const SizedBox(height: 24),

                // ── Divider ───────────────────────────────
                Row(children: [
                  const Expanded(
                      child: Divider(
                          color: Color(0xFF2A2A2E),
                          height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12),
                    child: Text('or continue with',
                        style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF666666))),
                  ),
                  const Expanded(
                      child: Divider(
                          color: Color(0xFF2A2A2E),
                          height: 1)),
                ]),
                const SizedBox(height: 16),

                // ── Google + Apple ────────────────────────
                Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('G',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEA4335),
                                    fontFamily: 'Inter')),
                            SizedBox(width: 8),
                            Text('Google',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C4043),
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF3A3A3A)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.apple,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text('Apple',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Inter')),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 28),

                // ── Register Link ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account yet? ",
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF999999))),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                const RegisterScreen()),
                      ),
                      child: const Text('Create an account',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Inter')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'By signing in, you agree to our\nTerms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: const Color(0xFF666666),
                          height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

