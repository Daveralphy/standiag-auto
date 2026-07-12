// Add Vehicle screen — form to register a new vehicle with typeahead fields.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/profile/models/vehicle_model.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final _colourController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();
  bool _isLoading = false;

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

  Future<void> _save() async {
    if (_makeController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      AppErrorToast.showMessage(
          context, 'Please fill in at least the make and model.');
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);
    final success = await ref.read(profileProvider.notifier).addVehicle(
          VehicleModel(
            id: '',
            ownerId: userId,
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
    setState(() => _isLoading = false);
    if (success) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RouteNames.myVehicles);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (_, next) {
      if (next.error != null) {
        AppErrorToast.showMessage(context, next.error!);
      }
    });

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
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.myVehicles);
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text(AppStrings.addVehicleTitle,
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
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
                    const Text(AppStrings.addVehicleSubtitle,
                        style: AppTypography.body,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 22),
                    AppTextField(label: AppStrings.vehicleFieldMake,
                        controller: _makeController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldModel,
                        controller: _modelController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldYear,
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldType,
                        controller: _typeController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldColour,
                        controller: _colourController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldPlate,
                        controller: _plateController,
                        textInputAction: TextInputAction.next),
                    const SizedBox(height: 16),
                    AppTextField(label: AppStrings.vehicleFieldFuel,
                        controller: _fuelController,
                        textInputAction: TextInputAction.done),
                    const SizedBox(height: 32),
                    AppButton(
                      label: AppStrings.addVehicleSave,
                      onTap: _isLoading ? null : _save,
                      isLoading: _isLoading,
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