import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FullReportScreen extends StatefulWidget {
  const FullReportScreen({super.key});

  @override
  State<FullReportScreen> createState() => _FullReportScreenState();
}

class _FullReportScreenState extends State<FullReportScreen> {
  final Set<String> _expanded = {'P0301'};

  void _toggle(String code) => setState(() {
    _expanded.contains(code) ? _expanded.remove(code) : _expanded.add(code);
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _subRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _aiSummary(),
                    const SizedBox(height: 16),
                    _dtc('P0301', _Urg.critical, 'Cylinder 1 Misfire Detected',
                      'Fuel in cylinder 1 is not igniting properly. This causes rough idle, power loss and emissions.',
                      ['Faulty spark plug or ignition coil on cylinder 1',
                       'Fuel injector clog or failure',
                       'Low compression — worn piston rings'],
                      ['Workshop req.', 'Engine']),
                    const SizedBox(height: 10),
                    _dtc('P0420', _Urg.moderate, 'Catalyst System Efficiency Low',
                      'The catalytic converter is not processing exhaust gases efficiently.',
                      ['Worn or failing catalytic converter',
                       'O2 sensor fault (upstream or downstream)',
                       'Engine misfire causing converter damage'],
                      ['Exhaust', 'Emissions']),
                    const SizedBox(height: 10),
                    _dtc('P0171', _Urg.advisory, 'Fuel System Running Lean (Bank 1)',
                      'The engine is receiving too much air or not enough fuel on bank 1.',
                      ['Vacuum leak in intake manifold',
                       'Dirty or faulty MAF sensor',
                       'Low fuel pressure — weak fuel pump'],
                      ['Fuel system', 'Intake']),
                    const SizedBox(height: 12),
                    const Text('Tap any code above to expand or collapse full analysis',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11,
                            color: AppColors.textTertiary, fontFamily: 'Inter')),
                    const SizedBox(height: 20),
                    _buttons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Full Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.criticalBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.criticalBorder)),
            child: const Text('⚠ 3 CODES · CRITICAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight, fontFamily: 'Inter',
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _subRow() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Toyota Corolla 2016  •  9 Apr 2026, 09:41',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary,
                fontFamily: 'Inter')),
      ),
    );
  }

  Widget _aiSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.vehicleCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(9)),
                child: const Center(child: Text('🤖',
                    style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              const Text('AI Summary',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary, fontFamily: 'Inter')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryBorder)),
                child: const Text('🤖 GPT-4o',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                        color: AppColors.primary, fontFamily: 'Inter')),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Root cause identified',
              style: TextStyle(fontSize: 11, color: AppColors.advisory,
                  fontFamily: 'Inter')),
          const SizedBox(height: 10),
          const Text(
            'P0301 is likely the root cause. The cylinder 1 misfire may have triggered P0420 and P0171 as secondary effects. Fix P0301 first before other codes.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                height: 1.55, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _dtc(String code, _Urg urg, String title, String body,
      List<String> causes, List<String> chips) {
    final open = _expanded.contains(code);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggle(code),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: urg.border)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: urg.color,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: urg.bg,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(code,
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700, color: urg.color,
                                  fontFamily: 'monospace', letterSpacing: 0.5)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: urg.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: urg.border)),
                          child: Text(urg.label,
                              style: TextStyle(fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: urg.labelColor, letterSpacing: 0.5,
                                  fontFamily: 'Inter')),
                        ),
                        const SizedBox(width: 8),
                        Icon(open
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textTertiary, size: 18),
                      ]),
                      const SizedBox(height: 10),
                      Text(title,
                          style: const TextStyle(fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary, fontFamily: 'Inter')),
                      if (open) ...[
                        const SizedBox(height: 10),
                        Text(body,
                            style: const TextStyle(fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5, fontFamily: 'Inter')),
                        const SizedBox(height: 14),
                        const Text('PROBABLE CAUSES',
                            style: TextStyle(fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary, letterSpacing: 1.5,
                                fontFamily: 'Inter')),
                        const SizedBox(height: 8),
                        ...causes.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${(e.key + 1).toString().padLeft(2, '0')}  ',
                                  style: TextStyle(fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: urg.color, fontFamily: 'monospace')),
                              Expanded(child: Text(e.value,
                                  style: const TextStyle(fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4, fontFamily: 'Inter'))),
                            ],
                          ),
                        )),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: chips.map((c) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppColors.surfaceDeep,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.border)),
                            child: Text(c,
                                style: const TextStyle(fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Inter')),
                          )).toList(),
                        ),
                      ] else ...[
                        const SizedBox(height: 6),
                        Text('Tap to expand full analysis →',
                            style: TextStyle(fontSize: 12,
                                color: urg.color.withValues(alpha: 0.7),
                                fontFamily: 'Inter')),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: const Center(child: Text('Clear All Codes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary, fontFamily: 'Inter'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Center(child: Text('Find Mechanic →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Colors.white, fontFamily: 'Inter'))),
          ),
        ),
      ],
    );
  }
}

enum _Urg { critical, moderate, advisory }

extension _UrgStyle on _Urg {
  Color get color {
    switch (this) {
      case _Urg.critical: return AppColors.critical;
      case _Urg.moderate: return AppColors.moderate;
      case _Urg.advisory: return AppColors.advisory;
    }
  }
  Color get bg {
    switch (this) {
      case _Urg.critical: return AppColors.criticalBg;
      case _Urg.moderate: return AppColors.moderateBg;
      case _Urg.advisory: return AppColors.advisoryBg;
    }
  }
  Color get border {
    switch (this) {
      case _Urg.critical: return AppColors.criticalBorder;
      case _Urg.moderate: return AppColors.moderateBorder;
      case _Urg.advisory: return AppColors.advisoryBorder;
    }
  }
  String get label {
    switch (this) {
      case _Urg.critical: return '⚠ CRITICAL';
      case _Urg.moderate: return 'MODERATE';
      case _Urg.advisory: return 'ADVISORY';
    }
  }
  Color get labelColor {
    switch (this) {
      case _Urg.critical: return AppColors.primaryLight;
      case _Urg.moderate: return AppColors.moderate;
      case _Urg.advisory: return AppColors.advisory;
    }
  }
}


