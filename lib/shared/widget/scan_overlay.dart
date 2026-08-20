// The scan flow's overlay pieces — a two-stage disclosure that lives on
// top of whichever tab is currently showing, never a route change and
// never a slide-up-from-bottom sheet:
//
//  idle    → normal screen, nothing shown.
//  prompt  → tapping the floating scan icon blurs the current tab and
//            shows a small "Scan" button above the icon. Nothing has
//            opened yet — this is just "you've selected scanning".
//  open    → tapping that "Scan" button reveals the actual diagnostic
//            panel as a centered layer over the (still blurred) tab.
//
// Tapping outside always demotes exactly one stage — open → prompt,
// prompt → idle — never jumps straight back to idle from open, so the
// user is never suddenly unsure whether they're still "in" scanning.

import 'dart:ui';

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
import 'floating_scan_button.dart';
import 'health_gauge.dart';
import 'notched_nav_bar.dart';
import 'obd_device_picker_sheet.dart';

enum ScanOverlayStage { idle, prompt, open }

/// Full-screen blur/dark layer behind the prompt button and modal card.
/// Tapping it demotes the stage by one level via [onTapOutside].
class ScanBackdrop extends StatelessWidget {
  final ScanOverlayStage stage;
  final VoidCallback onTapOutside;

  const ScanBackdrop({
    super.key,
    required this.stage,
    required this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    final visible = stage != ScanOverlayStage.idle;
    return IgnorePointer(
      ignoring: !visible,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapOutside,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              // Deliberately fixed black regardless of theme (same as any
              // modal dimmer) rather than AppColors.background-derived — but
              // strong enough that it reliably darkens a *light*-mode tab
              // too, not just a dark one, so the red prompt button/text
              // sitting on top always has real contrast to work with.
              color: stage == ScanOverlayStage.open
                  ? const Color(0xCC000000)
                  : const Color(0x99000000),
            ),
          ),
        ),
      ),
    );
  }
}

/// The small "Scan" button that floats just above the notch's scan icon
/// once a stage is active. Tapping it opens the diagnostic panel.
class ScanPromptButton extends StatelessWidget {
  final ScanOverlayStage stage;
  final VoidCallback onTap;

  /// How far above the screen's bottom edge the floating scan icon's own
  /// top sits — this button floats just above that point. Callers compute
  /// this from the same constants NotchedNavBar itself uses, so the two
  /// always line up without NotchedNavBar needing to know this exists.
  final double iconTopFromBottom;

  const ScanPromptButton({
    super.key,
    required this.stage,
    required this.onTap,
    required this.iconTopFromBottom,
  });

  @override
  Widget build(BuildContext context) {
    final visible = stage != ScanOverlayStage.idle;
    return Positioned(
      left: 0,
      right: 0,
      bottom: iconTopFromBottom + 14,
      child: IgnorePointer(
        ignoring: !visible,
        child: Center(
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            // Rendered as a sibling in the tab shell's own Stack, outside
            // any Scaffold — same reason NavColumnItem needs this: without
            // a Material ancestor, Text/Icon here have nothing to resolve
            // DefaultTextStyle against.
            child: Material(
              type: MaterialType.transparency,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: AppColors.primaryBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    'Scan',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The actual diagnostic panel — health gauge, OBD status, connect/start —
/// shown as a centered card layer, not a bottom sheet. Absorbs its own
/// taps so tapping inside it never falls through to [ScanBackdrop].
class ScanModalCard extends ConsumerWidget {
  final ScanOverlayStage stage;

  const ScanModalCard({super.key, required this.stage});

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
    ScanState scanState,
  ) async {
    if (!scanState.isConnected) {
      await ObdDevicePickerSheet.show(context);
      return;
    }
    await ref
        .read(scanProvider.notifier)
        .startScan(vehicle.id, vehicle.ownerId);
  }

  Widget _buildCardContent(
    BuildContext context,
    WidgetRef ref,
    List<VehicleModel> vehicles,
    VehicleModel? vehicle,
    ScanState scanState,
    int? latestScore,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Vehicle Diagnostics',
          style: AppTypography.heading3,
          textAlign: TextAlign.center,
        ),
        // Only shown with 2+ vehicles — otherwise there's nothing to pick
        // between, and showing a one-item picker would just be noise.
        if (vehicles.length > 1) ...[
          const SizedBox(height: 14),
          _VehiclePicker(
            vehicles: vehicles,
            selectedId: vehicle?.id,
            onSelect: (id) =>
                ref.read(scanProvider.notifier).selectVehicle(id),
          ),
        ],
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => ObdDevicePickerSheet.show(context),
          child: ObdStatusPill(
            connected: scanState.isConnected,
            connectedName: scanState.connectedDeviceName,
          ),
        ),
        const SizedBox(height: 18),
        HealthGauge(score: latestScore, size: 170),
        const SizedBox(height: 16),
        Text(
          vehicle == null
              ? 'Add a vehicle first, then connect your OBD-II adapter to run a full diagnostic.'
              : !scanState.isConnected
              ? 'Connect your OBD-II adapter via Bluetooth to run a full diagnostic of ${vehicle.displayName}.'
              : 'Ready to scan ${vehicle.displayName}.',
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (vehicle == null)
          AppButton(
            label: 'Add a Vehicle',
            onTap: () => context.push(RouteNames.addVehicle),
          )
        else
          AppButton(
            label: !scanState.isConnected ? 'Connect Adapter' : 'Start Scan',
            isLoading: scanState.isConnectingDevice || scanState.isScanning,
            onTap: () => _handleTap(context, ref, vehicle, scanState),
          ),
        if (scanState.error != null) ...[
          const SizedBox(height: 12),
          Text(
            scanState.error!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = stage == ScanOverlayStage.open;
    final vehicles = ref.watch(profileProvider).vehicles;
    final scanState = ref.watch(scanProvider);
    // Prefer whichever vehicle was explicitly selected, as long as it still
    // exists — falls back to the first vehicle only when nothing's been
    // picked yet (e.g. an owner with just one vehicle never needs to pick).
    final vehicle = vehicles.isEmpty
        ? null
        : vehicles.firstWhere(
            (v) => v.id == scanState.selectedVehicleId,
            orElse: () => vehicles.first,
          );
    final latestScore = scanState.latestScan?.vehicleId == vehicle?.id
        ? scanState.latestScan?.healthScore
        : null;

    return IgnorePointer(
      ignoring: !visible,
      child: Center(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: visible ? 1 : 0.94,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: () {},
              // Rendered as a sibling in the tab shell's own Stack, outside
              // any Scaffold — same reason NavColumnItem needs this: without
              // a Material ancestor, none of the Text below (including
              // inside AppButton, which has no Material of its own either)
              // has a DefaultTextStyle to resolve against.
              child: Material(
                type: MaterialType.transparency,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 340,
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xl4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.modal),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      child: _buildCardContent(
                        context,
                        ref,
                        vehicles,
                        vehicle,
                        scanState,
                        latestScore,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrollable row of tappable vehicle chips — lets an owner
/// with more than one vehicle actually choose which one a scan applies to,
/// instead of it silently always targeting whichever vehicle an unordered
/// Firestore query happened to return first.
class _VehiclePicker extends StatelessWidget {
  final List<VehicleModel> vehicles;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _VehiclePicker({
    required this.vehicles,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final v = vehicles[i];
          final isSelected = v.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(v.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySubtle : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.2 : 1,
                ),
              ),
              child: Text(
                v.displayName,
                style: AppTypography.captionSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Distance from the screen's bottom edge to the top of the notch's
/// floating scan icon — computed from the same constants NotchedNavBar
/// itself uses internally, so [ScanPromptButton] lines up with it exactly.
double scanIconTopFromBottom() =>
    AppSpacing.navBarBottomOffset +
    NotchedNavBar.barHeight +
    (FloatingScanButton.visibleSize / 2);
