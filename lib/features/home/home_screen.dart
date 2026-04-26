import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/providers/vehicle_provider.dart';
import '../history/scan_history_screen.dart';
import '../maintenance/maintenance_screen.dart';
import '../notifications/notifications_screen.dart';
import '../navigation/main_navigation.dart';
import '../vehicle/add_vehicle_screen.dart';

class HomeScreenContent extends ConsumerWidget {
  const HomeScreenContent({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final activeVehicleAsync = ref.watch(activeVehicleProvider);
    final lastScanAsync = ref.watch(lastScanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ──────────────────────────────────
              profileAsync.when(
                data: (profile) => _buildHeader(
                  context,
                  username: profile?['username'] ?? '',
                ),
                loading: () => _buildHeader(context, username: ''),
                error: (_, __) => _buildHeader(context, username: ''),
              ),
              const SizedBox(height: 20),
              // ── Vehicle Card ─────────────────────────────
              activeVehicleAsync.when(
                data: (vehicle) => vehicle != null
                    ? _buildVehicleCard(vehicle)
                    : _buildNoVehicleCard(context),
                loading: () => _buildVehicleCardSkeleton(),
                error: (_, __) => _buildNoVehicleCard(context),
              ),
              const SizedBox(height: 16),
              // ── Live Stats ───────────────────────────────
              _buildLiveStatsSection(),
              const SizedBox(height: 16),
              // ── Scan Button ──────────────────────────────
              _buildScanButton(context),
              const SizedBox(height: 24),
              // ── Maintenance ──────────────────────────────
              activeVehicleAsync.when(
                data: (vehicle) =>
                    _buildMaintenanceSection(context, hasVehicle: vehicle != null),
                loading: () => _buildMaintenanceSection(context, hasVehicle: false),
                error: (_, __) => _buildMaintenanceSection(context, hasVehicle: false),
              ),
              const SizedBox(height: 24),
              // ── Recent Scans ─────────────────────────────
              lastScanAsync.when(
                data: (scan) => _buildRecentScansSection(context, scan),
                loading: () => _buildRecentScansSection(context, null),
                error: (_, __) => _buildRecentScansSection(context, null),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required String username}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                ),
                children: [
                  TextSpan(text: '${_greeting()}, '),
                  TextSpan(
                    text: username.isNotEmpty ? '$username.' : 'there.',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formattedDate(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => const NotificationsScreen()),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.notifications_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    final make = vehicle['make'] ?? '';
    final model = vehicle['model'] ?? '';
    final year = vehicle['year'] ?? '';
    final engineType = vehicle['engine_type'] ?? '';
    final nickname = vehicle['nickname'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.vehicleCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACTIVE VEHICLE',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text(
            nickname ?? '$make $model',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Inter'),
          ),
          const SizedBox(height: 4),
          Text(
            '$year  •  $engineType',
            style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontFamily: 'Inter'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.advisoryBg,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.advisoryBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle,
                        size: 12, color: AppColors.advisory),
                    SizedBox(width: 4),
                    Text('All clear',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.advisory,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              const Text('No recent scan',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      fontFamily: 'Inter')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleCard(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddVehicleScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 12),
            const Text('No vehicle added yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Inter')),
            const SizedBox(height: 4),
            const Text(
                'Add your vehicle to start scanning\nand get accurate diagnostics',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFBBBBBB),
                    height: 1.5,
                    fontFamily: 'Inter')),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Add Vehicle',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'Inter')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCardSkeleton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
    );
  }

  Widget _buildLiveStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LIVE STATS',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: _StatCard(
                label: 'RPM', value: '--',
                status: 'Not connected',
                statusColor: AppColors.textSecondary)),
            SizedBox(width: 10),
            Expanded(child: _StatCard(
                label: 'COOLANT', value: '--',
                status: 'Not connected',
                statusColor: AppColors.textSecondary)),
            SizedBox(width: 10),
            Expanded(child: _StatCard(
                label: 'BATTERY', value: '--',
                status: 'Not connected',
                statusColor: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Switch to Scan tab (index 1) in MainNavigation
            mainNavKey.currentState?.switchToTab(1);
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('RUN A DIAGNOSTIC SCAN',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                      fontFamily: 'Inter')),
              SizedBox(height: 2),
              Text('Connect OBD adapter and tap to begin',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontFamily: 'Inter')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceSection(BuildContext context,
      {required bool hasVehicle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('MAINTENANCE REMINDERS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                    fontFamily: 'Inter')),
            if (hasVehicle)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const MaintenanceScreen()),
                ),
                child: const Text('See all',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        fontFamily: 'Inter')),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (!hasVehicle)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.build_circle_outlined,
                    color: AppColors.textTertiary, size: 32),
                SizedBox(height: 10),
                Text('No vehicle added yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBBBBBB),
                        fontFamily: 'Inter')),
                SizedBox(height: 4),
                Text(
                    'Add your vehicle to get personalised\nmaintenance reminders',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.5,
                        fontFamily: 'Inter')),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.build_circle_outlined,
                    color: AppColors.textTertiary, size: 32),
                SizedBox(height: 10),
                Text('Maintenance reminders coming soon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFBBBBBB),
                        fontFamily: 'Inter')),
                SizedBox(height: 4),
                Text(
                    'After your first scan, StanDiag will suggest\nmaintenance based on your vehicle and results.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.5,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRecentScansSection(
      BuildContext context, Map<String, dynamic>? lastScan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('RECENT SCANS',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1.5,
                    fontFamily: 'Inter')),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ScanHistoryScreen()),
              ),
              child: const Text('See all',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                      fontFamily: 'Inter')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (lastScan == null)
          _buildNoScansCard()
        else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const ScanHistoryScreen()),
            ),
            child: _buildScanRow(lastScan),
          ),
      ],
    );
  }

  Widget _buildNoScansCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.wifi_tethering_outlined,
              color: AppColors.textTertiary, size: 32),
          SizedBox(height: 10),
          Text('No scans yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFBBBBBB),
                  fontFamily: 'Inter')),
          SizedBox(height: 4),
          Text('Run your first diagnostic scan\nto see results here',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  height: 1.5,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildScanRow(Map<String, dynamic> scan) {
    final codes = scan['dtc_codes'] as List? ?? [];
    final severity = scan['severity'] ?? 'clear';
    final scannedAt = scan['scanned_at'] != null
        ? DateTime.parse(scan['scanned_at'])
        : null;
    final isClean = codes.isEmpty || severity == 'clear';

    Color color;
    Color bg;
    Color border;
    String badge;
    IconData icon;

    if (isClean) {
      color = AppColors.advisory;
      bg = AppColors.advisoryBg;
      border = AppColors.advisoryBorder;
      badge = 'ALL CLEAR';
      icon = Icons.check_circle_outline_rounded;
    } else if (severity == 'critical') {
      color = AppColors.critical;
      bg = AppColors.criticalBg;
      border = AppColors.criticalBorder;
      badge = 'CRITICAL';
      icon = Icons.warning_amber_rounded;
    } else {
      color = AppColors.moderate;
      bg = AppColors.moderateBg;
      border = AppColors.moderateBorder;
      badge = 'MODERATE';
      icon = Icons.bolt_rounded;
    }

    final dateStr = scannedAt != null
        ? '${scannedAt.day} ${_monthName(scannedAt.month)} ${scannedAt.year}'
        : '';
    final codesStr = codes.isNotEmpty
        ? codes.take(3).join(', ')
        : 'All systems normal';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isClean
                      ? 'No faults detected'
                      : '${codes.length} fault code${codes.length > 1 ? 's' : ''} detected',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Inter'),
                ),
                const SizedBox(height: 3),
                Text('$dateStr  •  $codesStr',
                    style: const TextStyle(
                        fontSize: 13,
                        color: const Color(0xFFBBBBBB),
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: border)),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

// ── STAT CARD ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value, status;
  final Color statusColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                  fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(status,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }
}


// ── BACKWARD COMPATIBILITY ────────────────────────────────────
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeScreenContent());
  }
}







