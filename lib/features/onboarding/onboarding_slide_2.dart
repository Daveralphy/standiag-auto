import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';

class OnboardingSlide2 extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingSlide2({
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
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _ProgressDot(state: _DotState.done),
                  const SizedBox(width: 5),
                  _ProgressDot(state: _DotState.active),
                  const SizedBox(width: 5),
                  _ProgressDot(state: _DotState.inactive),
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
            const SizedBox(height: 10),
            Expanded(
              flex: 58,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const _AiCard(),
              ),
            ),
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
                          TextSpan(text: 'Understand\nevery '),
                          TextSpan(
                            text: 'fault',
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
                      'AI turns raw codes into plain language.\nKnow the cause, urgency, and what to do.',
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

enum _DotState { active, done, inactive }

class _ProgressDot extends StatelessWidget {
  final _DotState state;
  const _ProgressDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final isActive = state == _DotState.active;
    final isDone = state == _DotState.done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : isDone
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border,
        borderRadius: isActive ? AppRadius.smAll : AppRadius.fullAll,
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.lg,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI ANALYSIS',
                      style: AppTypography.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8, fontSize: 11)),
                  Text('Powered by GPT-4o',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.advisoryBg,
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(color: AppColors.advisoryBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                          color: AppColors.advisory,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text('LIVE',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.advisory,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('P0301',
              style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900,
                color: AppColors.textPrimary, fontFamily: 'Inter',
                letterSpacing: -1, height: 1,
              )),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.criticalBg,
              borderRadius: AppRadius.fullAll,
              border: Border.all(color: AppColors.criticalBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text('CRITICAL',
                    style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your engine\u2019s cylinder 1 is misfiring. Fuel is not burning fully, causing rough idle, power loss, and high emissions.',
            style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary, height: 1.55),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: ['Engine', 'Workhorse', 'Ignition'].map((t) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(t, style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
              ),
            ).toList(),
          ),
          const SizedBox(height: 10),
          Text('PROBABLE CAUSES',
              style: AppTypography.labelSm.copyWith(
                  color: AppColors.textTertiary, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          ...[
            'Faulty spark plug or ignition coil',
            'Fuel injector clog or failure',
            'Low compression \u2014 worn valve seats',
          ].asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0',
                    style: AppTypography.label.copyWith(
                        color: AppColors.primary,
                        fontSize: 11, fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(e.value,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary, height: 1.4)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 10),
          Text('URGENCY ASSESSMENT',
              style: AppTypography.labelSm.copyWith(
                  color: AppColors.textTertiary, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          _UrgencyBar(label: 'Critical', percent: 0.45, color: AppColors.critical),
          const SizedBox(height: 7),
          _UrgencyBar(label: 'Moderate', percent: 0.32, color: AppColors.moderate),
          const SizedBox(height: 7),
          _UrgencyBar(label: 'Advisory', percent: 0.19, color: AppColors.advisory),
        ],
      ),
    );
  }
}

class _UrgencyBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _UrgencyBar({required this.label, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary, fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: Container(
              height: 6,
              color: AppColors.surface,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent,
                child: Container(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text('%',
              textAlign: TextAlign.right,
              style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary)),
        ),
      ],
    );
  }
}

