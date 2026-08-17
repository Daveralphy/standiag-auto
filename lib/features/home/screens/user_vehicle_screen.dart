// Vehicle tab — the car owner's active vehicle, front and center: its own
// photo, name, and stats. Any other registered vehicles are listed below
// it, smaller. This is a profile screen, not the scan flow — the health
// gauge and OBD-II connect/scan experience live on their own screen
// (UserScanScreen), reached via the shell's floating scan button, not here.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_screen_header.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../../shared/widget/vehicle_ads_carousel.dart';
import '../../profile/models/vehicle_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../../scan/models/scan_model.dart';
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
    SystemUiStyle.apply();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = ref.read(currentUserIdProvider);
      if (ownerId == null) return;
      ref.read(profileProvider.notifier).fetchVehicles(ownerId);
      ref.read(scanProvider.notifier).fetchHistory(ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(profileProvider.select((s) => s.vehicles));
    final scanState = ref.watch(scanProvider);
    final vehicle = vehicles.isNotEmpty ? vehicles.first : null;
    final otherVehicles = vehicles.length > 1
        ? vehicles.skip(1).toList()
        : const <VehicleModel>[];

    final scansForVehicle = vehicle == null
        ? const <ScanModel>[]
        : scanState.history.where((s) => s.vehicleId == vehicle.id).toList();
    // scanState.history is already newest-first, so the first match for
    // this vehicle is its latest scan.
    final latestScanForVehicle = vehicle == null
        ? null
        : (scanState.latestScan?.vehicleId == vehicle.id
              ? scanState.latestScan
              : (scansForVehicle.isNotEmpty ? scansForVehicle.first : null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppScreenHeader(
              title: 'Your Vehicle',
              subtitle: vehicle?.displayName ?? 'No vehicle added',
              trailingIcon: Icons.settings_outlined,
              onTrailingTap: () => context.push(RouteNames.myVehicles),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.navBarClearance + 24,
                ),
                child: Column(
                  children: [
                    if (vehicle == null)
                      _EmptyVehicleCard(
                        onAdd: () => context.push(RouteNames.addVehicle),
                      )
                    else
                      _ActiveVehicleCard(
                        vehicle: vehicle,
                        latestScan: latestScanForVehicle,
                        totalScans: scansForVehicle.length,
                      ),
                    if (otherVehicles.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Other Vehicles',
                          style: AppTypography.heading4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < otherVehicles.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _OtherVehicleCard(
                          vehicle: otherVehicles[i],
                          onTap: () => context.push(
                            RouteNames.editVehicle,
                            extra: otherVehicles[i].id,
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    const VehicleAdsCarousel(),
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

class _ActiveVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final ScanModel? latestScan;
  final int totalScans;

  const _ActiveVehicleCard({
    required this.vehicle,
    required this.latestScan,
    required this.totalScans,
  });

  @override
  Widget build(BuildContext context) {
    final meta = [
      vehicle.type,
      vehicle.colour,
      vehicle.fuelType,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty
                ? Image.network(
                    vehicle.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const _VehiclePhotoPlaceholder(),
                  )
                : const _VehiclePhotoPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.displayName,
                  style: AppTypography.heading2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: AppTypography.body,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
                const SizedBox(height: 16),
                Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatColumn(
                        value: latestScan == null
                            ? '—'
                            : '${latestScan!.healthScore}',
                        label: 'HEALTH SCORE',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.borderSubtle,
                    ),
                    Expanded(
                      child: _StatColumn(
                        value: latestScan == null
                            ? 'Never'
                            : Formatters.shortDate(latestScan!.createdAt),
                        label: 'LAST SCAN',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.borderSubtle,
                    ),
                    Expanded(
                      child: _StatColumn(
                        value: '$totalScans',
                        label: 'TOTAL SCANS',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;

  const _OtherVehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = [
      vehicle.type,
      vehicle.colour,
      vehicle.fuelType,
    ].where((s) => s.isNotEmpty).join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 48,
                height: 48,
                child: vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty
                    ? Image.network(
                        vehicle.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _VehiclePhotoPlaceholder(iconSize: 22),
                      )
                    : const _VehiclePhotoPlaceholder(iconSize: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiclePhotoPlaceholder extends StatelessWidget {
  final double iconSize;
  const _VehiclePhotoPlaceholder({this.iconSize = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySubtle,
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          color: AppColors.primary,
          size: iconSize,
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.heading4,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 0.4,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _EmptyVehicleCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyVehicleCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            color: AppColors.textMuted,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicle added yet',
            style: AppTypography.heading3,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your car to see its stats and run diagnostics with OBD.',
            style: AppTypography.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AppButton(label: 'Add a Vehicle', onTap: onAdd),
        ],
      ),
    );
  }
}
