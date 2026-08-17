// Searching for Mechanic screen — the live-matching experience that used to
// live inline on the Mechanics tab. Shows the car owner's location with an
// outward-growing radar ripple, alerts them to how many mechanics are in
// range (or, for a direct-by-ID request, who specifically they're waiting
// on), and stacks incoming quotes as they arrive.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_map.dart';
import '../../../shared/widget/cancel_search_dialog.dart';
import '../../../shared/widget/system_ui_style.dart';
import '../../jobs/models/service_request_model.dart';
import '../../jobs/providers/service_request_provider.dart';
import '../../jobs/widgets/quote_card_stack.dart';
import '../providers/mechanics_provider.dart';

class SearchingMechanicScreen extends ConsumerStatefulWidget {
  final String requestId;
  const SearchingMechanicScreen({super.key, required this.requestId});

  @override
  ConsumerState<SearchingMechanicScreen> createState() =>
      _SearchingMechanicScreenState();
}

class _SearchingMechanicScreenState
    extends ConsumerState<SearchingMechanicScreen> {
  bool _isCancelling = false;

  // Captured once, up front — Riverpod's `ref` itself is unusable inside
  // dispose() (it throws "Cannot use ref after the widget was disposed",
  // even though the widget is still technically mounted at that point), but
  // the notifier object it resolves to is a plain, long-lived Dart object
  // completely independent of this widget's lifecycle, so holding onto it
  // directly sidesteps the issue entirely.
  late final ServiceRequestNotifier _serviceRequestNotifier;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.apply();
    _serviceRequestNotifier = ref.read(serviceRequestProvider.notifier);
  }

  @override
  void dispose() {
    // Only ever stops the local Firestore listener this screen opened —
    // never writes a cancellation. That write happens exclusively in
    // _cancelSearch, awaited and confirmed *before* this screen starts
    // tearing down; leaving via an accepted quote (a context.go elsewhere)
    // must not retroactively cancel a request that just got matched.
    _serviceRequestNotifier.stopWatching();
    super.dispose();
  }

  /// Confirms with the user, then cancels the request and pops — awaited
  /// and completed before the pop happens, so nothing async is left running
  /// against a screen that's already tearing down.
  Future<void> _cancelSearch(BuildContext context) async {
    if (_isCancelling) return;
    final confirmed = await CancelSearchDialog.show(context);
    if (!confirmed || !context.mounted) return;
    setState(() => _isCancelling = true);
    await _serviceRequestNotifier.cancelRequest(widget.requestId);
    if (!context.mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(
      serviceRequestByIdProvider(widget.requestId),
    );

    return Scaffold(
      backgroundColor: AppColors.mapBackground,
      body: requestAsync.when(
        data: (request) {
          if (request == null) return _buildUnavailable();
          return _buildSearching(request);
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _buildUnavailable(),
      ),
    );
  }

  Widget _buildUnavailable() {
    return SafeArea(
      child: Column(
        children: [
          _buildBackButton(),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal,
                ),
                child: Text(
                  'This request is no longer available.',
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton([VoidCallback? onTap]) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap ?? () => context.pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearching(ServiceRequestModel request) {
    final targetId = request.targetMechanicId;
    final userLocation = request.carOwnerLocation;
    final center = userLocation != null
        ? LatLng(userLocation.latitude, userLocation.longitude)
        : const LatLng(6.5244, 3.3792);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _cancelSearch(context);
      },
      child: Stack(
        children: [
          AppMap(
            initialCenter: center,
            initialZoom: 13.5,
            enableCurrentLocation: true,
            showMapControls: false,
            animateCurrentLocationRipple: true,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(() => _cancelSearch(context)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: targetId == null
                      ? _BroadcastStatus(radiusKm: request.radiusKm)
                      : _TargetedStatus(mechanicId: targetId),
                ),
              ],
            ),
          ),
          // Request details + Cancel anchored to the bottom, above the nav
          // clearance — incoming quote cards stack directly above these,
          // pushing them up as more arrive rather than covering them.
          Positioned(
            left: AppSpacing.pageHorizontal,
            right: AppSpacing.pageHorizontal,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                  ),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: QuoteCardStack(request: request),
                  ),
                ),
                const SizedBox(height: 12),
                _RequestSummaryCard(request: request),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Cancel Search',
                  variant: AppButtonVariant.danger,
                  isLoading: _isCancelling,
                  onTap: _isCancelling ? null : () => _cancelSearch(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What was actually submitted — the vehicle and problem description the
/// user entered before the search started, so it's still visible while
/// they wait instead of only existing in a sheet they've already closed.
class _RequestSummaryCard extends ConsumerWidget {
  final ServiceRequestModel request;
  const _RequestSummaryCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref
        .watch(vehicleByIdProvider(request.vehicleId))
        .valueOrNull;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle?.displayName ?? 'Your Vehicle',
                  style: AppTypography.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  request.issue,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Alerting N nearby mechanics" — the honest proxy: the real count of
/// visible mechanics within this request's own broadcast radius, using the
/// same distance data the Mechanics tab's own lists already compute (an
/// unknown distance still counts as "in range" rather than being silently
/// dropped, matching notifyNearbyMechanics' own inclusion rule).
class _BroadcastStatus extends ConsumerWidget {
  final double radiusKm;
  const _BroadcastStatus({required this.radiusKm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mechanicsAsync = ref.watch(nearbyMechanicsProvider);
    final count =
        mechanicsAsync.valueOrNull
            ?.where((m) => m.distanceKm == null || m.distanceKm! <= radiusKm)
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Searching', style: AppTypography.heading3),
        const SizedBox(height: 4),
        Text(
          count == 0
              ? 'Alerting nearby mechanics…'
              : 'Alerting $count nearby mechanic${count == 1 ? '' : 's'}',
          style: AppTypography.body,
        ),
      ],
    );
  }
}

/// "Waiting for {name} to respond" — the direct-by-ID request status.
class _TargetedStatus extends ConsumerWidget {
  final String mechanicId;
  const _TargetedStatus({required this.mechanicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mechanicUserProvider(mechanicId));
    final name = userAsync.valueOrNull != null
        ? '${userAsync.valueOrNull!.firstName} ${userAsync.valueOrNull!.lastName}'
              .trim()
        : 'the mechanic';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Searching', style: AppTypography.heading3),
        const SizedBox(height: 4),
        Text('Waiting for $name to respond…', style: AppTypography.body),
      ],
    );
  }
}
