import 'dart:async';
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
import '../models/user_model.dart';
import '../providers/signup_draft_provider.dart';

class OtpEmailScreen extends ConsumerStatefulWidget {
  const OtpEmailScreen({super.key});

  @override
  ConsumerState<OtpEmailScreen> createState() => _OtpEmailScreenState();
}

class _OtpEmailScreenState extends ConsumerState<OtpEmailScreen> {
  final List<String> _digits = List.filled(6, '');
  int _countdown = 59;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _startCountdown();
    ref.read(authControllerProvider).sendEmailVerification();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdownLabel {
    final m = _countdown ~/ 60;
    final s = _countdown % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        for (int i = 5; i >= 0; i--) {
          if (_digits[i].isNotEmpty) {
            _digits[i] = '';
            break;
          }
        }
      } else {
        for (int i = 0; i < 6; i++) {
          if (_digits[i].isEmpty) {
            _digits[i] = key;
            break;
          }
        }
      }
    });
  }

  bool get _isFull => _digits.every((d) => d.isNotEmpty);

  Future<void> _resend() async {
    if (_countdown != 0) return;
    await ref.read(authControllerProvider).sendEmailVerification();
    if (!mounted) return;
    setState(() => _countdown = 59);
    _startCountdown();
  }

  Future<void> _verify() async {
    setState(() => _isLoading = true);
    try {
      final verified = await ref.read(authControllerProvider).checkEmailVerified();
      if (!mounted) return;
      if (!verified) {
        AppErrorToast.showMessage(context,
            'Not verified yet — open the link we emailed you, then try again.');
        return;
      }
      context.go(RouteNames.otpPhone);
    } catch (error, stackTrace) {
      if (!mounted) return;
      AppErrorToast.showMessage(
          context, ErrorHandler.handle(error, stackTrace).message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draftType = ref.watch(signupDraftProvider).type;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Stack(
              children: [
                Image.asset('assets/images/onboarding_1.png',
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
                // Top row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.go(draftType == UserType.mechanic
                            ? RouteNames.mechanicSignupStepThree
                            : RouteNames.userSignupStepThree),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x14FFFFFF)),
                          ),
                          child: const Center(child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13, color: Colors.white)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.otpPhone),
                        child: const Text('Skip for now',
                            style: TextStyle(
                              fontFamily: 'Inter', fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0x59FFFFFF),
                            )),
                      ),
                    ],
                  ),
                ),

                // Headline + subtitle + boxes
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
                            TextSpan(text: 'Verify your\n'),
                            TextSpan(text: 'email.',
                                style: TextStyle(color: AppColors.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter the 6-digit code sent to your email. You can skip and verify later.',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 15,
                          color: Color(0x47FFFFFF), height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // OTP boxes
                      Row(
                        children: List.generate(6, (i) => Expanded(
                          child: Container(
                            height: 56,
                            margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                            decoration: BoxDecoration(
                              color: _digits[i].isNotEmpty
                                  ? const Color(0x14E8281E)
                                  : const Color(0x0AFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _digits[i].isNotEmpty
                                    ? AppColors.primary
                                    : const Color(0x17FFFFFF),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _digits[i],
                                style: const TextStyle(
                                  fontFamily: 'Inter', fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: _resend,
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 14,
                                color: Color(0x4DFFFFFF),
                              ),
                              children: [
                                const TextSpan(text: "Didn't receive a code? "),
                                TextSpan(
                                  text: _countdown == 0
                                      ? 'Resend'
                                      : 'Resend in $_countdownLabel',
                                  style: TextStyle(
                                    color: _countdown == 0
                                        ? AppColors.primary
                                        : const Color(0x33FFFFFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Custom number keypad
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      // Verify button
                      GestureDetector(
                        onTap: (_isFull && !_isLoading) ? _verify : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: _isFull
                                  ? [const Color(0xFFF03328), const Color(0xFFC41F16)]
                                  : [const Color(0xFF3A3A3A), const Color(0xFF2A2A2A)],
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Verify Email',
                                    style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3,
                                    )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Keypad grid
                      _Keypad(onKey: _onKey),
                    ],
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

class _Keypad extends StatelessWidget {
  final void Function(String) onKey;
  const _Keypad({required this.onKey});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: keys.map((row) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: row.map((k) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: k.isEmpty
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: () => onKey(k),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: k == '⌫'
                              ? const Color(0x0FFFFFFF)
                              : const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: k == '⌫'
                              ? const Icon(Icons.backspace_outlined,
                                  color: Colors.white, size: 20)
                              : Text(k,
                                  style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  )),
                        ),
                      ),
                    ),
            ),
          )).toList(),
        ),
      )).toList(),
    );
  }
}