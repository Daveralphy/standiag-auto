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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
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
    SystemUiStyle.applyDark();
  }

  Future<void> _callMechanic() async {
    setState(() => _isBusy = true);
    final carOwnerId = ref.read(currentUserIdProvider);
    if (carOwnerId == null) return;
    final jobId = await ref.read(jobProvider.notifier).createJob(
          carOwnerId: carOwnerId,
          mechanicId: widget.mechanicId,
          vehicleId: '',
          issue: 'General car issue',
        );
    if (!mounted) return;
    context.go(RouteNames.inAppCall,
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
                      color: const Color(0x12FFFFFF),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.border)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Mechanic Profile',
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
                        const Divider(color: AppColors.borderSubtle),
                        const SizedBox(height: 12),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(child: Text(
                              mechanic?.workshopAddress ?? '',
                              style: AppTypography.bodySmall,
                              overflow: TextOverflow.ellipsis, maxLines: 1)),
                        ]),
                        const SizedBox(height: 6),
                        const Row(children: [
                          StatusDot(isOnline: true, size: 8),
                          SizedBox(width: 6),
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
                              const Expanded(
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
