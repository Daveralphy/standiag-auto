// Mechanic Active Call screen — mechanic is on call with user.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/mechanics/providers/mechanics_provider.dart';
import '../../../shared/widget/app_avatar.dart';
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
  bool _isMuted = false;
  bool _isSpeaker = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds++);
      return true;
    });
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
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Text('StanDiag Call',
                  style: AppTypography.heading3,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
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
                  Text(_duration,
                      style: AppTypography.body.copyWith(
                          color: AppColors.success),
                      overflow: TextOverflow.ellipsis, maxLines: 1),
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
                    onTap: () => setState(() => _isMuted = !_isMuted),
                    isActive: _isMuted,
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.mechanicPostCall,
                        extra: widget.jobId),
                    child: Container(
                      width: 64, height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Color(0x66E8281E), blurRadius: 20),
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  _CallBtn(
                    icon: Icons.volume_up_rounded,
                    label: 'Speaker',
                    onTap: () => setState(() => _isSpeaker = !_isSpeaker),
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
              color: isActive ? AppColors.primarySubtle : const Color(0x12FFFFFF),
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