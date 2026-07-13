// Scan History screen — list of past OBD scans for the user.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/scan_model.dart';
import '../providers/scan_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_skeleton.dart';
import '../../../shared/widget/system_ui_style.dart';

class ScanHistoryScreen extends ConsumerStatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  ConsumerState<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends ConsumerState<ScanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return;
      }
      ref.read(scanProvider.notifier).fetchHistory(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScanState>(scanProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final state = ref.watch(scanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.md,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.userHome);
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    AppStrings.scanHistoryTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: state.isScanning && state.history.isEmpty
                  ? ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, __) => const _ScanCardSkeleton(),
                    )
                  : state.history.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.speed_rounded,
                                    color: Color(0x33FFFFFF), size: 48),
                                SizedBox(height: 16),
                                Text('No scans yet',
                                    style: AppTypography.heading3),
                                SizedBox(height: 8),
                                Text(
                                    'Connect your OBD-II adapter and run a scan to see your vehicle\'s diagnostic history here.',
                                    style: AppTypography.body,
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.pageHorizontal,
                          ),
                          itemCount: state.history.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 11),
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () => context.push(RouteNames.scanDetail,
                                extra: state.history[i].id),
                            child: _ScanCard(scan: state.history[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanCard extends ConsumerWidget {
  final ScanModel scan;
  const _ScanCard({required this.scan});

  Color get _scoreColor {
    if (scan.healthScore >= 8) return AppColors.success;
    if (scan.healthScore >= 5) return AppColors.amber;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(scan.vehicleId));
    final vehicleName = vehicleAsync.valueOrNull?.displayName ?? 'Vehicle';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                scan.healthScore.toString(),
                style: AppTypography.healthScore
                    .copyWith(fontSize: 22, letterSpacing: -1),
              ),
              const SizedBox(width: 5),
              const Text('/ 10',
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ],
          ),
          const SizedBox(height: 2),
          Text(vehicleName,
              style: AppTypography.body,
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 2),
          Text(Formatters.shortDate(scan.createdAt),
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Health Score',
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(scan.healthLabel,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700, color: _scoreColor,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: (scan.healthScore.clamp(0, 10)) / 10,
                backgroundColor: const Color(0x14FFFFFF),
                valueColor: AlwaysStoppedAnimation(_scoreColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanCardSkeleton extends StatelessWidget {
  const _ScanCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeleton(width: 44, height: 44, radius: AppRadius.full),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton.wide(height: 12),
                SizedBox(height: 6),
                AppSkeleton(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
