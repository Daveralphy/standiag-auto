import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/services/auth_service.dart';
import '../navigation/main_navigation.dart';
import '../mechanic/mechanic_navigation.dart';
import 'account_type_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      AppToast.error(context, 'Please enter your email and password.');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().signIn(emailOrUsername: email, password: pass);
      if (!mounted) return;
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) { AppToast.error(context, 'Login failed.'); return; }
      final profile = await Supabase.instance.client
          .from('profiles').select('account_type').eq('id', userId).maybeSingle();
      if (!mounted) return;
      final accountType = profile?['account_type'] ?? 'car_owner';
      if (accountType == 'mechanic') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MechanicNavigation()), (r) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainNavigation()), (r) => false);
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      AppToast.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text('Welcome back.',
                  textAlign: TextAlign.center,
                  style: AppTypography.h1.copyWith(fontSize: 28)),
              const SizedBox(height: 10),
              Text('Sign in to continue to StanDiag',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              // â”€â”€ Email â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _AuthField(
                label: 'Email address',
                hint: 'Enter your email',
                controller: _emailCtrl,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              // â”€â”€ Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _AuthField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passCtrl,
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                inputAction: TextInputAction.done,
                onSubmit: (_) => _login(),
                suffix: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // â”€â”€ Forgot password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => AppToast.info(
                      context, 'Password reset coming soon.'),
                  child: Text('Forget Password?',
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 28),
              // â”€â”€ Continue button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _loading ? null : _login,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.lgAll,
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                        : Text('Continue',
                            style: AppTypography.button),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // â”€â”€ Divider â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(children: [
                Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Or Login with',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary)),
                ),
                Expanded(child: Divider(color: AppColors.border, thickness: 1)),
              ]),
              const SizedBox(height: 20),
              // â”€â”€ Google + Apple side by side â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AppToast.info(
                        context, 'Google sign in coming soon.'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleIcon(),
                          const SizedBox(width: 10),
                          Text('Google',
                              style: AppTypography.label.copyWith(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AppToast.info(
                        context, 'Apple sign in coming soon.'),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.apple_rounded,
                              color: AppColors.textPrimary, size: 22),
                          const SizedBox(width: 10),
                          Text('Apple',
                              style: AppTypography.label.copyWith(
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 36),
              // â”€â”€ Create account â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No account? ',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary)),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AccountTypeScreen())),
                    child: Text('Create account',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // â”€â”€ Terms â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AppToast.info(context, 'Terms coming soon.'),
                    child: Text('Terms of Use',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|', style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary)),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => AppToast.info(
                        context, 'Privacy policy coming soon.'),
                    child: Text('Privacy Policy.',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Auth field â€” floating label on border left edge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AuthField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final TextInputAction inputAction;
  final Widget? suffix;
  final ValueChanged<String>? onSubmit;

  const _AuthField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.suffix,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                keyboardType: keyboardType,
                textInputAction: inputAction,
                onSubmitted: onSubmit,
                style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (suffix != null) suffix!,
          ]),
        ),
        Positioned(
          top: -9,
          left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20, height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // Scale factor based on 24x24 viewBox
    final s = w / 24;

    void drawPath(String d, Color color) {
      final paint = Paint()..color = color..style = PaintingStyle.fill;
      final path = Path();
      // Blue: top right arc
      if (color == const Color(0xFF4285F4)) {
        path.moveTo(22.56 * s, 12.25 * s);
        path.cubicTo(22.56 * s, 11.47 * s, 22.49 * s, 10.72 * s, 22.36 * s, 10 * s);
        path.lineTo(12 * s, 10 * s);
        path.lineTo(12 * s, 14.26 * s);
        path.lineTo(17.92 * s, 14.26 * s);
        path.cubicTo(17.66 * s, 15.63 * s, 16.88 * s, 16.79 * s, 15.71 * s, 17.57 * s);
        path.lineTo(15.71 * s, 20.34 * s);
        path.lineTo(19.28 * s, 20.34 * s);
        path.cubicTo(21.36 * s, 18.42 * s, 22.56 * s, 15.6 * s, 22.56 * s, 12.25 * s);
      } else if (color == const Color(0xFF34A853)) {
        path.moveTo(12 * s, 23 * s);
        path.cubicTo(14.97 * s, 23 * s, 17.46 * s, 22.02 * s, 19.28 * s, 20.34 * s);
        path.lineTo(15.71 * s, 17.57 * s);
        path.cubicTo(14.73 * s, 18.23 * s, 13.48 * s, 18.63 * s, 12 * s, 18.63 * s);
        path.cubicTo(9.14 * s, 18.63 * s, 6.71 * s, 16.7 * s, 5.84 * s, 14.1 * s);
        path.lineTo(2.18 * s, 14.1 * s);
        path.lineTo(2.18 * s, 16.94 * s);
        path.cubicTo(3.99 * s, 20.53 * s, 7.7 * s, 23 * s, 12 * s, 23 * s);
      } else if (color == const Color(0xFFFBBC05)) {
        path.moveTo(5.84 * s, 14.09 * s);
        path.cubicTo(5.62 * s, 13.43 * s, 5.49 * s, 12.73 * s, 5.49 * s, 12 * s);
        path.cubicTo(5.49 * s, 11.27 * s, 5.62 * s, 10.57 * s, 5.84 * s, 9.91 * s);
        path.lineTo(5.84 * s, 7.07 * s);
        path.lineTo(2.18 * s, 7.07 * s);
        path.cubicTo(1.43 * s, 8.55 * s, 1 * s, 10.22 * s, 1 * s, 12 * s);
        path.cubicTo(1 * s, 13.78 * s, 1.43 * s, 15.45 * s, 2.18 * s, 16.93 * s);
        path.lineTo(5.84 * s, 14.09 * s);
      } else {
        path.moveTo(12 * s, 5.38 * s);
        path.cubicTo(13.62 * s, 5.38 * s, 15.06 * s, 5.94 * s, 16.21 * s, 7.02 * s);
        path.lineTo(19.36 * s, 3.87 * s);
        path.cubicTo(17.45 * s, 2.09 * s, 14.97 * s, 1 * s, 12 * s, 1 * s);
        path.cubicTo(7.7 * s, 1 * s, 3.99 * s, 3.47 * s, 2.18 * s, 7.07 * s);
        path.lineTo(5.84 * s, 9.91 * s);
        path.cubicTo(6.71 * s, 7.31 * s, 9.14 * s, 5.38 * s, 12 * s, 5.38 * s);
      }
      canvas.drawPath(path, paint);
    }

    drawPath('blue', const Color(0xFF4285F4));
    drawPath('green', const Color(0xFF34A853));
    drawPath('yellow', const Color(0xFFFBBC05));
    drawPath('red', const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(_GoogleGPainter old) => false;
}



