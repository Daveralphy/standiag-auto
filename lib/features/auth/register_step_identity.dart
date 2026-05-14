import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_toast.dart';

class RegisterStepIdentity extends StatefulWidget {
  final RegisterState state;
  final VoidCallback onBack;
  final VoidCallback onSuccess;

  const RegisterStepIdentity({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSuccess,
  });

  @override
  State<RegisterStepIdentity> createState() => _RegisterStepIdentityState();
}

class _RegisterStepIdentityState extends State<RegisterStepIdentity> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _showPass    = false;
  bool _showConfirm = false;
  bool _loading     = false;

  String? _usernameHint;
  bool?   _usernameAvailable;
  bool    _checkingUsername = false;
  final _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  int get _strength {
    final v = _passCtrl.text;
    int s = 0;
    if (v.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(v)) s++;
    if (RegExp(r'[0-9]').hasMatch(v)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s++;
    return s;
  }

  Color _strengthColor(int s) {
    if (s <= 1) return const Color(0xFFEF4444);
    if (s <= 2) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  String _strengthLabel(int s) {
    if (s <= 1) return 'Weak password';
    if (s <= 2) return 'Fair password';
    if (s == 3) return 'Good password';
    return 'Strong password';
  }

  Future<void> _checkUsername(String v) async {
    if (v.isEmpty) {
      setState(() { _usernameHint = null; _usernameAvailable = null; });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
      setState(() {
        _usernameHint = 'Only letters, numbers and underscores allowed';
        _usernameAvailable = false;
      });
      return;
    }
    setState(() {
      _checkingUsername = true;
      _usernameHint = 'Checking availability...';
      _usernameAvailable = null;
    });
    try {
      final result = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', v.toLowerCase())
          .maybeSingle();
      if (!mounted) return;
      final taken = result != null;
      setState(() {
        _usernameAvailable = !taken;
        _usernameHint = taken ? '@$v is already taken' : '@$v is available';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _usernameHint = null; _usernameAvailable = null; });
    } finally {
      if (mounted) setState(() => _checkingUsername = false);
    }
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (username.isEmpty) {
      AppToast.error(context, 'Please choose a username.'); return;
    }
    if (_usernameAvailable != true) {
      AppToast.error(context, 'Please choose an available username.'); return;
    }
    if (email.isEmpty || !email.contains('@')) {
      AppToast.error(context, 'Please enter a valid email address.'); return;
    }
    if (password.length < 8) {
      AppToast.error(context, 'Password must be at least 8 characters.'); return;
    }
    if (password != confirm) {
      AppToast.error(context, 'Passwords do not match.'); return;
    }

    setState(() => _loading = true);
    try {
      final auth = AuthService();
      final s = widget.state;
      if (s.accountType == 'mechanic') {
        await auth.registerMechanic(
          email: email,
          password: password,
          username: username,
          firstName: s.firstName,
          lastName: s.lastName,
          gender: s.gender,
          phone: s.phone,
          countryCode: s.countryCode,
          address: s.address,
          specialisations: s.specialisations,
          experienceYears: s.experienceYears,
        );
      } else {
        await auth.registerCarOwner(
          email: email,
          password: password,
          username: username,
          firstName: s.firstName,
          lastName: s.lastName,
          gender: s.gender,
          phone: s.phone,
          countryCode: s.countryCode,
          vehicle: s.vehicle,
        );
      }
      if (!mounted) return;
      widget.onSuccess();
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
    final s      = _strength;
    final hasPass = _passCtrl.text.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Future.delayed(
                        const Duration(milliseconds: 100), widget.onBack);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 20),
                _StepTabs(currentStep: 4),
                const SizedBox(height: 40),
                Text('Almost there,\none last step.',
                    style: AppTypography.h1.copyWith(
                        fontSize: 28, letterSpacing: -0.6, height: 1.15)),
                const SizedBox(height: 8),
                Text('Set up your login credentials.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),

                // Username
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(
                            color: _usernameAvailable == true
                                ? const Color(0xFF22C55E)
                                : _usernameAvailable == false
                                    ? const Color(0xFFEF4444)
                                    : AppColors.border),
                      ),
                      child: Row(children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.alternate_email_rounded,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _usernameCtrl,
                            onChanged: (v) {
                              setState(() {});
                              Future.delayed(
                                  const Duration(milliseconds: 600), () {
                                if (_usernameCtrl.text == v) {
                                  _checkUsername(v);
                                }
                              });
                            },
                            style: AppTypography.body
                                .copyWith(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Choose a username',
                              hintStyle: AppTypography.body
                                  .copyWith(color: AppColors.textDisabled),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_checkingUsername)
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppColors.textTertiary),
                          )
                        else if (_usernameAvailable == true)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF22C55E), size: 18)
                        else if (_usernameAvailable == false)
                          const Icon(Icons.cancel_rounded,
                              color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 16),
                      ]),
                    ),
                    Positioned(
                      top: -9, left: 12,
                      child: Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Username',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    _usernameHint ?? 'Letters, numbers and underscores only',
                    style: AppTypography.caption.copyWith(
                        color: _usernameAvailable == true
                            ? const Color(0xFF22C55E)
                            : _usernameAvailable == false
                                ? const Color(0xFFEF4444)
                                : AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 22),

                // Email
                _FloatingField(
                  label: 'Email Address',
                  hint: 'Enter email address',
                  controller: _emailCtrl,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 22),

                // Password
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _passCtrl,
                            obscureText: !_showPass,
                            onChanged: (_) => setState(() {}),
                            style: AppTypography.body
                                .copyWith(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Create a password',
                              hintStyle: AppTypography.body
                                  .copyWith(color: AppColors.textDisabled),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showPass = !_showPass),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text(
                              _showPass ? 'Hide' : 'Show',
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      top: -9, left: 12,
                      child: Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Password',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                if (hasPass) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(4, (i) {
                      final filled = i < s;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                          height: 3,
                          decoration: BoxDecoration(
                            color: filled
                                ? _strengthColor(s)
                                : AppColors.border,
                            borderRadius: AppRadius.fullAll,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(_strengthLabel(s),
                      style: AppTypography.caption
                          .copyWith(color: _strengthColor(s))),
                ],
                const SizedBox(height: 22),

                // Confirm Password
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textTertiary, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _confirmCtrl,
                            obscureText: !_showConfirm,
                            onChanged: (_) => setState(() {}),
                            style: AppTypography.body
                                .copyWith(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              hintStyle: AppTypography.body
                                  .copyWith(color: AppColors.textDisabled),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                              () => _showConfirm = !_showConfirm),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            child: Text(
                              _showConfirm ? 'Hide' : 'Show',
                              style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    Positioned(
                      top: -9, left: 12,
                      child: Container(
                        color: AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('Confirm Password',
                            style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Terms
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary, height: 1.6),
                    children: [
                      const TextSpan(
                          text: 'By creating an account you agree to our '),
                      TextSpan(
                          text: 'Terms of Service',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline)),
                      const TextSpan(text: ' and '),
                      TextSpan(
                          text: 'Privacy Policy',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.underline)),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _loading ? null : _submit,
                  child: AnimatedOpacity(
                    opacity: _loading ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 200),
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
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : Text('CREATE ACCOUNT',
                                style: AppTypography.button.copyWith(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w800)),
                      ),
                    ),
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

// ── Step tabs ─────────────────────────────────────────────────────
class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});
  static const _labels = [
    'Getting\nStarted', 'Your\nDetails', 'Contact\nInfo',
    'Vehicle /\nExpertise', 'Your\nIdentity',
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentStep;
        final isDone   = i < currentStep;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 24 : 8, height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : isDone
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : AppColors.border,
                      borderRadius: isActive
                          ? AppRadius.smAll
                          : AppRadius.fullAll,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_labels[i],
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 10, height: 1.3)),
                ]),
              ),
              if (i < _labels.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 8, height: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Floating label field ──────────────────────────────────────────
class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textTertiary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: AppTypography.body
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ]),
        ),
        Positioned(
          top: -9, left: 12,
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