// Outgoing Call screen — car owner's side while waiting for a directly-
// called mechanic to answer. Watches the job doc (via jobProvider) for the
// mechanic's answer or decline, and gives up with a "no answer" state after
// a timeout. Reached with context.push from MechanicCandidateProfileScreen
// so cancelling naturally pops back to where the call started.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/job_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../providers/mechanics_provider.dart';

class OutgoingCallScreen extends ConsumerStatefulWidget {
  final String jobId;
  final String mechanicId;
  const OutgoingCallScreen({
    super.key,
    required this.jobId,
    required this.mechanicId,
  });

  @override
  ConsumerState<OutgoingCallScreen> createState() =>
      _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends ConsumerState<OutgoingCallScreen>
    with SingleTickerProviderStateMixin {
  static const _ringTimeout = Duration(seconds: 30);

  late final AnimationController _ringController;
  late final Animation<double> _ringAnimation;
  Timer? _timeoutTimer;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    ref.read(jobProvider.notifier).watchActiveJob(widget.jobId);
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _ringAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _timeoutTimer = Timer(_ringTimeout, _handleNoAnswer);
  }

  @override
  void dispose() {
    _ringController.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _handleNoAnswer() {
    if (_handled || !mounted) return;
    _handled = true;
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.rejected);
    AppErrorToast.showMessage(
      context,
      'The mechanic is unavailable right now. Please try another mechanic or try again later.',
    );
    context.pop();
  }

  void _cancel() {
    if (_handled) return;
    _handled = true;
    _timeoutTimer?.cancel();
    ref.read(jobProvider.notifier).updateStatus(widget.jobId, JobStatus.rejected);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final mechanicUserAsync =
        ref.watch(mechanicUserProvider(widget.mechanicId));
    final mechanicName = mechanicUserAsync.valueOrNull != null
        ? '${mechanicUserAsync.valueOrNull!.firstName} ${mechanicUserAsync.valueOrNull!.lastName}'
            .trim()
        : 'Mechanic';

    ref.listen(jobProvider.select((s) => s.activeJob), (previous, next) {
      if (_handled || next == null) return;
      if (next.callAnsweredAt != null) {
        _handled = true;
        _timeoutTimer?.cancel();
        context.go(RouteNames.inAppCall, extra: {
          'jobId': widget.jobId,
          'mechanicId': widget.mechanicId,
        });
      } else if (next.status == JobStatus.rejected) {
        _handled = true;
        _timeoutTimer?.cancel();
        AppErrorToast.showMessage(context, '$mechanicName declined the call.');
        context.pop();
      }
    });

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
                  onTap: _cancel,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textPrimary)),
                ),
              ]),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _ringAnimation,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryBorder, width: 2)),
                      child: Center(
                        child: AppAvatar(name: mechanicName, size: 96),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(mechanicName,
                      style: AppTypography.heading1,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                  Text('Calling…',
                      style: AppTypography.body,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: _cancel,
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          const BoxShadow(color: Color(0x66E8281E), blurRadius: 20),
                        ]),
                      child: const Icon(Icons.call_end_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text('Cancel',
                        style: AppTypography.caption,
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
