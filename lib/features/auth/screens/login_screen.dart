import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/system_ui_style.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow the scaffold to resize when keyboard appears
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

          // Content — no back button, fully scrollable
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top space to push content below image
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22),

                  // Headline
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
                      color: Color(0x47FFFFFF), height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Username or Email
                  _FloatingField(
                    label: 'Username or Email',
                    hint: 'Enter your username or email',
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 22),

                  // Password
                  _FloatingField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: !_showPassword,
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
                        onTap: () {},
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
                    onTap: () {
                      setState(() => _isLoading = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (!mounted) return;
                            setState(() => _isLoading = false);
                            context.go(RouteNames.userHome);
                      });
                    },
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
                                fontFamily: 'Inter', fontSize: 12,
                                color: Color(0x33FFFFFF),
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
                        onTap: () {},
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _SocialButton(
                        label: 'Apple',
                        icon: const Icon(Icons.apple_rounded,
                            size: 18, color: Colors.white),
                        onTap: () {},
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
                            color: Color(0x4DFFFFFF),
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

class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
          color: Color(0x66FFFFFF), fontWeight: FontWeight.w400,
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
    canvas.drawPath(
      Path()
        ..moveTo(22.56, 12.25)
        ..cubicTo(22.56, 11.47, 22.49, 10.72, 22.36, 10.0)
        ..lineTo(12.0, 10.0)
        ..lineTo(12.0, 14.26)
        ..lineTo(17.92, 14.26)
        ..cubicTo(17.66, 15.63, 16.88, 16.79, 15.71, 17.57)
        ..lineTo(15.71, 20.34)
        ..lineTo(19.28, 20.34)
        ..cubicTo(21.36, 18.42, 22.56, 15.6, 22.56, 12.25)
        ..close(),
      blue,
    );

    final green = Paint()..color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(12.0, 23.0)
        ..cubicTo(14.97, 23.0, 17.46, 22.02, 19.28, 20.34)
        ..lineTo(15.71, 17.57)
        ..cubicTo(14.73, 18.23, 13.48, 18.63, 12.0, 18.63)
        ..cubicTo(9.14, 18.63, 6.71, 16.7, 5.84, 14.1)
        ..lineTo(2.18, 14.1)
        ..lineTo(2.18, 16.94)
        ..cubicTo(3.99, 20.53, 7.7, 23.0, 12.0, 23.0)
        ..close(),
      green,
    );

    final yellow = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(5.84, 14.09)
        ..cubicTo(5.62, 13.43, 5.49, 12.73, 5.49, 12.0)
        ..cubicTo(5.49, 11.27, 5.62, 10.57, 5.84, 9.91)
        ..lineTo(5.84, 7.07)
        ..lineTo(2.18, 7.07)
        ..cubicTo(1.43, 8.55, 1.0, 10.22, 1.0, 12.0)
        ..cubicTo(1.0, 13.78, 1.43, 15.45, 2.18, 16.93)
        ..lineTo(5.84, 14.09)
        ..close(),
      yellow,
    );

    final red = Paint()..color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(12.0, 5.38)
        ..cubicTo(13.62, 5.38, 15.06, 5.94, 16.21, 7.02)
        ..lineTo(19.36, 3.87)
        ..cubicTo(17.45, 2.09, 14.97, 1.0, 12.0, 1.0)
        ..cubicTo(7.7, 1.0, 3.99, 3.47, 2.18, 7.07)
        ..lineTo(5.84, 9.91)
        ..cubicTo(6.71, 7.31, 9.14, 5.38, 12.0, 5.38)
        ..close(),
      red,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}