// Live-updating stack of incoming quote cards for the Searching screen.
// Backed by an AnimatedList whose source of truth is a locally-held,
// manually-diffed copy of quotesForRequestProvider's emissions — the stream
// always hands back the full current pending-quotes list, so every emission
// is diffed against what's already on screen to know what to insert/remove.
// A mechanic who re-bids after expiring/declining just naturally slides back
// in, since their earlier quote was already removed by an earlier diff.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/app_badge.dart';
import '../../../shared/widget/app_button.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../models/quote_model.dart';
import '../models/service_request_model.dart';
import '../providers/service_request_provider.dart';

class QuoteCardStack extends ConsumerStatefulWidget {
  final ServiceRequestModel request;

  const QuoteCardStack({super.key, required this.request});

  @override
  ConsumerState<QuoteCardStack> createState() => _QuoteCardStackState();
}

class _QuoteCardStackState extends ConsumerState<QuoteCardStack> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<QuoteModel> _quotes = [];

  void _applyDiff(List<QuoteModel> incoming) {
    final incomingIds = incoming.map((q) => q.mechanicId).toSet();
    var addedQuote = false;
    for (var i = _quotes.length - 1; i >= 0; i--) {
      if (!incomingIds.contains(_quotes[i].mechanicId)) {
        final removed = _quotes.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _exitTransition(removed, animation),
        );
      }
    }
    for (final quote in incoming) {
      final existingIndex = _quotes.indexWhere(
        (q) => q.mechanicId == quote.mechanicId,
      );
      if (existingIndex == -1) {
        final insertIndex = _quotes.length;
        _quotes.insert(insertIndex, quote);
        _listKey.currentState?.insertItem(insertIndex);
        addedQuote = true;
      } else {
        // Same mechanic, still pending — just refresh the held copy in case
        // they edited their price/note without a status change.
        _quotes[existingIndex] = quote;
      }
    }
    if (addedQuote) HapticFeedback.mediumImpact();
    if (mounted) setState(() {});
  }

  // Doesn't accept directly — hands off to MechanicCandidateProfileScreen,
  // which shows the mechanic's full profile alongside their quote and does
  // the actual acceptQuote + job creation once the car owner confirms there.
  void _viewAndAccept(BuildContext context, QuoteModel quote) {
    context.push(
      RouteNames.mechanicProfile,
      extra: {'mechanicId': quote.mechanicId, 'requestId': widget.request.id},
    );
  }

  void _decline(QuoteModel quote) {
    ref
        .read(serviceRequestProvider.notifier)
        .declineQuote(widget.request.id, quote.mechanicId);
  }

  Widget _insertTransition(QuoteModel quote, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: FadeTransition(
          opacity: animation,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _QuoteTimerCard(
              key: ValueKey(quote.mechanicId),
              requestId: widget.request.id,
              carOwnerLocation: widget.request.carOwnerLocation,
              quote: quote,
              onAccept: () => _viewAndAccept(context, quote),
              onDecline: () => _decline(quote),
            ),
          ),
        ),
      ),
    );
  }

  Widget _exitTransition(QuoteModel quote, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: _ExitingQuoteCard(quote: quote),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(quotesForRequestProvider(widget.request.id), (_, next) {
      next.whenData(_applyDiff);
    });

    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      initialItemCount: _quotes.length,
      itemBuilder: (context, index, animation) {
        if (index >= _quotes.length) return const SizedBox.shrink();
        return _insertTransition(_quotes[index], animation);
      },
    );
  }
}

class _QuoteTimerCard extends ConsumerStatefulWidget {
  final String requestId;
  final GeoPoint? carOwnerLocation;
  final QuoteModel quote;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _QuoteTimerCard({
    super.key,
    required this.requestId,
    required this.carOwnerLocation,
    required this.quote,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  ConsumerState<_QuoteTimerCard> createState() => _QuoteTimerCardState();
}

class _QuoteTimerCardState extends ConsumerState<_QuoteTimerCard> {
  static const _window = Duration(seconds: 30);
  Timer? _expireTimer;
  Timer? _tickTimer;
  late final DateTime _deadline;

  @override
  void initState() {
    super.initState();
    _deadline = widget.quote.createdAt.add(_window);
    final remaining = _deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      scheduleMicrotask(_expire);
    } else {
      _expireTimer = Timer(remaining, _expire);
      _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _expire() {
    ref
        .read(serviceRequestProvider.notifier)
        .expireQuote(widget.requestId, widget.quote.mechanicId);
  }

  @override
  void dispose() {
    _expireTimer?.cancel();
    _tickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.quote;
    final mechanicAsync = ref.watch(mechanicByIdProvider(quote.mechanicId));
    final userAsync = ref.watch(mechanicUserProvider(quote.mechanicId));
    final mechanic = mechanicAsync.valueOrNull;
    final user = userAsync.valueOrNull;
    final name = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Mechanic';

    double? distanceKm;
    final mechanicLocation = mechanic?.location;
    final ownerLocation = widget.carOwnerLocation;
    if (mechanicLocation != null && ownerLocation != null) {
      distanceKm =
          Geolocator.distanceBetween(
            ownerLocation.latitude,
            ownerLocation.longitude,
            mechanicLocation.latitude,
            mechanicLocation.longitude,
          ) /
          1000;
    }

    final remaining = _deadline.difference(DateTime.now());
    final secondsLeft = remaining.isNegative ? 0 : remaining.inSeconds;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              AppAvatar(name: name, imageUrl: user?.profilePhoto, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.heading4,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        RatingStars(
                          rating: mechanic?.rating ?? 0,
                          starSize: 12,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${(mechanic?.rating ?? 0).toStringAsFixed(1)} · ${mechanic?.totalJobs ?? 0} jobs',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${quote.price.toStringAsFixed(0)}',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Text(
                      '${secondsLeft}s',
                      style: AppTypography.captionSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (quote.note != null && quote.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                quote.note!,
                style: AppTypography.bodySmall,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Decline',
                  onTap: widget.onDecline,
                  variant: AppButtonVariant.ghost,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(label: 'Accept', onTap: widget.onAccept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A frozen, non-interactive snapshot shown only while a card animates out
/// (accepted/declined/expired) — no live timer, no buttons, just enough to
/// avoid an empty flash mid-collapse.
class _ExitingQuoteCard extends ConsumerWidget {
  final QuoteModel quote;
  const _ExitingQuoteCard({required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(mechanicUserProvider(quote.mechanicId));
    final user = userAsync.valueOrNull;
    final name = user != null
        ? '${user.firstName} ${user.lastName}'.trim()
        : 'Mechanic';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, imageUrl: user?.profilePhoto, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTypography.heading4,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            '₦${quote.price.toStringAsFixed(0)}',
            style: AppTypography.heading3.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
