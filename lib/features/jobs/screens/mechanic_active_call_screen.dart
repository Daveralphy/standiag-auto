// Mechanic Active Call screen — mechanic is on call with user.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/services/call_engine_service.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/job_provider.dart';

class MechanicActiveCallScreen extends ConsumerStatefulWidget {
  final String jobId;
  const MechanicActiveCallScreen({super.key, required this.jobId});

  @override
  ConsumerState<MechanicActiveCallScreen> createState() =>
      _MechanicActiveCallScreenState();
}

class _MechanicActiveCallScreenState
    extends ConsumerState<MechanicActiveCallScreen> {
  final CallEngineService _callEngine = CallEngineService();
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _connected = false;
  bool _isEnding = false;
  String? _callError;
  int _seconds = 0;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
    _joinCall();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _callEngine.leave();
    super.dispose();
  }

  Future<void> _joinCall() async {
    try {
      await _callEngine.join(
        channelId: widget.jobId,
        onRemoteJoined: () {
          if (!mounted || _connected) return;
          setState(() => _connected = true);
          _startDurationTimer();
        },
        onRemoteLeft: () {
          if (mounted) _endCall();
        },
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      ErrorHandler.handle(
        error,
        stackTrace,
        screen: 'MechanicActiveCallScreen.joinCall',
        userId: ref.read(currentUserIdProvider),
      );
      setState(() => _callError = _callErrorMessage(error, stackTrace));
    }
  }

  Future<void> _retryCall() async {
    await _callEngine.leave();
    if (!mounted) return;
    setState(() => _callError = null);
    _joinCall();
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  String _callErrorMessage(Object error, StackTrace stackTrace) {
    if (error is StateError && error.message == 'agora-not-configured') {
      return 'Voice calling is not available right now. Please try again later.';
    }
    if (error is StateError && error.message == 'microphone-permission-denied') {
      return 'Microphone permission is required to make calls.';
    }
    return 'We could not connect your call. This appears to be an issue on our end, and we are working to resolve it. Please try again shortly.';
  }

  Future<void> _endCall() async {
    if (_isEnding) return;
    _isEnding = true;
    _durationTimer?.cancel();
    await _callEngine.leave();
    if (!mounted) return;
    context.go(RouteNames.mechanicPostCall, extra: widget.jobId);
  }

  String get _duration {
    final int m = _seconds ~/ 60;
    final int s = _seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(jobProvider.select((s) => s.activeJob));
    final callerAsync = job == null
        ? null
        : ref.watch(mechanicUserProvider(job.carOwnerId));
    final callerName = callerAsync?.valueOrNull != null
        ? '${callerAsync!.valueOrNull!.firstName} ${callerAsync.valueOrNull!.lastName}'
            .trim()
        : 'Car Owner';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'StanDiag Call',
                      style: AppTypography.heading3,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAvatar(name: callerName, size: 100),
                  const SizedBox(height: 20),
                  Text(callerName,
                      style: AppTypography.heading1,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                    Text(
                      _callError ?? (_connected ? _duration : 'Connecting…'),
                      style: AppTypography.body.copyWith(
                        color: _callError == null
                          ? AppColors.success
                          : AppColors.primary),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                    if (_callError != null) ...[
                    const SizedBox(height: 16),
                    AppButton(label: 'Try Again', onTap: _retryCall),
                    ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 0,
                  AppSpacing.pageHorizontal, 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallBtn(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: 'Mute',
                    onTap: () {
                      setState(() => _isMuted = !_isMuted);
                      _callEngine.setMuted(_isMuted);
                    },
                    isActive: _isMuted,
                  ),
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          const BoxShadow(color: Color(0x66E8281E), blurRadius: 20),
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  _CallBtn(
                    icon: Icons.volume_up_rounded,
                    label: 'Speaker',
                    onTap: () {
                      setState(() => _isSpeaker = !_isSpeaker);
                      _callEngine.setSpeakerphoneOn(_isSpeaker);
                    },
                    isActive: _isSpeaker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const _CallBtn({required this.icon, required this.label,
      required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primarySubtle : AppColors.border,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.border),
            ),
            child: Icon(icon,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1),
        ],
      ),
    );
  }
}