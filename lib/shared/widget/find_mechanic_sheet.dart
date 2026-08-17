// "Find a mechanic" modal — pick (or add) a vehicle, describe the problem,
// then broadcast a service request. Reached from the Mechanics tab's "Find
// Nearby Mechanic" button (broadcast to everyone nearby) and, when
// [targetMechanicId] is set, chained after MechanicIdLookupSheet for the
// "Schedule Repair" path — same form either way, just aimed at one mechanic
// instead of everyone in range.

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/data/common_issues_data.dart';
import '../../core/data/vehicle_reference_data.dart';
import '../../core/navigation/route_names.dart';
import '../../features/jobs/providers/service_request_provider.dart';
import '../../features/profile/models/vehicle_model.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import 'app_autocomplete_field.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// The radius nearby mechanics are alerted within for a broadcast request —
/// irrelevant for a targeted one, which always reaches its target regardless
/// of distance.
const double _searchRadiusKm = 15.0;

class FindMechanicSheet {
  FindMechanicSheet._();

  static Future<void> show(
    BuildContext context, {
    String? targetMechanicId,
    String? targetMechanicName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FindMechanicSheetContent(
        targetMechanicId: targetMechanicId,
        targetMechanicName: targetMechanicName,
        onRequestCreated: (requestId) {
          context.push(RouteNames.userSearchingMechanic, extra: requestId);
        },
      ),
    );
  }
}

class _FindMechanicSheetContent extends ConsumerStatefulWidget {
  final String? targetMechanicId;
  final String? targetMechanicName;
  final ValueChanged<String> onRequestCreated;

  const _FindMechanicSheetContent({
    required this.targetMechanicId,
    required this.targetMechanicName,
    required this.onRequestCreated,
  });

  @override
  ConsumerState<_FindMechanicSheetContent> createState() =>
      _FindMechanicSheetContentState();
}

class _FindMechanicSheetContentState
    extends ConsumerState<_FindMechanicSheetContent> {
  String? _selectedVehicleId;
  bool _showAddVehicleForm = false;
  bool _isSavingVehicle = false;
  bool _isSubmitting = false;

  final _issueController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _typeController = TextEditingController();
  final _colourController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _typeController.dispose();
    _colourController.dispose();
    _plateController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  Future<void> _saveNewVehicle() async {
    if (_makeController.text.trim().isEmpty ||
        _modelController.text.trim().isEmpty) {
      return;
    }
    final ownerId = ref.read(currentUserIdProvider);
    if (ownerId == null) return;

    setState(() => _isSavingVehicle = true);
    final success = await ref
        .read(profileProvider.notifier)
        .addVehicle(
          VehicleModel(
            id: '',
            ownerId: ownerId,
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
    setState(() {
      _isSavingVehicle = false;
      if (success) {
        _selectedVehicleId = ref.read(profileProvider).vehicles.last.id;
        _showAddVehicleForm = false;
      }
    });
  }

  Future<void> _submit() async {
    final vehicleId = _selectedVehicleId;
    final issue = _issueController.text.trim();
    if (vehicleId == null || issue.isEmpty) return;
    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;

    setState(() => _isSubmitting = true);

    GeoPoint? origin;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition();
        origin = GeoPoint(position.latitude, position.longitude);
      }
    } catch (_) {
      // Broadcast/target without a location below rather than blocking on it.
    }
    if (!mounted) return;

    final requestId = await ref
        .read(serviceRequestProvider.notifier)
        .createRequest(
          carOwnerId: carOwnerId,
          carOwnerLocation: origin,
          issue: issue,
          vehicleId: vehicleId,
          radiusKm: _searchRadiusKm,
          targetMechanicId: widget.targetMechanicId,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.onRequestCreated(requestId);
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(profileProvider.select((s) => s.vehicles));
    final canSubmit =
        _selectedVehicleId != null &&
        _issueController.text.trim().isNotEmpty &&
        !_isSubmitting;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl5),
            ),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl4,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: Text(
                  widget.targetMechanicName != null
                      ? 'Request ${widget.targetMechanicName}'
                      : 'Find Nearby Mechanic',
                  style: AppTypography.heading3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl4,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl2,
                  ),
                  children: [
                    Text('Your Vehicle', style: AppTypography.heading4),
                    const SizedBox(height: 10),
                    for (final vehicle in vehicles) ...[
                      _SelectableVehicleCard(
                        vehicle: vehicle,
                        isSelected: _selectedVehicleId == vehicle.id,
                        onTap: () =>
                            setState(() => _selectedVehicleId = vehicle.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                    GestureDetector(
                      onTap: () => setState(
                        () => _showAddVehicleForm = !_showAddVehicleForm,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showAddVehicleForm
                                  ? Icons.expand_less_rounded
                                  : Icons.add_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Add a new vehicle',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showAddVehicleForm) ...[
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppAutocompleteField(
                              label: 'Make',
                              controller: _makeController,
                              suggestionsBuilder: VehicleReferenceData.makes,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppAutocompleteField(
                              label: 'Model',
                              controller: _modelController,
                              suggestionsBuilder: (query) =>
                                  VehicleReferenceData.modelsFor(
                                    _makeController.text,
                                    query,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Year',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Type',
                              controller: _typeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Colour',
                              controller: _colourController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Fuel Type',
                              controller: _fuelController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Plate Number',
                        controller: _plateController,
                      ),
                      const SizedBox(height: 14),
                      AppButton(
                        label: 'Save Vehicle',
                        isLoading: _isSavingVehicle,
                        onTap: _isSavingVehicle ? null : _saveNewVehicle,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      "What's the problem?",
                      style: AppTypography.heading4,
                    ),
                    const SizedBox(height: 10),
                    AppAutocompleteField(
                      label: 'Describe the issue',
                      hint: 'e.g. "Car won\'t start"',
                      controller: _issueController,
                      suggestionsBuilder: CommonIssuesData.filter,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: widget.targetMechanicId != null
                          ? 'Send Request'
                          : 'Search',
                      isLoading: _isSubmitting,
                      onTap: canSubmit ? _submit : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectableVehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableVehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: AppTypography.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (vehicle.type.isNotEmpty ||
                      vehicle.colour.isNotEmpty ||
                      vehicle.fuelType.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      [
                        vehicle.type,
                        vehicle.colour,
                        vehicle.fuelType,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
