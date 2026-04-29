import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';

class ScanNoFaultsScreen extends StatefulWidget {
  const ScanNoFaultsScreen({super.key});

  @override
  State<ScanNoFaultsScreen> createState() => _ScanNoFaultsScreenState();
}

class _ScanNoFaultsScreenState extends State<ScanNoFaultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700))..forward();
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
                  children: [
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: SizedBox(
                          width: 160, height: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(width: 160, height: 160,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.advisory.withValues(alpha: 0.10), width: 1))),
                              Container(width: 128, height: 128,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.advisory.withValues(alpha: 0.16), width: 1))),
                              Container(width: 98, height: 98,
                                  decoration: BoxDecoration(shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.advisory.withValues(alpha: 0.24), width: 1.5))),
                              Container(
                                width: 72, height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.advisory.withValues(alpha: 0.12),
                                  border: Border.all(color: AppColors.advisory, width: 2),
                                  boxShadow: [BoxShadow(
                                      color: AppColors.advisory.withValues(alpha: 0.30),
                                      blurRadius: 20)],
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: AppColors.advisory, size: 34),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('No faults detected.',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary, fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    const Text(
                      "Your vehicle's systems are all reading\nwithin normal parameters. Good to go.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary,
                          height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 10),
                    const Text('11 April 2026  •  09:41 AM  •  ELM327  •  0 codes',
                        style: TextStyle(fontSize: 11, color: AppColors.textTertiary,
                            fontFamily: 'Inter')),
                    const SizedBox(height: 28),
                    _buildLiveData(),
                    const SizedBox(height: 24),
                    _buildButtons(context),
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
    return AppSecondaryHeader(
      title: 'Diagnostic Scan',
      onBack: () => Navigator.of(context).pop(),
      action: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.advisoryBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.advisoryBorder),
        ),
        child: const Text('Scan complete',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.advisory, fontFamily: 'Inter')),
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

  Widget _buildLiveData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('LIVE DATA SNAPSHOT',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _LiveCard(label: 'RPM', value: '820',
                status: 'Idle', sub: 'Normal', color: AppColors.textSecondary)),
            const SizedBox(width: 10),
            Expanded(child: _LiveCard(label: 'COOLANT', value: '88°C',
                status: 'Normal', sub: '', color: AppColors.advisory)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _LiveCard(label: 'FUEL SYS', value: 'CL-OL',
                status: 'Closed loop', sub: 'Low Normal', color: AppColors.advisory)),
            const SizedBox(width: 10),
            Expanded(child: _LiveCard(label: 'ENGINE LOAD', value: '23%',
                status: 'Low Normal', sub: '', color: AppColors.advisory)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _LiveCard(label: 'BATTERY', value: '13.8V',
                status: 'Good', sub: '', color: AppColors.advisory)),
            const SizedBox(width: 10),
            Expanded(child: _LiveCard(label: 'THROTTLE', value: '15%',
                status: 'Normal', sub: '', color: AppColors.advisory)),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.advisoryBorder)),
            child: const Center(child: Text('Save Report',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: AppColors.advisory, fontFamily: 'Inter'))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.38),
                    blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Center(child: Text('Scan Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, fontFamily: 'Inter'))),
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  final String label, value, status, sub;
  final Color color;
  const _LiveCard({required this.label, required this.value,
      required this.status, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
              color: AppColors.textSecondary, letterSpacing: 0.8, fontFamily: 'Inter')),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
              color: color, fontFamily: 'Inter')),
          if (sub.isNotEmpty)
            Text(sub, style: const TextStyle(fontSize: 10,
                color: AppColors.textTertiary, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}


