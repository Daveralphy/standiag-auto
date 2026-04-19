import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  String _activeFilter = 'All';

  final _filters = ['All', 'Corolla 2016', 'Civic 2019'];

  final _scans = [
    _ScanItem(month: 'APRIL 2026', icon: _ScanIcon.critical,
        title: '3 fault codes detected', codes: 'P0301  P0420  P0171',
        vehicle: 'Corolla 2016', date: '9 Apr 2026, 09:41', badge: 'CRITICAL'),
    _ScanItem(month: '', icon: _ScanIcon.clear,
        title: 'No faults detected', codes: 'All systems normal  •  0 codes',
        vehicle: 'Civic 2019', date: '5 Apr 2026, 14:22', badge: 'ALL CLEAR'),
    _ScanItem(month: '', icon: _ScanIcon.moderate,
        title: '1 fault code detected', codes: 'P0128  Coolant below threshold',
        vehicle: 'Corolla 2016', date: '2 Apr 2026, 08:10', badge: 'MODERATE'),
    _ScanItem(month: 'MARCH 2026', icon: _ScanIcon.clear,
        title: 'No faults detected', codes: 'All systems normal  •  0 codes',
        vehicle: 'Corolla 2016', date: '22 Mar 2026, 11:05', badge: 'ALL CLEAR'),
    _ScanItem(month: '', icon: _ScanIcon.critical,
        title: '2 fault codes detected', codes: 'P0301  P0455',
        vehicle: 'Civic 2019', date: '8 Mar 2026, 16:47', badge: 'CRITICAL'),
    _ScanItem(month: '', icon: _ScanIcon.moderate,
        title: '1 fault code detected', codes: 'P0128  Coolant below threshold',
        vehicle: 'Corolla 2016', date: '6 Mar 2026, 08:10', badge: 'MODERATE'),
    _ScanItem(month: '', icon: _ScanIcon.clear,
        title: 'No faults detected', codes: 'All systems normal  •  0 codes',
        vehicle: 'Corolla 2016', date: '2 Mar 2026, 11:05', badge: 'ALL CLEAR'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildFilterChips(),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Scan History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
        ],
      ),
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
            onTap: () => setState(() => _activeFilter = _filters[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Text(_filters[i],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontFamily: 'Inter')),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: _scans.length + 1, // +1 for load more
      itemBuilder: (context, i) {
        if (i == _scans.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text('Load 9 more scans ↓',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.primary, fontFamily: 'Inter')),
            ),
          );
        }
        final scan = _scans[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scan.month.isNotEmpty) ...[
              if (i > 0) const SizedBox(height: 16),
              Text(scan.month,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary, letterSpacing: 1.5,
                      fontFamily: 'Inter')),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 8),
            _ScanRow(scan: scan),
          ],
        );
      },
    );
  }
}

enum _ScanIcon { critical, moderate, clear }

class _ScanItem {
  final String month, title, codes, vehicle, date, badge;
  final _ScanIcon icon;
  const _ScanItem({required this.month, required this.icon, required this.title,
      required this.codes, required this.vehicle, required this.date,
      required this.badge});
}

class _ScanRow extends StatelessWidget {
  final _ScanItem scan;
  const _ScanRow({required this.scan});

  Color get _color {
    switch (scan.icon) {
      case _ScanIcon.critical: return AppColors.critical;
      case _ScanIcon.moderate: return AppColors.moderate;
      case _ScanIcon.clear: return AppColors.advisory;
    }
  }

  Color get _bg {
    switch (scan.icon) {
      case _ScanIcon.critical: return AppColors.criticalBg;
      case _ScanIcon.moderate: return AppColors.moderateBg;
      case _ScanIcon.clear: return AppColors.advisoryBg;
    }
  }

  Color get _border {
    switch (scan.icon) {
      case _ScanIcon.critical: return AppColors.criticalBorder;
      case _ScanIcon.moderate: return AppColors.moderateBorder;
      case _ScanIcon.clear: return AppColors.advisoryBorder;
    }
  }

  String get _badgeLabel => scan.badge;

  Color get _badgeTextColor {
    switch (scan.icon) {
      case _ScanIcon.critical: return AppColors.primaryLight;
      case _ScanIcon.moderate: return AppColors.moderate;
      case _ScanIcon.clear: return AppColors.advisory;
    }
  }

  IconData get _iconData {
    switch (scan.icon) {
      case _ScanIcon.critical: return Icons.warning_amber_rounded;
      case _ScanIcon.moderate: return Icons.bolt_rounded;
      case _ScanIcon.clear: return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 3, height: 48,
            decoration: BoxDecoration(
                color: _color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: _bg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(_iconData, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scan.title,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text(scan.codes,
                    style: const TextStyle(fontSize: 11,
                        color: AppColors.textSecondary, fontFamily: 'Inter')),
                const SizedBox(height: 2),
                Text('${scan.vehicle}  •  ${scan.date}',
                    style: const TextStyle(fontSize: 10,
                        color: AppColors.textTertiary, fontFamily: 'Inter')),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
                color: _bg, borderRadius: BorderRadius.circular(7),
                border: Border.all(color: _border)),
            child: Text(_badgeLabel,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                    color: _badgeTextColor, letterSpacing: 0.3,
                    fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}
