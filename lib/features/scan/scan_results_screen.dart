import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'full_report_screen.dart';

class ScanResultsScreen extends StatelessWidget {
  const ScanResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSubRow(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildFaultCount(),
                    const SizedBox(height: 16),
                    const _DTCCard(
                      code: 'P0301', urgency: DTCUrgency.critical,
                      title: 'Cylinder 1 Misfire Detected',
                      chips: ['Faulty spark plug', 'Ignition coil failure'],
                    ),
                    const SizedBox(height: 10),
                    const _DTCCard(
                      code: 'P0420', urgency: DTCUrgency.moderate,
                      title: 'Catalyst System Efficiency Low',
                      chips: ['Worn catalytic converter', 'O2 sensor fault'],
                    ),
                    const SizedBox(height: 10),
                    const _DTCCard(
                      code: 'P0171', urgency: DTCUrgency.advisory,
                      title: 'Fuel System Running Lean (Bank 1)',
                      chips: ['Vacuum leak', 'MAF sensor dirt', 'Low fuel pressure'],
                    ),
                    const SizedBox(height: 16),
                    _buildAISummary(context),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Diagnostic Scan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.criticalBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.criticalBorder),
            ),
            child: const Text('⚠ 3 CODES · CRITICAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight, fontFamily: 'Inter',
                    letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          const Text('Toyota Corolla 2016  •  Scan complete',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary,
                  fontFamily: 'Inter')),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.advisoryBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.advisoryBorder),
            ),
            child: const Text('ELM327 · Active',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: AppColors.advisory, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultCount() {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: AppColors.criticalBg, shape: BoxShape.circle,
              border: Border.all(color: AppColors.criticalBorder)),
          child: const Center(
            child: Text('!', style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w900, color: AppColors.primary,
                fontFamily: 'Inter')),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('3 fault codes detected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, fontFamily: 'Inter')),
            SizedBox(height: 2),
            Text('Scanned on 11 April 2026 at 09:41 AM',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary,
                    fontFamily: 'Inter')),
          ],
        ),
      ],
    );
  }

  Widget _buildAISummary(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FullReportScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.vehicleCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('🤖',
                  style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🤖 AI Summary',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary, fontFamily: 'Inter')),
                  SizedBox(height: 3),
                  Text('P0301 is the likely root cause. Address this first.',
                      style: TextStyle(fontSize: 12,
                          color: AppColors.textSecondary, fontFamily: 'Inter')),
                ],
              ),
            ),
            const Text('Full report →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: AppColors.primary, fontFamily: 'Inter')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: const Center(
              child: Text('Clear Codes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary, fontFamily: 'Inter')),
            ),
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
                  color: AppColors.primary.withOpacity(0.38),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Center(
              child: Text('Find a Mechanic →',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Inter')),
            ),
          ),
        ),
      ],
    );
  }
}

enum DTCUrgency { critical, moderate, advisory }

extension DTCUrgencyStyle on DTCUrgency {
  Color get color {
    switch (this) {
      case DTCUrgency.critical: return AppColors.critical;
      case DTCUrgency.moderate: return AppColors.moderate;
      case DTCUrgency.advisory: return AppColors.advisory;
    }
  }
  Color get bg {
    switch (this) {
      case DTCUrgency.critical: return AppColors.criticalBg;
      case DTCUrgency.moderate: return AppColors.moderateBg;
      case DTCUrgency.advisory: return AppColors.advisoryBg;
    }
  }
  Color get borderColor {
    switch (this) {
      case DTCUrgency.critical: return AppColors.criticalBorder;
      case DTCUrgency.moderate: return AppColors.moderateBorder;
      case DTCUrgency.advisory: return AppColors.advisoryBorder;
    }
  }
  String get label {
    switch (this) {
      case DTCUrgency.critical: return '⚠ CRITICAL';
      case DTCUrgency.moderate: return 'MODERATE';
      case DTCUrgency.advisory: return 'ADVISORY';
    }
  }
  Color get labelColor {
    switch (this) {
      case DTCUrgency.critical: return AppColors.primaryLight;
      case DTCUrgency.moderate: return AppColors.moderate;
      case DTCUrgency.advisory: return AppColors.advisory;
    }
  }
}

class _DTCCard extends StatelessWidget {
  final String code;
  final DTCUrgency urgency;
  final String title;
  final List<String> chips;

  const _DTCCard({required this.code, required this.urgency,
      required this.title, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: urgency.borderColor)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: urgency.color,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: urgency.bg,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(code,
                              style: TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: urgency.color, fontFamily: 'monospace',
                                  letterSpacing: 0.5)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: urgency.bg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: urgency.borderColor)),
                          child: Text(urgency.label,
                              style: TextStyle(fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: urgency.labelColor, letterSpacing: 0.5,
                                  fontFamily: 'Inter')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(title,
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: chips.map((chip) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceDeep,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.border)),
                        child: Text(chip,
                            style: const TextStyle(fontSize: 11,
                                color: AppColors.textSecondary,
                                fontFamily: 'Inter')),
                      )).toList(),
                    ),
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
