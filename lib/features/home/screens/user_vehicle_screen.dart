// Vehicle tab (formerly Scan) — the car owner's active vehicle, its
// diagnostics, and OBD connection status. The floating scan button that
// triggers a new diagnostic lives one level up in tab_shell.dart, not here
// — it's a shell-level sibling, not a child of this screen, so it survives
// this screen being swapped out and back in via the IndexedStack.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_screen_backdrop.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/health_gauge.dart';
import '../../../shared/widget/obd_device_picker_sheet.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/providers/profile_provider.dart';
import '../../scan/providers/scan_provider.dart';

class UserVehicleScreen extends ConsumerStatefulWidget {
  const UserVehicleScreen({super.key});

  @override
  ConsumerState<UserVehicleScreen> createState() => _UserVehicleScreenState();
}

class _UserVehicleScreenState extends ConsumerState<UserVehicleScreen> {
  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = ref.read(currentUserIdProvider);
      if (ownerId == null) return;
      ref.read(profileProvider.notifier).fetchVehicles(ownerId);
      ref.read(scanProvider.notifier).fetchHistory(ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesState = ref.watch(profileProvider);
    final scanState = ref.watch(scanProvider);
    final vehicle = vehiclesState.vehicles.isNotEmpty
        ? vehiclesState.vehicles.first
        : null;
    final latestScoreForVehicle = scanState.latestScan?.vehicleId == vehicle?.id
        ? scanState.latestScan?.healthScore
        : (scanState.history.where((s) => s.vehicleId == vehicle?.id).isNotEmpty
              ? scanState.history
                    .firstWhere((s) => s.vehicleId == vehicle?.id)
                    .healthScore
              : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AppScreenBackdrop(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppScreenHeader(
                  title: 'Your Vehicle',
                  subtitle: vehicle?.displayName ?? 'No vehicle added',
                  trailingIcon: Icons.settings_outlined,
                  onTrailingTap: () => context.push(RouteNames.myVehicles),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      0,
                      AppSpacing.pageHorizontal,
                      AppSpacing.navBarClearance + 90,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => ObdDevicePickerSheet.show(context),
                          child: ObdStatusPill(
                            connected: scanState.isConnected,
                            connectedName: scanState.connectedDeviceName,
                          ),
                        ),
                        const SizedBox(height: 20),
                        HealthGauge(score: latestScoreForVehicle),
                        const SizedBox(height: 20),
                        const Text(
                          'Vehicle Diagnostics',
                          style: AppTypography.heading2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicle == null
                              ? 'Add a vehicle first, then connect your\nOBD-II adapter to run a full diagnostic.'
                              : !scanState.isConnected
                              ? 'Connect your OBD-II adapter via Bluetooth\nto run a full diagnostic of ${vehicle.displayName}.'
                              : 'Tap the scan button to run a full diagnostic\nof ${vehicle.displayName}.',
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        if (vehicle == null)
                          AppButton(
                            label: 'Add a Vehicle',
                            onTap: () => context.push(RouteNames.addVehicle),
                          )
                        else if (!scanState.isConnected)
                          AppButton(
                            label: 'Connect Adapter',
                            isLoading: scanState.isConnectingDevice,
                            onTap: () => ObdDevicePickerSheet.show(context),
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
                      ],
                    ),
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
