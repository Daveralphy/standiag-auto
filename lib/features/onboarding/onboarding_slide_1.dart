import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';

class OnboardingSlide1 extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingSlide1({
    super.key,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // ── Progress dots + Skip ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _ProgressDot(active: currentPage == 0),
                  const SizedBox(width: 5),
                  _ProgressDot(active: currentPage == 1),
                  const SizedBox(width: 5),
                  _ProgressDot(active: currentPage == 2),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onSkip,
                    child: Text('Skip',
                        style: AppTypography.body.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Scan card illustration ─────────────────────
            Expanded(
              flex: 58,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _ScanCard(),
              ),
            ),
            // ── Bottom section ─────────────────────────────
            Expanded(
              flex: 42,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                        children: [
                          TextSpan(text: 'Diagnose your\ncar '),
                          TextSpan(
                            text: 'instantly',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Connect via Bluetooth to your OBD-II adapter.\nRead fault codes and live sensor data in seconds.',
                      style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary, height: 1.55),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.lgAll,
                          boxShadow: AppShadows.primaryGlow,
                        ),
                        child: Center(
                          child: Text('NEXT',
                              style: AppTypography.button.copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
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

// ── Progress dot ──────────────────────────────────────────────────
class _ProgressDot extends StatelessWidget {
  final bool active;
  const _ProgressDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: active ? AppRadius.smAll : AppRadius.fullAll,
      ),
    );
  }
}

// ── OBD Scan card ─────────────────────────────────────────────────
class _ScanCard extends StatelessWidget {
  const _ScanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBD SCAN',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                          fontSize: 12)),
                  Text('Vehicle Diagnostic',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Fault rows
          const _FaultRow(
            code: 'P0301',
            name: 'Cylinder 1 Misfire',
            detail: 'Fuel is not burning fully',
            color: AppColors.critical,
          ),
          const _FaultRow(
            code: 'P0171',
            name: 'Catalytic Efficiency Low',
            detail: 'System Too Lean Bank 1',
            color: AppColors.moderate,
          ),
          const _FaultRow(
            code: 'P0711',
            name: 'Torque The Local 01',
            detail: 'Fluid Temperature Sensor',
            color: AppColors.moderate,
          ),
          const _FaultRow(
            code: 'B1234',
            name: 'Battery Voltage Low',
            detail: 'Check Alternator Output',
            color: AppColors.advisory,
            last: true,
          ),
          const SizedBox(height: 12),
          // Stats row
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.advisory,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text('4 FAULTS FOUND',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.advisory,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3)),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [8.0, 14.0, 18.0, 11.0, 16.0, 9.0, 13.0].map((h) =>
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Container(
                        width: 5, height: h,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.75),
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Bluetooth row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bluetooth.withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: const Icon(Icons.bluetooth_rounded,
                      color: AppColors.bluetooth, size: 14),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ELM327 Adapter',
                          style: AppTypography.label.copyWith(
                              color: AppColors.textPrimary, fontSize: 12)),
                      Text('Plug into OBD-II port',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.advisory,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text('Connected',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.advisory,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fault row ─────────────────────────────────────────────────────
class _FaultRow extends StatelessWidget {
  final String code;
  final String name;
  final String detail;
  final Color color;
  final bool last;

  const _FaultRow({
    required this.code,
    required this.name,
    required this.detail,
    required this.color,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(code,
                style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    letterSpacing: 0.3)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
                Text(detail,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

