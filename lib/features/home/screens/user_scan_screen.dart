import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_nav_bar.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/health_gauge.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/screens/user_drawer_screen.dart';
import '../../scan/providers/scan_provider.dart';

class UserScanScreen extends ConsumerStatefulWidget {
  const UserScanScreen({super.key});

  @override
  ConsumerState<UserScanScreen> createState() => _UserScanScreenState();
}

class _UserScanScreenState extends ConsumerState<UserScanScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  Future<void> _startScan(String vehicleId, String ownerId) async {
    await ref.read(scanProvider.notifier).startScan(vehicleId, ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const UserDrawerScreen(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppScreenHeader(
                  scaffoldKey: _scaffoldKey,
                  title: 'Scan Vehicle',
                  subtitle: 'Diagnose your car',
                  trailingIcon: Icons.history_rounded,
                  onTrailingTap: () =>
                      context.go(RouteNames.userScanHistory),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Consumer(builder: (context, ref, _) {
                    final vehiclesState = ref.watch(profileProvider);
                    final scanState = ref.watch(scanProvider);
                    final vehicle = vehiclesState.vehicles.isNotEmpty
                        ? vehiclesState.vehicles.first
                        : null;
                    final latestScoreForVehicle = scanState.latestScan
                                ?.vehicleId ==
                            vehicle?.id
                        ? scanState.latestScan?.healthScore
                        : (scanState.history
                                .where((s) => s.vehicleId == vehicle?.id)
                                .isNotEmpty
                            ? scanState.history
                                .firstWhere((s) => s.vehicleId == vehicle?.id)
                                .healthScore
                            : null);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal, 0,
                          AppSpacing.pageHorizontal,
                          AppSpacing.navBarClearance),
                      child: Column(
                        children: [
                          ObdStatusPill(connected: scanState.isConnected),
                          const SizedBox(height: 20),
                          HealthGauge(score: latestScoreForVehicle),
                          const SizedBox(height: 20),
                          const Text('Vehicle Diagnostics',
                              style: AppTypography.heading2,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Text(
                            vehicle == null
                                ? 'Add a vehicle first, then connect your\nOBD-II adapter to run a full diagnostic.'
                                : 'Connect your OBD-II adapter via Bluetooth\nand tap Scan to run a full diagnostic of\n${vehicle.displayName}.',
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
                              label: 'Tap to Scan',
                              isLoading: scanState.isScanning,
                              onTap: () =>
                                  _startScan(vehicle.id, vehicle.ownerId),
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
                    );
                  }),
                ),
              ],
            ),
          ),
          AppNavBar(
            activeItem: NavBarItem.scan,
            userType: NavBarUserType.carOwner,
            onScanTap: () {},
            onHomeTap: () => context.go(RouteNames.userHome),
            onThirdTap: () => context.go(RouteNames.userMechanics),
          ),
        ],
      ),
    );
  }
}
