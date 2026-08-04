// Vehicle Diagnostics (Scan) screen — a distinct screen from the Vehicle
// tab, reached by tapping the shell's floating scan button. Owns the
// health gauge and the OBD-II connect/scan flow; the Vehicle tab itself is
// just a profile view and never shows this content inline.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/health_gauge.dart';
import '../../../shared/widget/obd_device_picker_sheet.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/models/vehicle_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/scan_provider.dart';

class UserScanScreen extends ConsumerStatefulWidget {
  const UserScanScreen({super.key});

  @override
  ConsumerState<UserScanScreen> createState() => _UserScanScreenState();
}

class _UserScanScreenState extends ConsumerState<UserScanScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _handleTap(VehicleModel vehicle, ScanState scanState) async {
    if (!scanState.isConnected) {
      await ObdDevicePickerSheet.show(context);
      return;
    }
    await ref
        .read(scanProvider.notifier)
        .startScan(vehicle.id, vehicle.ownerId);
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(profileProvider).vehicles;
    final vehicle = vehicles.isNotEmpty ? vehicles.first : null;
    final scanState = ref.watch(scanProvider);
    final latestScore = scanState.latestScan?.vehicleId == vehicle?.id
        ? scanState.latestScan?.healthScore
        : null;

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
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go(RouteNames.userVehicle),
                    child: Container(
                      width: 32,
                      height: 32,
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
                      'Vehicle Diagnostics',
                      style: AppTypography.heading3,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => ObdDevicePickerSheet.show(context),
                      child: ObdStatusPill(
                        connected: scanState.isConnected,
                        connectedName: scanState.connectedDeviceName,
                      ),
                    ),
                    const SizedBox(height: 24),
                    HealthGauge(score: latestScore),
                    const SizedBox(height: 24),
                    const Text(
                      'Run a Full Diagnostic',
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle == null
                          ? 'Add a vehicle first, then connect your\nOBD-II adapter to run a full diagnostic.'
                          : !scanState.isConnected
                          ? 'Connect your OBD-II adapter via Bluetooth\nto run a full diagnostic of ${vehicle.displayName}.'
                          : 'Ready to scan ${vehicle.displayName}.\nTap below to start.',
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (vehicle == null)
                      AppButton(
                        label: 'Add a Vehicle',
                        onTap: () => context.push(RouteNames.addVehicle),
                      )
                    else
                      AppButton(
                        label: !scanState.isConnected
                            ? 'Connect Adapter'
                            : 'Start Scan',
                        isLoading:
                            scanState.isConnectingDevice ||
                            scanState.isScanning,
                        onTap: () => _handleTap(vehicle, scanState),
                      ),
                    if (scanState.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        scanState.error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
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
