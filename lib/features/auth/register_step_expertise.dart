import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import '../../core/widgets/app_overlay_dropdown.dart';
import '../../core/widgets/app_toast.dart';
import 'register_step_identity.dart';

class RegisterStepExpertise extends StatefulWidget {
  final RegisterState state;
  final void Function(RegisterState) onNext;
  final VoidCallback onBack;

  const RegisterStepExpertise({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStepExpertise> createState() => _RegisterStepExpertiseState();
}

class _RegisterStepExpertiseState extends State<RegisterStepExpertise> {
  static const _allSpecs = [
    'Engine Repair', 'Electrical', 'Diagnostics', 'Transmission',
    'Brakes', 'Suspension', 'Body Work', 'AC / Cooling',
    'Tyres & Wheels', 'Exhaust',
  ];

  late Set<String> _selected;
  int _expYears = 1;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.state.specialisations);
    _expYears = widget.state.experienceYears == 0
        ? 1
        : widget.state.experienceYears;
  }

  void _next() {
    if (_selected.isEmpty) {
      AppToast.error(context, 'Please select at least one specialisation.');
      return;
    }
    final updated = widget.state.copyWith(
      specialisations: _selected.toList(),
      experienceYears: _expYears,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterStepIdentity(
        state: updated,
        onBack: () => Navigator.of(context).pop(),
        onSuccess: () => widget.onNext(updated),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    Future.delayed(const Duration(milliseconds: 100),
                        widget.onBack);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 20),
                _StepTabs(currentStep: 3),
                const SizedBox(height: 40),
                Text('What are you\ngood at?',
                    style: AppTypography.h1.copyWith(
                        fontSize: 28, letterSpacing: -0.6, height: 1.15)),
                const SizedBox(height: 8),
                Text('Select all that apply to your work.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                AppMultiSelectDropdown(
                  label: 'Specialisations',
                  hint: 'Select specialisations',
                  options: _allSpecs,
                  selected: _selected,
                  icon: Icons.build_outlined,
                  onChanged: (v) => setState(() => _selected = v),
                ),
                const SizedBox(height: 22),
                AppSearchDropdown(
                  label: 'Years of Experience',
                  hint: 'Select years of experience',
                  value: _expYears == 0
                      ? null
                      : _expYears.toString() +
                          (_expYears == 1 ? ' year' : ' years'),
                  icon: Icons.access_time_rounded,
                  items: List.generate(
                      50,
                      (i) => (i + 1).toString() +
                          (i == 0 ? ' year' : ' years')),
                  onSelected: (v) => setState(() {
                    _expYears = int.parse(v.split(' ')[0]);
                  }),
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _next,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.lgAll,
                      boxShadow: AppShadows.primaryGlow,
                    ),
                    child: Center(
                      child: Text('NEXT',
                          style: AppTypography.button.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step tabs ─────────────────────────────────────────────────────
class _StepTabs extends StatelessWidget {
  final int currentStep;
  const _StepTabs({required this.currentStep});
  static const _labels = [
    'Getting\nStarted', 'Your\nDetails', 'Contact\nInfo',
    'Your\nExpertise', 'Your\nIdentity',
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentStep;
        final isDone   = i < currentStep;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 24 : 8, height: 8,
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
                          fontSize: 10, height: 1.3)),
                ]),
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