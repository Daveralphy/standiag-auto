import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/theme/app_colors.dart';
import 'scan_connecting_screen.dart';

class BtDeviceListScreen extends StatefulWidget {
  const BtDeviceListScreen({super.key});

  @override
  State<BtDeviceListScreen> createState() => _BtDeviceListScreenState();
}

class _BtDeviceListScreenState extends State<BtDeviceListScreen> {
  final List<ScanResult> _results = [];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _results.clear();
      _scanning = true;
    });

    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          for (final r in results) {
            if (!_results.any((e) =>
                e.device.remoteId == r.device.remoteId)) {
              _results.add(r);
            }
          }
        });
      }
    });

    await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10));

    if (mounted) setState(() => _scanning = false);
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  bool _isLikelyOBD(String name) {
    final n = name.toLowerCase();
    return n.contains('elm') ||
        n.contains('obd') ||
        n.contains('obdii') ||
        n.contains('vlink') ||
        n.contains('v-link') ||
        n.contains('carista') ||
        n.contains('icar');
  }

  @override
  Widget build(BuildContext context) {
    final obdDevices =
        _results.where((r) => _isLikelyOBD(r.device.platformName)).toList();
    final otherDevices =
        _results.where((r) => !_isLikelyOBD(r.device.platformName)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Select Adapter',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter')),
                  ),
                  if (_scanning)
                    const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2),
                    )
                  else
                    GestureDetector(
                      onTap: _startScan,
                      child: const Text('Rescan',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontFamily: 'Inter')),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  'Select your ELM327 OBD adapter from the list below.',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bluetooth_searching_rounded,
                              color: AppColors.textTertiary,
                              size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _scanning
                                ? 'Scanning for devices...'
                                : 'No devices found.\nMake sure your adapter is plugged in.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.5,
                                fontFamily: 'Inter'),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20),
                      children: [
                        if (obdDevices.isNotEmpty) ...[
                          const _SectionLabel(
                              label: 'OBD ADAPTERS DETECTED'),
                          const SizedBox(height: 8),
                          ...obdDevices.map((r) =>
                              _DeviceTile(
                                  result: r,
                                  isOBD: true,
                                  onTap: () =>
                                      _connect(r.device))),
                          const SizedBox(height: 16),
                        ],
                        if (otherDevices.isNotEmpty) ...[
                          const _SectionLabel(
                              label: 'OTHER DEVICES'),
                          const SizedBox(height: 8),
                          ...otherDevices.map((r) =>
                              _DeviceTile(
                                  result: r,
                                  isOBD: false,
                                  onTap: () =>
                                      _connect(r.device))),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _connect(BluetoothDevice device) {
    FlutterBluePlus.stopScan();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ScanConnectingScreen(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
            fontFamily: 'Inter'));
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final bool isOBD;
  final VoidCallback onTap;

  const _DeviceTile({
    required this.result,
    required this.isOBD,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown Device';
    final rssi = result.rssi;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isOBD
                  ? AppColors.primaryBorder
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isOBD
                    ? AppColors.primarySubtle
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isOBD
                        ? AppColors.primaryBorder
                        : AppColors.border),
              ),
              child: Icon(
                isOBD
                    ? Icons.power_outlined
                    : Icons.bluetooth_rounded,
                color: isOBD
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Text(
                      result.device.remoteId.toString(),
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isOBD)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('OBD',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFamily: 'Inter')),
                  ),
                const SizedBox(height: 4),
                Text('$rssi dBm',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

