import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../../core/theme/design_system.dart';
import '../../core/models/register_state.dart';
import '../../core/widgets/app_overlay_dropdown.dart';
import '../../core/widgets/app_toast.dart';
import 'register_step_identity.dart';

class RegisterStepVehicle extends StatefulWidget {
  final RegisterState state;
  final void Function(RegisterState) onNext;
  final VoidCallback onBack;

  const RegisterStepVehicle({
    super.key,
    required this.state,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<RegisterStepVehicle> createState() => _RegisterStepVehicleState();
}

class _RegisterStepVehicleState extends State<RegisterStepVehicle> {
  final _nicknameCtrl = TextEditingController();

  List<String> _makes = [];
  List<String> _models = [];
  final List<String> _years =
      List.generate(30, (i) => (DateTime.now().year - i).toString());
  final List<String> _engineTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];

  String? _make;
  String? _model;
  String? _year;
  String? _engineType;
  bool _makesLoading = false;
  bool _modelsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMakes();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMakes() async {
    setState(() => _makesLoading = true);
    try {
      final response = await http.get(Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetAllMakes?format=json'));
      final data = json.decode(response.body);
      final results = (data['Results'] as List)
          .map((e) => e['Make_Name'].toString())
          .toList();
      results.sort();
      if (mounted) setState(() => _makes = results);
    } catch (_) {
      if (mounted) {
        setState(() => _makes = [
              'Toyota', 'Honda', 'Ford', 'Mercedes-Benz', 'BMW',
              'Hyundai', 'Kia', 'Nissan', 'Volkswagen', 'Chevrolet',
            ]);
      }
    } finally {
      if (mounted) setState(() => _makesLoading = false);
    }
  }

  Future<void> _loadModels(String make) async {
    setState(() {
      _modelsLoading = true;
      _models = [];
      _model = null;
    });
    try {
      final makeEncoded = Uri.encodeComponent(make);
      final response = await http.get(Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/'
          '$makeEncoded?format=json'));
      final data = json.decode(response.body);
      final results = (data['Results'] as List)
          .map((e) => e['Model_Name'].toString())
          .toList();
      results.sort();
      if (mounted) setState(() => _models = results);
    } catch (_) {
      if (mounted) setState(() => _models = ['Model 1', 'Model 2', 'Model 3']);
    } finally {
      if (mounted) setState(() => _modelsLoading = false);
    }
  }

  void _next() {
    if (_make == null || _model == null ||
        _year == null || _engineType == null) {
      AppToast.error(context, 'Please complete all vehicle fields.');
      return;
    }
    final updated = widget.state.copyWith(
      vehicle: {
        'make': _make,
        'model': _model,
        'year': int.parse(_year!),
        'engine_type': _engineType,
        'nickname': _nicknameCtrl.text.trim(),
      },
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
                    Future.delayed(
                        const Duration(milliseconds: 100), widget.onBack);
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textTertiary, size: 22),
                ),
                const SizedBox(height: 20),
                _StepTabs(currentStep: 3),
                const SizedBox(height: 40),
                Text('Tell us about\nyour vehicle',
                    style: AppTypography.h1.copyWith(
                        fontSize: 28, letterSpacing: -0.6, height: 1.15)),
                const SizedBox(height: 8),
                Text('We\u2019ll use this to personalise your diagnostics.',
                    style: AppTypography.body
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.textTertiary, size: 14),
                  const SizedBox(width: 6),
                  Text('You can add more vehicles later from your profile.',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary)),
                ]),
                const SizedBox(height: 28),
                AppSearchDropdown(
                  label: 'Make',
                  hint: _makesLoading ? 'Loading makes...' : 'Search vehicle make',
                  value: _make,
                  icon: Icons.directions_car_outlined,
                  items: _makes,
                  searchable: true,
                  onSelected: (v) {
                    setState(() => _make = v);
                    _loadModels(v);
                  },
                ),
                const SizedBox(height: 22),
                AppSearchDropdown(
                  label: 'Model',
                  hint: _make == null
                      ? 'Select make first'
                      : _modelsLoading
                          ? 'Loading models...'
                          : 'Select model',
                  value: _model,
                  icon: Icons.directions_car_outlined,
                  items: _models,
                  onSelected: (v) => setState(() => _model = v),
                ),
                const SizedBox(height: 22),
                Row(children: [
                  Expanded(
                    child: AppSearchDropdown(
                      label: 'Year',
                      hint: 'Year',
                      value: _year,
                      icon: Icons.calendar_month_outlined,
                      items: _years,
                      onSelected: (v) => setState(() => _year = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppSearchDropdown(
                      label: 'Engine Type',
                      hint: 'Type',
                      value: _engineType,
                      icon: Icons.settings_outlined,
                      items: _engineTypes,
                      onSelected: (v) => setState(() => _engineType = v),
                    ),
                  ),
                ]),
                const SizedBox(height: 22),
                _FloatingField(
                  label: 'Nickname (Optional)',
                  hint: 'e.g. My Red Corolla',
                  controller: _nicknameCtrl,
                  icon: Icons.star_outline_rounded,
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
    'Your First\nVehicle', 'Your\nIdentity',
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

// ── Floating label field ──────────────────────────────────────────
class _FloatingField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  const _FloatingField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
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
                style: AppTypography.body
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTypography.body
                      .copyWith(color: AppColors.textDisabled),
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