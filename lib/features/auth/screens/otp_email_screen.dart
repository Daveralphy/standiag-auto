import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/services/otp_email_service.dart';
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
  static const _codeValidity = Duration(minutes: 10);

  final List<String> _digits = List.filled(6, '');
  int _countdown = 59;
  Timer? _timer;
  bool _isLoading = false;

  // The code actually being checked against — generated and emailed
  // client-side via EmailJS, the same real (not link-based) verification
  // this app already uses for password changes. Previously this screen's
  // keypad checked nothing at all: any 6 digits "verified" as long as the
  // user had separately clicked a Firebase-emailed link.
  String? _sentCode;
  DateTime? _codeSentAt;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _startCountdown();
    _sendNewCode();
  }

  String _generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<void> _sendNewCode() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final code = _generateCode();
    _sentCode = code;
    _codeSentAt = DateTime.now();
    try {
      await OtpEmailService.sendCode(toEmail: email, code: code);
    } catch (error, stackTrace) {
      if (!mounted) return;
      final message =
          error is StateError && error.message == 'emailjs-not-configured'
          ? "Email delivery isn't set up yet — add your EmailJS keys in emailjs_config.dart."
          : ErrorHandler.handle(error, stackTrace).message;
      AppErrorToast.showMessage(context, message);
    }
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
    setState(() => _countdown = 59);
    _startCountdown();
    await _sendNewCode();
  }

  Future<void> _verify() async {
    final entered = _digits.join();
    if (_sentCode == null || _codeSentAt == null ||
        DateTime.now().difference(_codeSentAt!) > _codeValidity) {
      AppErrorToast.showMessage(
        context,
        'This code has expired. Tap Resend to get a new one.',
      );
      return;
    }
    if (entered != _sentCode) {
      AppErrorToast.showMessage(context, 'Incorrect code. Please try again.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'emailVerified': true}, SetOptions(merge: true));
      }
      if (!mounted) return;
      context.push(RouteNames.otpPhone);
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
    final draftType = ref.watch(signupDraftProvider).type;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(
                          draftType == UserType.mechanic
                              ? RouteNames.mechanicSignupStepThree
                              : RouteNames.userSignupStepThree,
                        );
                      }
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.otpPhone),
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTag,
                      ),
                    ),
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
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.12,
                        letterSpacing: -1,
                      ),
                      children: [
                        const TextSpan(text: 'Verify your\n'),
                        TextSpan(
                          text: 'email.',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter the 6-digit code sent to your email. You can skip and verify later.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: AppColors.textDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // OTP boxes
                  Row(
                    children: List.generate(
                      6,
                      (i) => Expanded(
                        child: Container(
                          height: 56,
                          margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: _digits[i].isNotEmpty
                                ? const Color(0x14E8281E)
                                : AppColors.borderSubtle,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _digits[i].isNotEmpty
                                  ? AppColors.primary
                                  : AppColors.borderActive,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _digits[i],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _resend,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: AppColors.textTag,
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
                                    : AppColors.textDisabled,
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
                        gradient: _isFull
                            ? const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFF03328), Color(0xFFC41F16)],
                              )
                            : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.border,
                                  AppColors.borderActive,
                                ],
                              ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Verify Email',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _isFull
                                      ? Colors.white
                                      : AppColors.textMuted,
                                  letterSpacing: -0.3,
                                ),
                              ),
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
      children: keys
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row
                    .map(
                      (k) => Expanded(
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
                                          ? AppColors.borderSubtle
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: k == '⌫'
                                          ? Icon(
                                              Icons.backspace_outlined,
                                              color: AppColors.textPrimary,
                                              size: 20,
                                            )
                                          : Text(
                                              k,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}
