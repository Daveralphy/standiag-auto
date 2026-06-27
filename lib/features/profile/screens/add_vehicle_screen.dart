// Add Vehicle screen — form to register a new vehicle with typeahead fields.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
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

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => context.go(RouteNames.myVehicles),
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
                      onTap: () {
                        setState(() => _isLoading = true);
                        Future.delayed(const Duration(seconds: 1), () {
                        if (!context.mounted) return;
                          if (mounted) {
                            setState(() => _isLoading = false);
                            context.go(RouteNames.myVehicles);
                          }
                        });
                      },
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