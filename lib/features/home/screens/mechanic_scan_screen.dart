// Mechanic Scan screen — OBD diagnostic scan for a customer's vehicle
// during an active job. Nav bar active: Scan. Bell icon top right.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/health_gauge.dart';
import '../../../shared/widget/obd_device_picker_sheet.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/providers/job_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/mechanic_drawer_screen.dart';
import '../../scan/providers/scan_provider.dart';

class MechanicScanScreen extends ConsumerStatefulWidget {
  const MechanicScanScreen({super.key});

  @override
  ConsumerState<MechanicScanScreen> createState() =>
      _MechanicScanScreenState();
}

class _MechanicScanScreenState extends ConsumerState<MechanicScanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  Future<void> _startScan(String vehicleId, String ownerId) async {
    await ref.read(scanProvider.notifier).startScan(vehicleId, ownerId);
  }

  @override
  Widget build(BuildContext context) {
    final mechanicId = ref.watch(currentUserIdProvider);
    final activeJobAsync = mechanicId == null
        ? null
        : ref.watch(activeJobForMechanicProvider(mechanicId));
    final job = activeJobAsync?.valueOrNull;
    final vehicleAsync =
        job == null ? null : ref.watch(vehicleByIdProvider(job.vehicleId));
    final vehicle = vehicleAsync?.valueOrNull;
    final scanState = ref.watch(scanProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const MechanicDrawerScreen(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppScreenHeader(
                  scaffoldKey: _scaffoldKey,
                  title: AppStrings.homeMechanicScanTitle,
                  subtitle: AppStrings.homeMechanicScanSubtitle,
                  trailingIcon: Icons.history_rounded,
                  onTrailingTap: () => context.go(RouteNames.jobHistory),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, 0,
                        AppSpacing.pageHorizontal,
                        AppSpacing.navBarClearance),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => ObdDevicePickerSheet.show(context),
                          child: ObdStatusPill(
                              connected: scanState.isConnected,
                              connectedName: scanState.connectedDeviceName),
                        ),
                        const SizedBox(height: 20),
                        HealthGauge(score: scanState.latestScan?.healthScore),
                        const SizedBox(height: 20),
                        const Text(
                          'Vehicle Diagnostics',
                          style: AppTypography.heading2,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vehicle == null
                              ? "You don't have an active job right now. Accept a job request to start diagnosing a customer's vehicle."
                              : !scanState.isConnected
                                  ? 'Connect your OBD-II adapter via Bluetooth to run a full diagnostic of ${vehicle.displayName}.'
                                  : 'Tap Scan to run a full diagnostic of ${vehicle.displayName}.',
                          style: AppTypography.body,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          label: !scanState.isConnected
                              ? 'Connect Adapter'
                              : 'Tap to Scan',
                          isLoading: scanState.isScanning ||
                              scanState.isConnectingDevice,
                          onTap: vehicle == null || job == null
                              ? null
                              : !scanState.isConnected
                                  ? () => ObdDevicePickerSheet.show(context)
                                  : () => _startScan(vehicle.id, job.carOwnerId),
                        ),
                        if (scanState.error != null) ...[
                          const SizedBox(height: 12),
                          Text(scanState.error!,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.primary),
                              textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.scan,
            userType: NavBarUserType.mechanic,
            onScanTap: () {},
            onHomeTap: () => context.go(RouteNames.mechanicHome),
            onThirdTap: () => context.go(RouteNames.mechanicUsers),
          ),
        ],
      ),
    );
  }
}
