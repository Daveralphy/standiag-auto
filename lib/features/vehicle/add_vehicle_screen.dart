import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/searchable_dropdown.dart';
import '../../core/services/vehicle_service.dart';
import '../../core/providers/vehicle_provider.dart';
import '../../core/providers/profile_provider.dart';

const _years = [
  '2025','2024','2023','2022','2021','2020','2019','2018','2017',
  '2016','2015','2014','2013','2012','2011','2010','2009','2008',
  '2007','2006','2005','2004','2003','2002','2001','2000','1999',
  '1998','1997','1996','1995','1994','1993','1992','1991','1990',
];

const _engineTypes = ['Petrol', 'Diesel', 'Hybrid', 'Electric'];

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  // Selections
  String? _make;
  String? _model;
  String _year = '2016';
  String _engineType = 'Petrol';

  // API state
  List<String> _makes = [];
  List<String> _models = [];
  bool _loadingMakes = true;
  bool _loadingModels = false;

  // Other fields
  final _nicknameController = TextEditingController();
  final _vinController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMakesOnly();
  }

  /// Fetch makes without auto-selecting or fetching models
  Future<void> _fetchMakesOnly() async {
    try {
      final client = HttpClient();
      final req = await client.getUrl(
        Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/GetAllMakes?format=json'),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map<String, dynamic>;
      final results = data['Results'] as List<dynamic>;
      final names = results
          .map((r) => (r['Make_Name'] as String?)?.trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toList()
        ..sort();

      if (mounted) {
        setState(() {
          _makes = names;
          _loadingMakes = false;
          // Don't auto-select - let user choose
        });
      }
    } catch (_) {
      // Fallback
      if (mounted) {
        final fallback = [
          'TOYOTA', 'HONDA', 'HYUNDAI', 'KIA', 'FORD', 'NISSAN',
          'MAZDA', 'SUZUKI', 'MERCEDES-BENZ', 'BMW', 'LEXUS', 'VOLKSWAGEN',
        ];
        setState(() {
          _makes = fallback;
          _loadingMakes = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _vinController.dispose();
    super.dispose();
  }



  Future<void> _fetchModels(String make) async {
    setState(() {
      _loadingModels = true;
      _models = [];
      _model = null;
    });
    try {
      final encoded = Uri.encodeComponent(make);
      final client = HttpClient();
      final req = await client.getUrl(
        Uri.parse(
          'https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/$encoded?format=json',
        ),
      );
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      client.close();

      final data = jsonDecode(body) as Map<String, dynamic>;
      final results = data['Results'] as List<dynamic>;
      final names = results
          .map((r) => (r['Model_Name'] as String?)?.trim() ?? '')
          .where((n) => n.isNotEmpty)
          .toList()
        ..sort();

      if (mounted) {
        setState(() {
          _models = names.isNotEmpty ? names : ['—'];
          _model = names.isNotEmpty ? names.first : '—';
          _loadingModels = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _models = ['—'];
          _model = '—';
          _loadingModels = false;
        });
      }
    }
  }

  Future<void> _addVehicle() async {
    if (_make == null || _model == null) {
      AppToast.error(context, 'Please select a make and model.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await VehicleService().addVehicle(
        make: _make!,
        model: _model!,
        year: _year,
        engineType: _engineType,
        nickname: _nicknameController.text,
        vin: _vinController.text,
      );
      ref.invalidate(activeVehicleProvider);
      ref.invalidate(userVehiclesProvider);
      ref.invalidate(hasVehiclesProvider);
      ref.invalidate(scanCountProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'StanDiag needs your car details to give\nyou accurate diagnostics.',
                      style: TextStyle(
                        fontSize: 13, color: Color(0xFFBBBBBB),
                        height: 1.5, fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPreviewCard(),
                    const SizedBox(height: 20),
                    if (_loadingMakes)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(child: _buildDropdown(
                            label: 'MAKE',
                            value: _make,
                            items: _makes,
                            onChanged: (v) {
                              if (v != null && v != _make) {
                                setState(() => _make = v);
                                _fetchModels(v);
                              }
                            },
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _loadingModels
                            ? _buildLoadingDropdown('MODEL')
                            : _buildDropdown(
                                label: 'MODEL',
                                value: _model,
                                items: _models,
                                onChanged: (v) {
                                  if (v != null) setState(() => _model = v);
                                },
                              )),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildDropdown(
                            label: 'YEAR',
                            value: _year,
                            items: _years,
                            onChanged: (v) {
                              if (v != null) setState(() => _year = v);
                            },
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDropdown(
                            label: 'ENGINE TYPE',
                            value: _engineType,
                            items: _engineTypes,
                            onChanged: (v) {
                              if (v != null) setState(() => _engineType = v);
                            },
                          )),
                        ],
                      ),
                    ],
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
    return AppSecondaryHeader(
      title: 'Add your vehicle',
      onBack: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildPreviewCard() {
    final nickname = _nicknameController.text.isNotEmpty ? _nicknameController.text : null;
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
                fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.textSecondary, letterSpacing: 1.5, fontFamily: 'Inter',
              )),
          const SizedBox(height: 12),
          // ── Vehicle Image ──────────────────────────────────
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _make != null && _model != null
              ? Image.network(
                  _getVehicleImageUrl(_make!, _model!, _year),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 48,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.directions_car_rounded,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                ),
          ),
          const SizedBox(height: 12),
          // ── Vehicle Details ───────────────────────────────
          Text(
            '${_make ?? '—'} ${_model ?? '—'}  ·  $_year',
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_engineType${nickname != null ? '  •  $nickname' : ''}',
            style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  /// Get vehicle image URL from Cars.com API
  String _getVehicleImageUrl(String make, String model, String year) {
    final encodedMake = Uri.encodeComponent(make.toLowerCase());
    final encodedModel = Uri.encodeComponent(model.toLowerCase());
    return 'https://car-images.bauerau.com.au/app/mvc/image.php?width=800&quality=85&make=$encodedMake&model=$encodedModel&year=$year';
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SearchableDropdown(
      label: label,
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildLoadingDropdown(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter',
            )),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
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
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textTertiary, letterSpacing: 1.5, fontFamily: 'Inter',
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14, color: AppColors.textDisabled, fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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

  Widget _buildAddButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isLoading ? null : _addVehicle,
      child: Container(
        width: double.infinity,
        height: 56,
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
              : [BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.40),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('ADD VEHICLE',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 0.8, fontFamily: 'Inter',
                  )),
        ),
      ),
    );
  }
}
