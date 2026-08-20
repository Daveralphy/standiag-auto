// Mechanic Candidate Profile screen — full profile view of a mechanic the
// car owner is considering, shown from the map, search results, or an
// incoming quote. Not to be confused with profile/screens/mechanic_profile_screen.dart,
// which is a mechanic's view of their OWN profile.
//
// Two modes, based on whether [requestId] is set:
//  - No requestId: the car owner picked this mechanic directly (map pin or
//    search) — "Call Mechanic" starts the existing direct-call flow.
//  - With requestId: they're here from one of this mechanic's quotes on an
//    open request — this screen shows that quote and "Accept & Start Job"
//    finalizes it (creates the job already in the accepted state and sends
//    the mechanic straight en route), no call involved.

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/credits_pricing.dart';
import '../../../core/navigation/route_names.dart';
import '../../../features/credits/providers/credits_provider.dart';
import '../../../features/credits/services/credits_gateway.dart';
import '../../../features/profile/models/vehicle_model.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_error_toast.dart';
import '../../../shared/widget/app_text_field.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../providers/mechanics_provider.dart';
import '../../jobs/models/quote_model.dart';
import '../../jobs/providers/job_provider.dart';
import '../../jobs/providers/service_request_provider.dart';

class MechanicCandidateProfileScreen extends ConsumerStatefulWidget {
  final String mechanicId;
  final String? requestId;
  const MechanicCandidateProfileScreen({
    super.key,
    required this.mechanicId,
    this.requestId,
  });

  @override
  ConsumerState<MechanicCandidateProfileScreen> createState() =>
      _MechanicCandidateProfileScreenState();
}

class _MechanicCandidateProfileScreenState
    extends ConsumerState<MechanicCandidateProfileScreen> {
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
  }

  Future<void> _callMechanic() async {
    final details = await _CallDetailsDialog.show(context, ref);
    if (details == null || !mounted) return;

    setState(() => _isBusy = true);
    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;

    final canProceed = await CreditsGateway.charge(
      ref.read(creditsProvider.notifier),
      userId: carOwnerId,
      action: 'contact_mechanic',
      fallbackAmount: CreditsPricing.contactMechanicCost,
      reason: 'Contacted a mechanic',
    );
    if (!mounted) return;
    if (!canProceed) {
      setState(() => _isBusy = false);
      final error = ref.read(creditsProvider).error;
      AppErrorToast.showMessage(
        context,
        error ?? 'You don\'t have enough credits for this.',
      );
      return;
    }

    // Best-effort — same pattern as FindMechanicSheet: call without a
    // location rather than blocking on permission/GPS.
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
      // Fall through without a location.
    }
    if (!mounted) return;

    final jobId = await ref.read(jobProvider.notifier).createJob(
          carOwnerId: carOwnerId,
          mechanicId: widget.mechanicId,
          vehicleId: details.vehicleId ?? '',
          issue: details.issue,
          carOwnerLocation: origin,
        );
    if (!mounted) return;
    setState(() => _isBusy = false);
    context.push(RouteNames.outgoingCall,
        extra: {'jobId': jobId, 'mechanicId': widget.mechanicId});
  }

  Future<void> _acceptQuote(QuoteModel quote) async {
    setState(() => _isBusy = true);
    final request = ref.read(serviceRequestByIdProvider(widget.requestId!)).valueOrNull;
    if (request == null) {
      setState(() => _isBusy = false);
      return;
    }
    final jobId = await ref
        .read(serviceRequestProvider.notifier)
        .acceptQuote(request: request, quote: quote);
    if (!mounted) return;
    context.go(RouteNames.userMechanicAccepted, extra: jobId);
  }

  @override
  Widget build(BuildContext context) {
    final mechanicAsync = ref.watch(mechanicByIdProvider(widget.mechanicId));
    final mechanicUserAsync =
        ref.watch(mechanicUserProvider(widget.mechanicId));
    final mechanic = mechanicAsync.valueOrNull;
    final mechanicUser = mechanicUserAsync.valueOrNull;
    final mechanicName = mechanicUser != null
        ? '${mechanicUser.firstName} ${mechanicUser.lastName}'.trim()
        : 'Mechanic';

    QuoteModel? quote;
    if (widget.requestId != null) {
      final quotes =
          ref.watch(quotesForRequestProvider(widget.requestId!)).valueOrNull;
      final matches =
          quotes?.where((q) => q.mechanicId == widget.mechanicId) ?? const [];
      quote = matches.isEmpty ? null : matches.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.userMechanics);
                    }
                  },
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Mechanic Profile',
                    style: AppTypography.heading3,
                    overflow: TextOverflow.ellipsis, maxLines: 1)),
              ]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: AppColors.border)),
                      child: Column(children: [
                        AppAvatar(name: mechanicName, size: 72),
                        const SizedBox(height: 12),
                        Text(mechanicName,
                            style: AppTypography.heading2,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingStars(rating: mechanic?.rating ?? 0),
                            const SizedBox(width: 6),
                            Flexible(child: Text(
                                '${(mechanic?.rating ?? 0).toStringAsFixed(1)} · ${mechanic?.totalJobs ?? 0} jobs · ${mechanic?.yearsOfExperience ?? 0} yrs',
                                style: AppTypography.caption,
                                overflow: TextOverflow.ellipsis, maxLines: 1)),
                          ]),
                        const SizedBox(height: 12),
                        Wrap(spacing: 6, runSpacing: 6,
                          children: (mechanic?.expertise ?? const [])
                              .map((e) => ExpertiseTag(label: e))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: 12),
                        Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(
                              mechanic?.workshopAddress ?? '',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          const StatusDot(isOnline: true, size: 8),
                          const SizedBox(width: 6),
                          Text('Online',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1),
                        ]),
                      ]),
                    ),
                    if (quote != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text('Their Quote',
                                    style: AppTypography.heading4,
                                    overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              Text('₦${quote.price.toStringAsFixed(0)}',
                                  style: AppTypography.heading3
                                      .copyWith(color: AppColors.primary),
                                  overflow: TextOverflow.ellipsis, maxLines: 1),
                            ]),
                            if (quote.note != null &&
                                quote.note!.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(quote.note!,
                                  style: AppTypography.bodySmall,
                                  overflow: TextOverflow.ellipsis, maxLines: 3),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppButton(
                      label:
                          quote != null ? 'Accept Quote & Start Job' : 'Call Mechanic',
                      onTap: quote != null
                          ? () => _acceptQuote(quote!)
                          : _callMechanic,
                      isLoading: _isBusy,
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

/// What a direct call was actually about — previously every call went out
/// with an empty vehicleId and a generic hardcoded "General car issue",
/// so nothing downstream in the job flow ever showed anything meaningful.
/// Vehicle selection is optional (a car owner might be calling about
/// something not tied to a specific vehicle); the issue description is
/// required.
class _CallDetails {
  final String? vehicleId;
  final String issue;
  const _CallDetails({this.vehicleId, required this.issue});
}

class _CallDetailsDialog extends StatefulWidget {
  final List<VehicleModel> vehicles;
  const _CallDetailsDialog({required this.vehicles});

  static Future<_CallDetails?> show(BuildContext context, WidgetRef ref) {
    final vehicles = ref.read(profileProvider).vehicles;
    return showDialog<_CallDetails>(
      context: context,
      barrierColor: const Color(0xB8000000),
      builder: (_) => _CallDetailsDialog(vehicles: vehicles),
    );
  }

  @override
  State<_CallDetailsDialog> createState() => _CallDetailsDialogState();
}

class _CallDetailsDialogState extends State<_CallDetailsDialog> {
  String? _selectedVehicleId;
  final _issueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.isNotEmpty) {
      _selectedVehicleId = widget.vehicles.first.id;
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _issueController.text.trim().isNotEmpty;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.modal),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About your call',
                style: AppTypography.heading3,
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
            const SizedBox(height: 8),
            Text(
              'Let the mechanic know what\'s going on before you call.',
              style: AppTypography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            if (widget.vehicles.isNotEmpty) ...[
              Text('Vehicle', style: AppTypography.heading4),
              const SizedBox(height: 10),
              for (final vehicle in widget.vehicles) ...[
                _VehicleOption(
                  vehicle: vehicle,
                  isSelected: _selectedVehicleId == vehicle.id,
                  onTap: () =>
                      setState(() => _selectedVehicleId = vehicle.id),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
            ],
            Text("What's the problem?", style: AppTypography.heading4),
            const SizedBox(height: 10),
            AppTextField(
              label: 'Describe the issue',
              hint: 'e.g. "Car won\'t start"',
              controller: _issueController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Call',
                    onTap: canContinue
                        ? () => Navigator.of(context).pop(
                              _CallDetails(
                                vehicleId: _selectedVehicleId,
                                issue: _issueController.text.trim(),
                              ),
                            )
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                vehicle.displayName,
                style: AppTypography.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
