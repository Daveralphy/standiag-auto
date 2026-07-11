import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/auth_floating_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  // Field-level errors
  String? _emailError;
  String? _passwordError;

  // Top toast
  OverlayEntry? _toastEntry;
  late AnimationController _toastController;
  late Animation<Offset> _toastSlide;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _toastSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _toastController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _toastController.dispose();
    _toastEntry?.remove();
    super.dispose();
  }

  // ─── Show top toast ──────────────────────────────────────────────────
  void _showToast(String message) {
    _toastEntry?.remove();
    _toastEntry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SlideTransition(
              position: _toastSlide,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0A0A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x59E8281E)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x99000000),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toastEntry!);
    _toastController.forward(from: 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _toastController.reverse().then((_) {
        _toastEntry?.remove();
        _toastEntry = null;
      });
    });
  }

  // ─── Sign in ─────────────────────────────────────────────────────────
  Future<void> _signIn() async {
    // Clear field errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final input = _emailController.text.trim();
    final password = _passwordController.text;

    // Field-level validation
    bool hasError = false;
    if (input.isEmpty) {
      setState(() => _emailError = 'Please enter your username or email');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      hasError = true;
    }
    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authControllerProvider);
      await auth.signInWithIdentifier(input, password);
      if (!mounted) return;
      final uid = ref.read(currentUserIdProvider);
      // Resolve the real type with one direct fetch instead of reading the
      // (possibly still-loading) currentUserTypeProvider — otherwise a
      // mechanic can briefly land on the CarOwner home before the router's
      // redirect corrects it, which reads as a visible flash of the wrong
      // screen rather than a smooth arrival.
      final type = uid == null
          ? UserType.carOwner
          : await auth.fetchUserType(uid);
      if (!mounted) return;
      context.go(RouteNames.homeFor(type));
    } on StateError {
      if (mounted) {
        setState(() => _emailError = 'No account found with that username');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final error = ErrorHandler.handle(e, StackTrace.current);
      switch (error.type) {
        case AppErrorType.wrongPassword:
          setState(() => _passwordError = error.message);
          break;
        case AppErrorType.userNotFound:
        case AppErrorType.invalidEmail:
          setState(() => _emailError = error.message);
          break;
        default:
          _showToast(error.message);
      }
    } catch (error, stackTrace) {
      if (mounted) {
        _showToast(ErrorHandler.handle(error, stackTrace).message);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Photo bleed top 30%
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.30,
            child: Stack(
              children: [
                Image.asset('assets/images/onboarding_1.png',
                    width: double.infinity, height: double.infinity,
                    fit: BoxFit.cover, alignment: Alignment.topCenter),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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

          // Content
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15),

                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 30,
                        fontWeight: FontWeight.w900, color: Colors.white,
                        height: 1.12, letterSpacing: -1,
                      ),
                      children: [
                        TextSpan(text: 'Welcome\n'),
                        TextSpan(text: 'back.',
                            style: TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to continue to StanDiag Auto.',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 15,
                      color: Color(0x99FFFFFF), height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Email / Username
                  AuthFloatingField(
                    label: 'Username or Email',
                    hint: 'Enter your username or email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  // Password
                  AuthFloatingField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    enabled: !_isLoading,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    suffix: GestureDetector(
                      onTap: () =>
                          setState(() => _showPassword = !_showPassword),
                      child: Icon(
                        _showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: const Color(0x66FFFFFF),
                      ),
                    ),
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: GestureDetector(
                        onTap: () => context.push(RouteNames.forgotPassword),
                        child: const Text('Forgot password?',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            )),
                      ),
                    ),
                  ),

                  // Sign In button
                  _PrimaryButton(
                    label: 'Sign In',
                    isLoading: _isLoading,
                    onTap: _signIn,
                  ),

                  // Divider
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Expanded(child: Divider(
                            color: Color(0x14FFFFFF), thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('or continue with',
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 13,
                                color: Color(0x73FFFFFF),
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                        Expanded(child: Divider(
                            color: Color(0x14FFFFFF), thickness: 1)),
                      ],
                    ),
                  ),

                  // Social buttons
                  Row(
                    children: [
                      Expanded(child: _SocialButton(
                        label: 'Google',
                        icon: const _GoogleIcon(),
                        onTap: () =>
                            _showToast('Google sign-in is coming soon.'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _SocialButton(
                        label: 'Apple',
                        icon: const Icon(Icons.apple_rounded,
                            size: 18, color: Colors.white),
                        onTap: () =>
                            _showToast('Apple sign-in is coming soon.'),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign up
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go(RouteNames.profileTypePicker),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 15,
                            color: Color(0x80FFFFFF),
                          ),
                          children: [
                            TextSpan(text: "Don't have an account? "),
                            TextSpan(text: 'Sign up',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Remaining widgets ─────────────────────────────────────────────────────

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
          child: isLoading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 17,
                    fontWeight: FontWeight.w700, color: Colors.white,
                    letterSpacing: -0.3,
                  )),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x17FFFFFF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xA6FFFFFF),
                )),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18, height: 18,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    canvas.scale(s, s);
    final blue = Paint()..color = const Color(0xFF4285F4);
    canvas.drawPath(Path()
      ..moveTo(22.56, 12.25)
      ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
      ..lineTo(12.0, 10.0)..lineTo(12.0, 14.26)..lineTo(17.92, 14.26)
      ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
      ..lineTo(15.71, 20.34)..lineTo(19.28, 20.34)
      ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)..close(), blue);
    final green = Paint()..color = const Color(0xFF34A853);
    canvas.drawPath(Path()
      ..moveTo(12.0, 23.0)
      ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
      ..lineTo(15.71, 17.57)
      ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
      ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
      ..lineTo(2.18, 14.1)..lineTo(2.18, 16.94)
      ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)..close(), green);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawPath(Path()
      ..moveTo(5.84, 14.09)
      ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
      ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
      ..lineTo(5.84, 7.07)..lineTo(2.18, 7.07)
      ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
      ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.93)
      ..lineTo(5.84, 14.09)..close(), yellow);
    final red = Paint()..color = const Color(0xFFEA4335);
    canvas.drawPath(Path()
      ..moveTo(12.0, 5.38)
      ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
      ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.07)
      ..lineTo(5.84, 9.91)
      ..cubicTo(6.71, 7.31, 9.14, 5.38, 12.0, 5.38)..close(), red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}