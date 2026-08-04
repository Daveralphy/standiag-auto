// Vehicle Diagnostics (Scan) sheet — a modal that floats on top of
// whichever tab the car owner is on when they tap the shell's floating
// scan button, dismissible by tapping outside it (showModalBottomSheet's
// default barrier-dismiss). Owns the health gauge and the OBD-II
// connect/scan flow; the Vehicle tab itself never shows this content
// inline.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/route_names.dart';
import '../../features/profile/models/vehicle_model.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/scan/providers/scan_provider.dart';
import 'app_button.dart';
import 'health_gauge.dart';
import 'obd_device_picker_sheet.dart';

class ScanSheet {
  ScanSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScanSheetContent(),
    );
  }
}

class _ScanSheetContent extends ConsumerStatefulWidget {
  const _ScanSheetContent();

  @override
  ConsumerState<_ScanSheetContent> createState() => _ScanSheetContentState();
}

class _ScanSheetContentState extends ConsumerState<_ScanSheetContent> {
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

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl5),
            ),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl4,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: Text(
                  'Vehicle Diagnostics',
                  style: AppTypography.heading3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => ObdDevicePickerSheet.show(context),
                        child: ObdStatusPill(
                          connected: scanState.isConnected,
                          connectedName: scanState.connectedDeviceName,
                        ),
                      ),
                      const SizedBox(height: 20),
                      HealthGauge(score: latestScore, size: 190),
                      const SizedBox(height: 20),
                      const Text(
                        'Run a Full Diagnostic',
                        style: AppTypography.heading3,
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
                      const SizedBox(height: 24),
                      if (vehicle == null)
                        AppButton(
                          label: 'Add a Vehicle',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push(RouteNames.addVehicle);
                          },
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
        );
      },
    );
  }
}
