import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import 'register_step_contact.dart';

class RegisterStepDetails extends StatefulWidget {
  final RegisterState state;
  final void Function(RegisterState) onNext;
  final VoidCallback onBack;

  const RegisterStepDetails({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStepDetails> createState() => _RegisterStepDetailsState();
}

class _RegisterStepDetailsState extends State<RegisterStepDetails> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  String? _gender;
  bool _genderOpen = false;
  bool _dobOpen = false;
  int _dobDay = 15;
  int _dobMonth = 4;
  int _dobYear = 1998;
  bool _dobConfirmed = false;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];




  @override
  void initState() {
    super.initState();
    _firstCtrl.text = widget.state.firstName;
    _lastCtrl.text = widget.state.lastName;
    _gender = widget.state.gender.isEmpty ? null : widget.state.gender;
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  String get _dobDisplay =>
      [_dobDay.toString(), _months[_dobMonth - 1], _dobYear.toString()].join(' ');

  void _next() {
    if (_firstCtrl.text.trim().isEmpty ||
        _lastCtrl.text.trim().isEmpty ||
        _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final updated = widget.state.copyWith(
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      gender: _gender,
    );
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterStepContact(
        state: updated,
        onNext: (s) => widget.onNext(s),
        onBack: () => Navigator.of(context).pop(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _genderOpen = false;
        _dobOpen = false;
      }),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // â”€â”€ Back â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onBack,
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 20),
                // â”€â”€ Step tabs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _StepTabs(currentStep: 1),
                const SizedBox(height: 40),
                // â”€â”€ Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                Text('Let\u2019s get to\nknow you',
                    style: AppTypography.h1.copyWith(
                        fontSize: 28, letterSpacing: -0.6,
                        height: 1.15)),
                const SizedBox(height: 8),
                Text('This is how you\u2019ll appear on your account.',
                    style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary)),
                const SizedBox(height: 28),
                // â”€â”€ First name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _FloatingField(
                  label: 'First Name',
                  hint: 'Enter first name',
                  controller: _firstCtrl,
                  icon: Icons.person_outline_rounded,
                  inputAction: TextInputAction.next,
                ),
                const SizedBox(height: 22),
                // â”€â”€ Last name â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _FloatingField(
                  label: 'Last Name',
                  hint: 'Enter last name',
                  controller: _lastCtrl,
                  icon: Icons.person_outline_rounded,
                  inputAction: TextInputAction.done,
                ),
                const SizedBox(height: 22),
                // â”€â”€ Gender inline dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _InlineDropdown(
                  label: 'Gender',
                  hint: 'Select gender',
                  value: _gender,
                  icon: Icons.person_outline_rounded,
                  open: _genderOpen,
                  options: const ['Male', 'Female', 'Other'],
                  onToggle: () => setState(() {
                    _genderOpen = !_genderOpen;
                    _dobOpen = false;
                  }),
                  onSelect: (v) => setState(() {
                    _gender = v;
                    _genderOpen = false;
                  }),
                ),
                const SizedBox(height: 22),
                // â”€â”€ Date of birth inline picker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _DobInlineField(
                  label: 'Date of Birth',
                  hint: 'Select date of birth',
                  displayValue: _dobOpen ? null : (_dobConfirmed ? _dobDisplay : null),
                  open: _dobOpen,
                  day: _dobDay,
                  month: _dobMonth,
                  year: _dobYear,
                  onToggle: () => setState(() {
                    _dobOpen = !_dobOpen;
                    _genderOpen = false;
                  }),
                  onDayChanged: (v) => setState(() => _dobDay = v + 1),
                  onMonthChanged: (v) => setState(() => _dobMonth = v + 1),
                  onYearChanged: (v) => setState(() => _dobYear = 1950 + v),
                  onConfirm: () => setState(() { _dobOpen = false; _dobConfirmed = true; }),
                ),
                const SizedBox(height: 40),
                // â”€â”€ Next button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€ Floating label text field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputAction inputAction;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.inputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textTertiary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: inputAction,
                style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textDisabled),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ]),
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Inline dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InlineDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final bool open;
  final List<String> options;
  final VoidCallback onToggle;
  final void Function(String) onSelect;

  const _InlineDropdown({
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.open,
    required this.options,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: open
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : AppRadius.lgAll,
                  border: Border.all(
                      color: open
                          ? AppColors.primaryBorder
                          : AppColors.border),
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  Icon(icon, color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ?? hint,
                      style: AppTypography.body.copyWith(
                          color: value != null
                              ? AppColors.textPrimary
                              : AppColors.textDisabled),
                    ),
                  ),
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary, size: 20),
                  const SizedBox(width: 16),
                ]),
              ),
            ),
            if (open)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14)),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Column(
                  children: options.map((o) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(o),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: o != options.last
                            ? const Border(bottom: BorderSide(
                                color: AppColors.borderSubtle))
                            : null,
                      ),
                      child: Text(o,
                          style: AppTypography.body.copyWith(
                              color: value == o
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: value == o
                                  ? FontWeight.w700
                                  : FontWeight.w400)),
                    ),
                  )).toList(),
                ),
              ),
          ],
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Date of birth inline field â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DobInlineField extends StatelessWidget {
  final String label;
  final String hint;
  final String? displayValue;
  final bool open;
  final int day;
  final int month;
  final int year;
  final VoidCallback onToggle;
  final void Function(int) onDayChanged;
  final void Function(int) onMonthChanged;
  final void Function(int) onYearChanged;
  final VoidCallback onConfirm;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];

  const _DobInlineField({
    required this.label,
    required this.hint,
    required this.displayValue,
    required this.open,
    required this.day,
    required this.month,
    required this.year,
    required this.onToggle,
    required this.onDayChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: open
                      ? const BorderRadius.vertical(top: Radius.circular(14))
                      : AppRadius.lgAll,
                  border: Border.all(
                      color: open
                          ? AppColors.primaryBorder
                          : AppColors.border),
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.calendar_month_outlined,
                      color: AppColors.textTertiary, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayValue ?? hint,
                      style: AppTypography.body.copyWith(
                          color: displayValue != null
                              ? AppColors.textPrimary
                              : AppColors.textDisabled),
                    ),
                  ),
                  Icon(
                    open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary, size: 20),
                  const SizedBox(width: 16),
                ]),
              ),
            ),
            if (open)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14)),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _WheelColumn(
                            label: 'Day',
                            items: List.generate(31, (i) => (i + 1).toString()),
                            selectedIndex: day - 1,
                            onChanged: onDayChanged,
                          ),
                        ),
                        Container(width: 1, height: 90,
                            color: AppColors.border),
                        Expanded(
                          child: _WheelColumn(
                            label: 'Month',
                            items: _months,
                            selectedIndex: month - 1,
                            onChanged: onMonthChanged,
                          ),
                        ),
                        Container(width: 1, height: 90,
                            color: AppColors.border),
                        Expanded(
                          child: _WheelColumn(
                            label: 'Year',
                            items: List.generate(80, (i) => (1950 + i).toString()),
                            selectedIndex: year - 1950,
                            onChanged: onYearChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onConfirm,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Center(
                          child: Text('Confirm',
                              style: AppTypography.button.copyWith(
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Positioned(
          top: -9, left: 12,
          child: Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label,
                style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Wheel column â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _WheelColumn extends StatefulWidget {
  final String label;
  final List<String> items;
  final int selectedIndex;
  final void Function(int) onChanged;

  const _WheelColumn({
    required this.label,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late FixedExtentScrollController _ctrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selectedIndex;
    _ctrl = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.label,
            style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                fontSize: 9)),
        const SizedBox(height: 6),
        SizedBox(
          height: 90,
          child: ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: 28,
            perspective: 0.003,
            diameterRatio: 1.4,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              setState(() => _current = i);
              widget.onChanged(i);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, i) {
                final selected = i == _current;
                final near = (i - _current).abs() == 1;
                return Center(
                  child: Text(widget.items[i],
                      style: TextStyle(
                          fontSize: selected ? 19 : near ? 15 : 13,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.textPrimary
                              : near
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                          fontFamily: 'Inter')),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}



