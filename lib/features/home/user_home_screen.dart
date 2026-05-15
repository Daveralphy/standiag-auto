import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/vehicle_model.dart';
import '../../core/models/mechanic_model.dart';
import '../../core/models/scan_model.dart';
import '../../core/services/home_service.dart';
import '../../core/widgets/app_toast.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _service = HomeService();
  final _supabase = Supabase.instance.client;

  String _firstName = '';
  VehicleModel? _vehicle;
  Map<String, dynamic> _vehicleStats = {};
  List<MechanicModel> _nearbyMechanics = [];
  List<ScanModel> _recentScans = [];
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final uid = _supabase.auth.currentUser!.id;
      final profile = await _supabase
          .from('profiles')
          .select('first_name')
          .eq('id', uid)
          .single();

      final vehicle = await _service.getActiveVehicle();
      Map<String, dynamic> stats = {};
      if (vehicle != null) {
        stats = await _service.getVehicleStats(vehicle.id);
      }
      final scans = await _service.getRecentScans();

      List<MechanicModel> mechanics = [];
      try {
        final pos = await Geolocator.getCurrentPosition();
        mechanics = await _service.getNearbyMechanics(
          userLat: pos.latitude, userLng: pos.longitude);
      } catch (_) {
        mechanics = await _service.getNearbyMechanics(
          userLat: 6.5244, userLng: 3.3792);
      }

      final notifs = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);

      if (!mounted) return;
      setState(() {
        _firstName = profile['first_name'] as String? ?? '';
        _vehicle = vehicle;
        _vehicleStats = stats;
        _recentScans = scans;
        _nearbyMechanics = mechanics;
        _unreadCount = notifs.length;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, 'Failed to load home data.');
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 6) return '${(d.inDays / 7).floor()}w ago';
    if (d.inDays > 0) return '${d.inDays}d ago';
    if (d.inHours > 0) return '${d.inHours}h ago';
    return '${d.inMinutes}m ago';
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildVehicleCard(),
                      _buildNearbyMechanics(),
                      _buildScanButton(),
                      _buildRecentScans(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting(),
              style: AppTypography.caption
                  .copyWith(color: AppColors.textTertiary)),
          Text('$_firstName ðŸ‘‹',
              style: AppTypography.h2.copyWith(letterSpacing: -0.5)),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(children: [
              const Center(child: Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary, size: 22)),
              if (_unreadCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.background, width: 1.5)),
                  ),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildVehicleCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Active Vehicle'),
        const SizedBox(height: 10),
        _vehicle == null ? _noVehicle() : _vehicleContent(),
      ]),
    );
  }

  Widget _noVehicle() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: [
      const Icon(Icons.directions_car_outlined,
          color: AppColors.textTertiary, size: 40),
      const SizedBox(height: 8),
      Text('No active vehicle',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text('Add a vehicle from your profile',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
    ]),
  );

  Widget _vehicleContent() {
    final v = _vehicle!;
    final faults = _vehicleStats['fault_codes'] as int? ?? 0;
    final total = _vehicleStats['total_scans'] as int? ?? 0;
    final lastScan = _vehicleStats['last_scan'] as DateTime?;
    final severity = _vehicleStats['severity'] as String? ?? 'clear';
    final condColor = severity == 'clear'
        ? AppColors.success
        : severity == 'warning'
            ? AppColors.warning
            : AppColors.primary;
    final condText = severity == 'clear'
        ? 'Good Condition'
        : severity == 'warning'
            ? 'Needs Attention'
            : 'Critical';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A0608), Color(0xFF0D0D10)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadius.smAll,
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Text('Car Owner',
                style: AppTypography.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: condColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Row(children: [
              Container(width: 6, height: 6,
                  decoration: BoxDecoration(
                      color: condColor, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(condText, style: AppTypography.caption.copyWith(
                  color: condColor, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Text(v.displayName,
            style: AppTypography.h2.copyWith(letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text('${v.year} Â· ${v.engineType}',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        const Divider(height: 28, color: Colors.white10, thickness: 0.5),
        Row(children: [
          _vStat(faults.toString(), 'Fault Codes'),
          const SizedBox(width: 20),
          _vStat(total.toString(), 'Total Scans'),
          const SizedBox(width: 20),
          _vStat(lastScan != null ? _timeAgo(lastScan) : 'Never', 'Last Scan'),
        ]),
      ]),
    );
  }

  Widget _vStat(String val, String lbl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
          Text(lbl, style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
        ],
      );

  Widget _buildNearbyMechanics() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: _sectionTitle('Nearby Mechanics'),
      ),
      if (_nearbyMechanics.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.border)),
            child: Center(child: Text('No mechanics nearby',
                style: AppTypography.body.copyWith(color: AppColors.textTertiary))),
          ),
        )
      else
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _nearbyMechanics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _MechanicCard(mechanic: _nearbyMechanics[i]),
          ),
        ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildScanButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // TODO: navigate to scan screen
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppRadius.lgAll,
            boxShadow: AppShadows.primaryGlow,
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Run Diagnostics',
                    style: AppTypography.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Connect OBD-II to scan your car',
                    style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.75))),
              ],
            )),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 22),
          ]),
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Recent Scans'),
        const SizedBox(height: 10),
        if (_recentScans.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.border)),
            child: Center(child: Column(children: [
              const Icon(Icons.qr_code_scanner_outlined,
                  color: AppColors.textTertiary, size: 36),
              const SizedBox(height: 8),
              Text('No scans yet', style: AppTypography.body
                  .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Connect your OBD-II to run a scan',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textTertiary)),
            ])),
          )
        else
          ...(_recentScans.map((s) =>
              _ScanItem(scan: s, timeAgo: _timeAgo(s.scannedAt)))),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1));
}

class _MechanicCard extends StatelessWidget {
  final MechanicModel mechanic;
  const _MechanicCard({required this.mechanic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard, borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.border)),
          child: mechanic.avatarUrl != null
              ? ClipRRect(borderRadius: AppRadius.mdAll,
                  child: Image.network(mechanic.avatarUrl!, fit: BoxFit.cover))
              : const Icon(Icons.person_outline_rounded,
                  color: AppColors.textTertiary, size: 24),
        ),
        const SizedBox(height: 10),
        Text(mechanic.fullName,
            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(mechanic.specsPreview,
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const Spacer(),
        Row(children: [
          Text('â­ ${mechanic.rating.toStringAsFixed(1)}',
              style: AppTypography.caption.copyWith(
                  color: AppColors.warning, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (mechanic.distanceKm != null)
            Text(
                mechanic.distanceKm! < 1
                    ? '${(mechanic.distanceKm! * 1000).round()}m'
                    : '${mechanic.distanceKm!.toStringAsFixed(1)}km',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary)),
        ]),
      ]),
    );
  }
}

class _ScanItem extends StatelessWidget {
  final ScanModel scan;
  final String timeAgo;
  const _ScanItem({required this.scan, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    final color = scan.isClear
        ? AppColors.success
        : scan.isWarning ? AppColors.warning : AppColors.primary;
    final label = scan.isClear ? 'Clear' : scan.isWarning ? 'Warning' : 'Critical';
    final title = scan.dtcCodes.isNotEmpty
        ? scan.dtcCodes.first : 'Full System Check';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard, borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border)),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll),
          child: Icon(
            scan.isClear ? Icons.check_circle_outline_rounded
                : Icons.warning_amber_rounded,
            color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(timeAgo, style: AppTypography.caption
              .copyWith(color: AppColors.textTertiary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll),
          child: Text(label, style: AppTypography.caption
              .copyWith(color: color, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}
