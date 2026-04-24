import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'register_screen.dart';
import '../navigation/main_navigation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

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
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.signIn(emailOrUsername: email, password: password);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainNavigation()),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(
          () => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final s = sw / 430;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: 24 * s, vertical: 32 * s),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo / Title ──────────────────────────
                Text('Welcome back.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Inter',
                      height: 1.2,
                      letterSpacing: -0.4,
                    )),
                SizedBox(height: 8 * s),
                Text('Sign in to your StanDiag account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16 * s,
                      color: const Color(0xFF999999),
                      fontFamily: 'Inter',
                    )),
                SizedBox(height: 36 * s),

                // ── Error Banner ──────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12 * s),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(8 * s),
                      border:
                          Border.all(color: AppColors.criticalBorder),
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

                // ── Email ─────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('EMAIL OR USERNAME',
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF999999),
                        letterSpacing: 1.5,
                        fontFamily: 'Inter',
                      )),
                ),
                SizedBox(height: 8 * s),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                      fontSize: 16 * s,
                      color: Colors.white,
                      fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: 'Enter your EMAIL OR USERNAME',
                    hintStyle: TextStyle(
                        fontSize: 16 * s,
                        color: const Color(0xFF555555),
                        fontFamily: 'Inter'),
                    filled: true,
                    fillColor: const Color(0xFF161619),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * s),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * s, vertical: 16 * s),
                  ),
                ),
                SizedBox(height: 18 * s),

                // ── Password ──────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('PASSWORD',
                      style: TextStyle(
                        fontSize: 11 * s,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF999999),
                        letterSpacing: 1.5,
                        fontFamily: 'Inter',
                      )),
                ),
                SizedBox(height: 8 * s),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(
                      fontSize: 16 * s,
                      color: Colors.white,
                      fontFamily: 'Inter'),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                        fontSize: 16 * s,
                        color: const Color(0xFF555555),
                        fontFamily: 'Inter'),
                    filled: true,
                    fillColor: const Color(0xFF161619),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * s),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * s, vertical: 16 * s),
                    suffixIcon: GestureDetector(
                      onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: EdgeInsets.only(right: 12 * s),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF666666),
                          size: 18 * s,
                        ),
                      ),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
                SizedBox(height: 10 * s),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text('Forgot your password?',
                        style: TextStyle(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        )),
                  ),
                ),
                SizedBox(height: 24 * s),

                // ── Sign In Button ────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.5),
                      padding: EdgeInsets.symmetric(vertical: 16 * s),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * s),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20 * s,
                            width: 20 * s,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('SIGN IN',
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              fontFamily: 'Inter',
                            )),
                  ),
                ),
                SizedBox(height: 24 * s),

                // ── Divider ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: const Color(0xFF2A2A2E),
                            height: 1,
                            thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12 * s),
                      child: Text('or continue with',
                          style: TextStyle(
                            fontSize: 13 * s,
                            color: const Color(0xFF666666),
                            fontFamily: 'Inter',
                          )),
                    ),
                    Expanded(
                        child: Divider(
                            color: const Color(0xFF2A2A2E),
                            height: 1,
                            thickness: 1)),
                  ],
                ),
                SizedBox(height: 16 * s),

                // ── Google + Apple side by side ───────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: 13 * s),
                          side: const BorderSide(
                              color: Color(0xFF2A2A2E), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10 * s),
                          ),
                        ),
                        icon: Text('G',
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEA4335),
                              fontFamily: 'Inter',
                            )),
                        label: Text('Google',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            )),
                      ),
                    ),
                    SizedBox(width: 12 * s),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(vertical: 13 * s),
                          side: const BorderSide(
                              color: Color(0xFF2A2A2E), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10 * s),
                          ),
                        ),
                        icon: Icon(Icons.apple,
                            color: Colors.white, size: 18 * s),
                        label: Text('Apple',
                            style: TextStyle(
                              fontSize: 14 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28 * s),

                // ── Register Link ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account yet? ",
                        style: TextStyle(
                          fontSize: 14 * s,
                          color: const Color(0xFF999999),
                          fontFamily: 'Inter',
                        )),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text('Create an account',
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontFamily: 'Inter',
                          )),
                    ),
                  ],
                ),
                SizedBox(height: 16 * s),
                Text(
                  'By signing in, you agree to our\nTerms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12 * s,
                    color: const Color(0xFF666666),
                    fontFamily: 'Inter',
                    height: 1.4,
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


