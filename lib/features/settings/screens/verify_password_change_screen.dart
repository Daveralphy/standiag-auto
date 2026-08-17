// Verify Password Change screen — OTP sent to email to confirm password change.

import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/services/otp_email_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';

class VerifyPasswordChangeScreen extends ConsumerStatefulWidget {
  final String currentPassword;
  final String newPassword;
  const VerifyPasswordChangeScreen({
    super.key,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  ConsumerState<VerifyPasswordChangeScreen> createState() =>
      _VerifyPasswordChangeScreenState();
}

class _VerifyPasswordChangeScreenState
    extends ConsumerState<VerifyPasswordChangeScreen> {
  static const _codeValidity = Duration(minutes: 5);

  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _countdown = 45;
  Timer? _timer;
  bool _isLoading = false;
  bool _isSendingCode = false;
  String? _sentCode;
  DateTime? _codeSentAt;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendNewCode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _countdown = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String _generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<void> _sendNewCode() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final code = _generateCode();
    setState(() {
      _sentCode = code;
      _codeSentAt = DateTime.now();
      _isSendingCode = true;
    });
    try {
      await OtpEmailService.sendCode(toEmail: email, code: code);
    } catch (error, stackTrace) {
      if (!mounted) return;
      final message = error is StateError && error.message == 'emailjs-not-configured'
          ? "Email delivery isn't set up yet — add your EmailJS keys in emailjs_config.dart."
          : ErrorHandler.handle(error, stackTrace).message;
      AppErrorToast.showMessage(context, message);
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _handleResend() async {
    if (_countdown != 0 || _isSendingCode) return;
    setState(() => _startCooldown());
    await _sendNewCode();
  }

  Future<void> _handleVerify() async {
    final entered = _controllers.map((c) => c.text).join();
    if (entered.length != 6) {
      AppErrorToast.showMessage(context, 'Enter the 6-digit code sent to your email.');
      return;
    }
    if (_sentCode == null || _codeSentAt == null ||
        DateTime.now().difference(_codeSentAt!) > _codeValidity) {
      AppErrorToast.showMessage(
          context, 'This code has expired. Tap Resend to get a new one.');
      return;
    }
    if (entered != _sentCode) {
      AppErrorToast.showMessage(context, 'Incorrect code. Please try again.');
      return;
    }

    final type = ref.read(currentUserTypeProvider);
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).changePassword(
            currentPassword: widget.currentPassword,
            newPassword: widget.newPassword,
          );
      if (!mounted) return;
      context.go(RouteNames.settingsFor(type));
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
    final type = ref.watch(currentUserTypeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.settingsFor(type));
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(AppStrings.verifyChangeTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.xl2),
                      border: Border.all(color: AppColors.primaryBorder)),
                    child: Icon(Icons.mail_outline_rounded,
                        color: AppColors.primary, size: 26)),
                  const SizedBox(height: 20),
                  Text(AppStrings.verifyChangeCheckEmail,
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                  Text(AppStrings.verifyChangeSubtitle,
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => _OtpBox(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                      },
                    )),
                  ),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Didn't receive it? ",
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    GestureDetector(
                      onTap: _handleResend,
                      child: Text(AppStrings.otpResend,
                          style: AppTypography.bodySmall.copyWith(
                              color: _countdown == 0
                                  ? AppColors.primary
                                  : AppColors.primaryBorder,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                    const SizedBox(width: 6),
                    Text(Formatters.countdown(_countdown),
                        style: AppTypography.bodySmall,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ]),
                  const SizedBox(height: 32),
                  AppButton(
                    label: AppStrings.verifyChangeVerify,
                    onTap: _handleVerify,
                    isLoading: _isLoading,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.borderSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderActive)),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppTypography.heading3,
        cursorColor: AppColors.primary,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none, counterText: ''),
      ),
    );
  }
}