import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/providers/vehicle_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../navigation/main_navigation.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() =>
      _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  String _make = 'Toyota';
  String _model = 'Corolla';
  String _year = '2016';
  String _engineType = 'Petrol';
  final _nicknameController = TextEditingController();
  final _vinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nicknameController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  Future<void> _addVehicle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await VehicleService().addVehicle(
        make: _make,
        model: _model,
        year: _year,
        engineType: _engineType,
        nickname: _nicknameController.text,
        vin: _vinController.text,
      );

      // Invalidate providers so home/profile refresh
      ref.invalidate(activeVehicleProvider);
      ref.invalidate(userVehiclesProvider);
      ref.invalidate(hasVehiclesProvider);
      ref.invalidate(scanCountProvider);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainNavigation()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'StanDiag needs your car details to give\nyou accurate diagnostics.',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 20),
                    _buildPreviewCard(),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.criticalBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.criticalBorder),
                        ),
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryLight,
                              fontFamily: 'Inter',
                            )),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                            child: _buildDropdown(
                                'MAKE',
                                _make,
                                ['Toyota', 'Honda', 'Hyundai', 'Ford',
                                  'Kia', 'Nissan', 'Mazda', 'Suzuki',
                                  'Mercedes', 'BMW', 'Lexus', 'Volkswagen'],
                                (v) =>
                                    setState(() => _make = v!))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildDropdown(
                                'MODEL',
                                _model,
                                ['Corolla', 'Camry', 'Civic', 'Accord',
                                  'Accent', 'Elantra', 'Sportage', 'Tucson',
                                  'Hilux', 'Prado', 'Sienna', 'Pathfinder'],
                                (v) =>
                                    setState(() => _model = v!))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                            child: _buildDropdown(
                                'YEAR',
                                _year,
                                ['2025', '2024', '2023', '2022', '2021',
                                  '2020', '2019', '2018', '2017', '2016',
                                  '2015', '2014', '2013', '2012', '2010',
                                  '2008', '2006', '2005', '2004', '2003',
                                  '2002', '2001', '2000'],
                                (v) =>
                                    setState(() => _year = v!))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildDropdown(
                                'ENGINE TYPE',
                                _engineType,
                                ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                                (v) => setState(
                                    () => _engineType = v!))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      label: 'NICKNAME (OPTIONAL)',
                      controller: _nicknameController,
                      hint: 'e.g. My Blue Corolla',
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      label: 'VIN (OPTIONAL)',
                      controller: _vinController,
                      hint: 'Enter VIN for enhanced accuracy',
                    ),
                    const SizedBox(height: 28),
                    _buildAddButton(),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Add your vehicle.',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final nickname = _nicknameController.text.isNotEmpty
        ? _nicknameController.text
        : null;
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
          const Text('VEHICLE PREVIEW',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text('$_make $_model  ·  $_year',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(
            '$_engineType${nickname != null ? '  •  $nickname' : ''}',
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value,
      List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 6),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceCard,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary, size: 18),
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter'),
              items: items
                  .map((item) => DropdownMenuItem(
                      value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.textDisabled,
                fontFamily: 'Inter'),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isLoading ? null : _addVehicle,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(colors: [
                  AppColors.primary.withValues(alpha: 0.5),
                  AppColors.primaryDark.withValues(alpha: 0.5),
                ])
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                      color:
                          AppColors.primary.withValues(alpha: 0.40),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('ADD VEHICLE',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.8,
                      fontFamily: 'Inter')),
        ),
      ),
    );
  }
}








