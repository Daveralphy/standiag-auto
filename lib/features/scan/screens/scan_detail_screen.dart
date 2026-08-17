// Scan Detail screen — full breakdown of a single past OBD scan: health
// score, real diagnostic readings (RPM/coolant/speed), and any stored
// trouble codes with their descriptions. All values come straight from the
// scan's own rawData — nothing here is fabricated for display.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/data/dtc_reference_data.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widget/health_gauge.dart';
import '../../../shared/widget/profile_field_row.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/scan_model.dart';
import '../providers/scan_provider.dart';

class ScanDetailScreen extends ConsumerStatefulWidget {
  final String scanId;
  const ScanDetailScreen({super.key, required this.scanId});

  @override
  ConsumerState<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends ConsumerState<ScanDetailScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  Color _scoreColor(int score) {
    if (score >= 8) return AppColors.success;
    if (score >= 5) return AppColors.amber;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(scanProvider).history;
    final scan = history.where((s) => s.id == widget.scanId).firstOrNull;

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
                      context.go(RouteNames.userScanHistory);
                    }
                  },
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Scan Details',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            Expanded(
              child: scan == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Scan not found',
                              style: AppTypography.heading3),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => context.canPop()
                                ? context.pop()
                                : context.go(RouteNames.userScanHistory),
                            child: Text('Go back',
                                style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    )
                  : _ScanDetailBody(scan: scan, scoreColor: _scoreColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanDetailBody extends ConsumerWidget {
  final ScanModel scan;
  final Color Function(int score) scoreColor;
  const _ScanDetailBody({required this.scan, required this.scoreColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleByIdProvider(scan.vehicleId));
    final vehicleName = vehicleAsync.valueOrNull?.displayName ?? 'Vehicle';

    final rpm = scan.rawData['rpm'] as int?;
    final coolant = scan.rawData['coolantTempC'] as int?;
    final speed = scan.rawData['speedKph'] as int?;
    final dtcCodes = (scan.rawData['dtcCodes'] as List?)?.cast<String>() ?? const [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Column(
        children: [
          const SizedBox(height: 12),
          HealthGauge(score: scan.healthScore, size: 200),
          const SizedBox(height: 8),
          Text(vehicleName,
              style: AppTypography.heading2,
              overflow: TextOverflow.ellipsis, maxLines: 1,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(Formatters.dateWithTime(scan.createdAt),
              style: AppTypography.caption,
              overflow: TextOverflow.ellipsis, maxLines: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Health Score',
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(scan.healthLabel,
                  style: TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scoreColor(scan.healthScore),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: scan.healthScore.clamp(0, 10) / 10,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(scoreColor(scan.healthScore)),
              ),
            ),
          ),

          if (rpm != null || coolant != null || speed != null) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Diagnostic Readings',
                  style: AppTypography.heading4,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
            if (rpm != null)
              ProfileFieldRow(label: 'Engine RPM', value: '$rpm rpm'),
            if (coolant != null)
              ProfileFieldRow(
                  label: 'Coolant Temperature', value: '$coolant°C'),
            if (speed != null)
              ProfileFieldRow(label: 'Vehicle Speed', value: '$speed km/h'),
          ],

          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Trouble Codes',
                style: AppTypography.heading4,
                overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          const SizedBox(height: 10),
          if (dtcCodes.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl2),
              decoration: BoxDecoration(
                color: const Color(0x144CAF50),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: const Color(0x334CAF50)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('No trouble codes found — this scan came back clean.',
                        style: AppTypography.body),
                  ),
                ],
              ),
            )
          else
            ...dtcCodes.map((code) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(AppSpacing.xl2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.primaryBorder),
                        ),
                        child: Text(code,
                            style: AppTypography.captionLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(DtcReferenceData.describe(code),
                            style: AppTypography.body,
                            overflow: TextOverflow.ellipsis, maxLines: 2),
                      ),
                    ],
                  ),
                )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
