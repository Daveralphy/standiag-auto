// OBD-II adapter picker — a bottom sheet that scans for nearby Bluetooth
// devices and connects to whichever one the user taps. Shared by both the
// CarOwner and Mechanic scan screens so the pairing flow is identical.

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../features/scan/providers/scan_provider.dart';
import '../../features/scan/services/elm327_service.dart';

class ObdDevicePickerSheet {
  ObdDevicePickerSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ObdDevicePickerContent(),
    );
  }
}

class _ObdDevicePickerContent extends ConsumerStatefulWidget {
  const _ObdDevicePickerContent();

  @override
  ConsumerState<_ObdDevicePickerContent> createState() =>
      _ObdDevicePickerContentState();
}

class _ObdDevicePickerContentState
    extends ConsumerState<_ObdDevicePickerContent> {
  String? _connectingId;
  bool _showUnnamedDevices = false;

  // Captured once while `ref` is still guaranteed valid. `dispose()` runs as
  // this widget's element is being torn down, and Riverpod's `ref` accessor
  // can throw StateError("Cannot use \"ref\" after the widget was disposed")
  // if touched at that point — so cleanup must use this captured reference
  // instead of calling `ref.read(...)` again inside dispose().
  late final ScanNotifier _scanNotifier;

  @override
  void initState() {
    super.initState();
    _scanNotifier = ref.read(scanProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanNotifier.startDeviceDiscovery();
    });
  }

  @override
  void dispose() {
    _scanNotifier.stopDeviceDiscovery();
    super.dispose();
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _connectingId = device.remoteId.str);
    final success = await _scanNotifier.connectToDevice(device);
    if (!mounted) return;
    setState(() => _connectingId = null);
    if (success) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl5)),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                    AppSpacing.xl4, AppSpacing.pageHorizontal, AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text('Connect OBD-II Adapter',
                          style: AppTypography.heading3,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      if (state.isDiscovering)
                        const Positioned(
                          right: 0,
                          child: SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Text(
                  state.isDiscovering
                      ? 'Searching for nearby Bluetooth devices…'
                      : 'Make sure your OBD-II adapter is plugged in and powered on.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(builder: (context) {
                  final likely = state.discoveredDevices
                      .where(Elm327Service.looksLikeObdAdapter)
                      .toList();
                  final named = state.discoveredDevices.where((d) =>
                      !Elm327Service.looksLikeObdAdapter(d) &&
                      Elm327Service.displayNameFor(d).isNotEmpty).toList();
                  final unnamed = state.discoveredDevices.where((d) =>
                      !Elm327Service.looksLikeObdAdapter(d) &&
                      Elm327Service.displayNameFor(d).isEmpty).toList();

                  if (state.discoveredDevices.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                state.isDiscovering
                                    ? Icons.bluetooth_searching_rounded
                                    : Icons.bluetooth_disabled_rounded,
                                color: const Color(0x33FFFFFF), size: 40),
                            const SizedBox(height: 12),
                            Text(
                              state.isDiscovering
                                  ? 'Looking for devices…'
                                  : 'No devices found yet.',
                              style: AppTypography.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                            if (!state.isDiscovering) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () =>
                                    _scanNotifier.startDeviceDiscovery(),
                                child: const Text('Search again',
                                    style: TextStyle(
                                      fontFamily: 'Inter', fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    )),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal),
                    children: [
                      if (likely.isNotEmpty) ...[
                        const _SectionLabel('Likely Your Adapter',
                            color: AppColors.success),
                        for (final result in likely) ...[
                          _DeviceTile(
                            result: result,
                            isLikely: true,
                            isConnecting: _connectingId ==
                                result.device.remoteId.str,
                            disabled: state.isConnectingDevice,
                            onTap: () => _connect(result.device),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 4),
                      ],
                      if (named.isNotEmpty) ...[
                        _SectionLabel(likely.isEmpty
                            ? 'Nearby Devices'
                            : 'Other Nearby Devices'),
                        for (final result in named) ...[
                          _DeviceTile(
                            result: result,
                            isLikely: false,
                            isConnecting: _connectingId ==
                                result.device.remoteId.str,
                            disabled: state.isConnectingDevice,
                            onTap: () => _connect(result.device),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                      if (unnamed.isNotEmpty) ...[
                        if (!_showUnnamedDevices)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showUnnamedDevices = true),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10),
                              child: Text(
                                "Not seeing your adapter? Show ${unnamed.length} more unnamed ${unnamed.length == 1 ? 'device' : 'devices'}",
                                style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else ...[
                          const _SectionLabel('Unnamed Devices'),
                          for (final result in unnamed) ...[
                            _DeviceTile(
                              result: result,
                              isLikely: false,
                              isConnecting: _connectingId ==
                                  result.device.remoteId.str,
                              disabled: state.isConnectingDevice,
                              onTap: () => _connect(result.device),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ],
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  child: Text(state.error!,
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;
  const _SectionLabel(this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.microBold.copyWith(
          color: color ?? const Color(0x66FFFFFF),
          letterSpacing: 0.8,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final bool isLikely;
  final bool isConnecting;
  final bool disabled;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.result,
    required this.isLikely,
    required this.isConnecting,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = Elm327Service.displayNameFor(result);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLikely ? const Color(0x144CAF50) : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
              color: isLikely ? const Color(0x664CAF50) : AppColors.border,
              width: isLikely ? 1.2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isLikely
                    ? const Color(0x1F4CAF50)
                    : AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                    color: isLikely
                        ? const Color(0x664CAF50)
                        : AppColors.primaryBorder),
              ),
              child: Icon(
                  isLikely ? Icons.check_circle_rounded : Icons.bluetooth_rounded,
                  color: isLikely ? AppColors.success : AppColors.primary,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isNotEmpty ? name : 'Unknown device',
                      style: AppTypography.bodyLarge,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  if (isLikely) ...[
                    const SizedBox(height: 2),
                    const Text('Likely your OBD-II adapter',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        )),
                  ],
                ],
              ),
            ),
            if (isConnecting)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textDisabled, size: 18),
          ],
        ),
      ),
    );
  }
}
