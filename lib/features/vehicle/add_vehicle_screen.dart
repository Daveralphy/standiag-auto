import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String _make = 'Toyota';
  String _model = 'Corolla';
  String _year = '2016';
  String _engineType = 'Petrol';
  final _nicknameController = TextEditingController();
  final _vinController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    _vinController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'StanDiag needs your car details to give\nyou accurate diagnostics.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary,
                          height: 1.5, fontFamily: 'Inter'),
                    ),
                    const SizedBox(height: 20),
                    _buildPreviewCard(),
                    const SizedBox(height: 20),
                    // Make + Model row
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('MAKE', _make,
                            ['Toyota', 'Honda', 'Hyundai', 'Ford', 'Kia'],
                            (v) => setState(() => _make = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('MODEL', _model,
                            ['Corolla', 'Camry', 'Civic', 'Accent', 'Sportage'],
                            (v) => setState(() => _model = v!))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Year + Engine row
                    Row(
                      children: [
                        Expanded(child: _buildDropdown('YEAR', _year,
                            ['2024', '2023', '2022', '2020', '2019', '2018',
                              '2017', '2016', '2015', '2014', '2013', '2010'],
                            (v) => setState(() => _year = v!))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdown('ENGINE TYPE', _engineType,
                            ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                            (v) => setState(() => _engineType = v!))),
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
                    _buildAddButton(context),
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
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Add your vehicle.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
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
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary, letterSpacing: 1.5,
                  fontFamily: 'Inter')),
          const SizedBox(height: 8),
          Text('$_make $_model  ·  $_year',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(
            '$_engineType${nickname != null ? '  •  $nickname' : ''}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
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
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary,
                  fontFamily: 'Inter'),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label,
      required TextEditingController controller, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textTertiary, letterSpacing: 1.5,
                fontFamily: 'Inter')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary,
              fontFamily: 'Inter'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textDisabled,
                fontFamily: 'Inter'),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: AppColors.primary.withOpacity(0.40),
              blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Center(
          child: Text('ADD VEHICLE',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.8, fontFamily: 'Inter')),
        ),
      ),
    );
  }
}
