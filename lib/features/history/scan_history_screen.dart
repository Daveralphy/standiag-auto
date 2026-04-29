import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';

class ScanHistoryScreen extends ConsumerStatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  ConsumerState<ScanHistoryScreen> createState() =>
      _ScanHistoryScreenState();
}

class _ScanHistoryScreenState
    extends ConsumerState<ScanHistoryScreen> {
  String _activeFilter = 'All';
  List<Map<String, dynamic>> _scans = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    final scans = await supabase
        .from('scans')
        .select('*, vehicles(make, model, year)')
        .eq('user_id', userId)
        .order('scanned_at', ascending: false);

    final vehicles = await supabase
        .from('vehicles')
        .select('id, make, model, year')
        .eq('user_id', userId);

    if (mounted) {
      setState(() {
        _scans = List<Map<String, dynamic>>.from(scans);
        _vehicles = List<Map<String, dynamic>>.from(vehicles);
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_activeFilter == 'All') return _scans;
    return _scans.where((s) {
      final v = s['vehicles'] as Map?;
      if (v == null) return false;
      final label = '${v['make']} ${v['model']} ${v['year']}';
      return label.contains(_activeFilter);
    }).toList();
  }

  List<String> get _filters {
    final labels = _vehicles
        .map((v) => '${v['make']} ${v['model']}')
        .toSet()
        .toList();
    return ['All', ...labels];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (_vehicles.isNotEmpty) _buildFilterChips(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppSecondaryHeader(
      title: 'Scan History',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filters[i] == _activeFilter;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                setState(() => _activeFilter = _filters[i]),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border),
              ),
              child: Text(_filters[i],
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_tethering_outlined,
              color: AppColors.textTertiary, size: 48),
          SizedBox(height: 16),
          Text('No scans yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          SizedBox(height: 6),
          Text('Your scan history will appear here.',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildList() {
    // Group by month
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final scan in _filtered) {
      final dt = DateTime.parse(scan['scanned_at']).toLocal();
      final key =
          '${_monthName(dt.month).toUpperCase()} ${dt.year}';
      grouped.putIfAbsent(key, () => []).add(scan);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: grouped.entries.expand((entry) {
        return [
          Text(entry.key,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 10),
          ...entry.value.map((scan) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ScanRow(scan: scan),
              )),
          const SizedBox(height: 8),
        ];
      }).toList(),
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May',
      'June', 'July', 'August', 'September', 'October',
      'November', 'December'
    ];
    return months[m];
  }
}

class _ScanRow extends StatelessWidget {
  final Map<String, dynamic> scan;
  const _ScanRow({required this.scan});

  @override
  Widget build(BuildContext context) {
    final codes = (scan['dtc_codes'] as List?) ?? [];
    final severity = scan['severity'] ?? 'clear';
    final isClean = codes.isEmpty || severity == 'clear';
    final isCritical = severity == 'critical';
    final vehicle = scan['vehicles'] as Map?;
    final vehicleName = vehicle != null
        ? '${vehicle['make']} ${vehicle['model']} ${vehicle['year']}'
        : 'Unknown vehicle';
    final dt = DateTime.parse(scan['scanned_at']).toLocal();
    final dateStr =
        '${dt.day} ${_month(dt.month)} ${dt.year}, ${_time(dt)}';

    final color = isClean
        ? AppColors.advisory
        : isCritical
            ? AppColors.critical
            : AppColors.moderate;
    final bg = isClean
        ? AppColors.advisoryBg
        : isCritical
            ? AppColors.criticalBg
            : AppColors.moderateBg;
    final border = isClean
        ? AppColors.advisoryBorder
        : isCritical
            ? AppColors.criticalBorder
            : AppColors.moderateBorder;
    final icon = isClean
        ? Icons.check_circle_outline_rounded
        : isCritical
            ? Icons.warning_amber_rounded
            : Icons.bolt_rounded;
    final badge = isClean
        ? 'ALL CLEAR'
        : isCritical
            ? 'CRITICAL'
            : 'MODERATE';
    final badgeColor = isCritical ? AppColors.primaryLight : color;

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
              width: 3, height: 48,
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
                const SizedBox(height: 2),
                Text(
                  codes.isNotEmpty
                      ? codes.take(3).join('  ')
                      : 'All systems normal',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontFamily: 'Inter'),
                ),
                const SizedBox(height: 2),
                Text('$vehicleName  •  $dateStr',
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: border)),
            child: Text(badge,
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    letterSpacing: 0.3,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}


