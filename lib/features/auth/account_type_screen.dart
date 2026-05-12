import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import 'account_type_info_screen.dart';
import '../../core/models/register_state.dart';
import 'register_step_details.dart';


class AccountTypeScreen extends StatefulWidget {
  final void Function(String accountType)? onNext;
  const AccountTypeScreen({super.key, this.onNext});
  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  String? _selected;

  void _select(String type) => setState(() => _selected = type);

  void _next() {
    if (_selected == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterStepDetails(
        state: RegisterState(accountType: _selected!),
        onNext: (_) {},
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  void _openInfo() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const AccountTypeInfoScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Back arrow top left â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 20),
              // â”€â”€ Step tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _StepTabs(currentStep: 0),
              const SizedBox(height: 40),
              // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Center(
                child: Text('Choose account type',
                    textAlign: TextAlign.center,
                    style: AppTypography.h1.copyWith(
                        fontSize: 26, letterSpacing: -0.5)),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text('How do you want to use StanDiag?',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 40),
              // â”€â”€ Option cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _OptionCard(
                emoji: '\u{1F697}',
                title: 'Car Owner',
                subtitle: 'Diagnose your vehicle and find mechanics',
                tag: 'Owner',
                selected: _selected == 'car_owner',
                onTap: () => _select('car_owner'),
              ),
              const SizedBox(height: 14),
              _OptionCard(
                emoji: '\u{1F527}',
                title: 'Mechanic',
                subtitle: 'Offer your services and grow your business',
                tag: 'Mechanic',
                selected: _selected == 'mechanic',
                onTap: () => _select('mechanic'),
              ),
              const Spacer(),
              // â”€â”€ Help link â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openInfo,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('?',
                          style: AppTypography.body.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                      const SizedBox(width: 6),
                      Text('What\u2019s the difference?',
                          style: AppTypography.bodySm.copyWith(
                              color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // â”€â”€ Next button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _selected != null ? _next : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _selected != null
                        ? AppColors.primaryGradient
                        : const LinearGradient(
                            colors: [Color(0xFF2A2A32), Color(0xFF2A2A32)]),
                    borderRadius: AppRadius.lgAll,
                    boxShadow: _selected != null
                        ? AppShadows.primaryGlow
                        : null,
                  ),
                  child: Center(
                    child: Text('Next',
                        style: AppTypography.button.copyWith(
                            color: _selected != null
                                ? Colors.white
                                : AppColors.textTertiary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Step tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});

  static const _labels = [
    'Getting\nStarted',
    'Your\nDetails',
    'Contact\nInfo',
    'Vehicle /\nExpertise',
    'Your\nIdentity',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : isDone
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : AppColors.border,
                        borderRadius: isActive
                            ? AppRadius.smAll
                            : AppRadius.fullAll,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_labels[i],
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 10,
                            height: 1.3)),
                  ],
                ),
              ),
              if (i < _labels.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 8, height: 2,
                    color: isDone
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// â”€â”€ Option card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _OptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String tag;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceCard,
                borderRadius: AppRadius.mdAll,
              ),
              child: Center(
                child: Text(emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.h4.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: AppTypography.bodySm.copyWith(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(tag,
                style: AppTypography.bodySm.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}




