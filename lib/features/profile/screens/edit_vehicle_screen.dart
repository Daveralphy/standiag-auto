// Edit Vehicle screen — same floating-label form as Add Vehicle, prefilled
// with the selected vehicle's real data, with Save and Delete actions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/data/vehicle_reference_data.dart';
import '../models/vehicle_model.dart';
import '../providers/profile_provider.dart';
import '../../../shared/widget/app_autocomplete_field.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class EditVehicleScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  const EditVehicleScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final _colourController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _colourController.dispose();
    _plateController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  void _prefillOnce(VehicleModel vehicle) {
    if (_prefilled) return;
    _prefilled = true;
    _makeController.text = vehicle.make;
    _modelController.text = vehicle.model;
    _yearController.text = vehicle.year;
    _typeController.text = vehicle.type;
    _colourController.text = vehicle.colour;
    _plateController.text = vehicle.plateNumber;
    _fuelController.text = vehicle.fuelType;
  }

  Future<void> _save(VehicleModel original) async {
    if (_makeController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      AppErrorToast.showMessage(
          context, 'Please fill in at least the make and model.');
      return;
    }
    setState(() => _isSaving = true);
    final success = await ref.read(profileProvider.notifier).updateVehicle(
          VehicleModel(
            id: original.id,
            ownerId: original.ownerId,
            make: _makeController.text.trim(),
            model: _modelController.text.trim(),
            year: _yearController.text.trim(),
            type: _typeController.text.trim(),
            colour: _colourController.text.trim(),
            plateNumber: _plateController.text.trim(),
            fuelType: _fuelController.text.trim(),
          ),
        );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove this vehicle?', style: AppTypography.heading4),
        content: const Text(
            'This can\'t be undone. You can add it again later if needed.',
            style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    await ref.read(profileProvider.notifier).deleteVehicle(widget.vehicleId);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

    final vehicles = ref.watch(profileProvider).vehicles;
    final vehicle = vehicles.where((v) => v.id == widget.vehicleId).firstOrNull;

    if (vehicle == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vehicle not found', style: AppTypography.heading3),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Text('Go back',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _prefillOnce(vehicle);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.pageHorizontal,
                  AppSpacing.md, AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Edit Vehicle',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
                GestureDetector(
                  onTap: _isDeleting ? null : _delete,
                  child: _isDeleting
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.primary))
                      : const Icon(Icons.delete_outline_rounded,
                          size: 20, color: AppColors.primary),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    AppAutocompleteField(
                        label: AppStrings.vehicleFieldMake,
                        hint: AppStrings.vehicleHintMake,
                        controller: _makeController,
                        suggestionsBuilder: VehicleReferenceData.makes),
                    const SizedBox(height: 16),
                    AppAutocompleteField(
                        label: AppStrings.vehicleFieldModel,
                        hint: AppStrings.vehicleHintModel,
                        controller: _modelController,
                        suggestionsBuilder: (query) => VehicleReferenceData
                            .modelsFor(_makeController.text, query)),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldYear,
                        hint: AppStrings.vehicleHintYear,
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldType,
                        hint: AppStrings.vehicleHintType,
                        controller: _typeController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldColour,
                        hint: AppStrings.vehicleHintColour,
                        controller: _colourController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldPlate,
                        hint: AppStrings.vehicleHintPlate,
                        controller: _plateController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldFuel,
                        hint: AppStrings.vehicleHintFuel,
                        controller: _fuelController,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Save Changes',
                      onTap: _isSaving ? null : () => _save(vehicle),
                      isLoading: _isSaving,
                    ),
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
}
