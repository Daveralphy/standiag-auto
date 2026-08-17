// Service Request provider — owns the car owner's active "find a mechanic"
// broadcast, and exposes the real-time streams both sides watch: the car
// owner watches quotes coming in on their request, and mechanics watch
// open requests near them.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/errors/error_handler.dart';
import '../../auth/models/mechanic_model.dart';
import '../../mechanics/providers/mechanics_provider.dart';
import '../models/job_model.dart';
import '../models/quote_model.dart';
import '../models/service_request_model.dart';

class ServiceRequestState {
  final ServiceRequestModel? activeRequest;
  final String? error;

  const ServiceRequestState({this.activeRequest, this.error});

  ServiceRequestState copyWith({
    ServiceRequestModel? activeRequest,
    String? error,
    bool clearActiveRequest = false,
  }) {
    return ServiceRequestState(
      activeRequest: clearActiveRequest
          ? null
          : (activeRequest ?? this.activeRequest),
      error: error,
    );
  }
}

class ServiceRequestNotifier extends StateNotifier<ServiceRequestState> {
  ServiceRequestNotifier() : super(const ServiceRequestState());

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _requestSub;

  /// Broadcasts a new open request and starts watching it. Returns the new
  /// request's id.
  Future<String> createRequest({
    required String carOwnerId,
    required GeoPoint? carOwnerLocation,
    required String issue,
    required String vehicleId,
    required double radiusKm,
    String? targetMechanicId,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection('serviceRequests')
        .add(
          ServiceRequestModel(
            id: '',
            carOwnerId: carOwnerId,
            carOwnerLocation: carOwnerLocation,
            issue: issue,
            vehicleId: vehicleId,
            radiusKm: radiusKm,
            targetMechanicId: targetMechanicId,
            status: ServiceRequestStatus.open,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
    _watch(doc.id);
    return doc.id;
  }

  void _watch(String requestId) {
    _requestSub?.cancel();
    _requestSub = FirebaseFirestore.instance
        .collection('serviceRequests')
        .doc(requestId)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists) return;
            state = state.copyWith(
              activeRequest: ServiceRequestModel.fromFirestore(snapshot),
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            state = state.copyWith(
              error: ErrorHandler.handle(error, stackTrace).message,
            );
          },
        );
  }

  /// Mechanic-side: sends (or updates) this mechanic's quote on a request.
  Future<void> submitQuote({
    required String requestId,
    required String mechanicId,
    required double price,
    String? note,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .collection('quotes')
          .doc(mechanicId)
          .set(
            QuoteModel(
              mechanicId: mechanicId,
              price: price,
              note: note,
              status: QuoteStatus.pending,
              createdAt: DateTime.now(),
            ).toFirestore(),
          );
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  /// Car-owner-side: accepts one mechanic's quote. Creates the real job —
  /// directly in the `accepted` state, since a quote already stands in for
  /// the call-and-review step the pending state exists for — marks the
  /// request matched, and marks every other pending quote declined so
  /// those mechanics' apps know the request is no longer open. Returns the
  /// new job's id.
  Future<String> acceptQuote({
    required ServiceRequestModel request,
    required QuoteModel quote,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final requestRef = firestore.collection('serviceRequests').doc(request.id);
    final quotesSnap = await requestRef.collection('quotes').get();

    final jobRef = firestore.collection('jobs').doc();
    final batch = firestore.batch();
    batch.set(
      jobRef,
      JobModel(
        id: '',
        carOwnerId: request.carOwnerId,
        mechanicId: quote.mechanicId,
        vehicleId: request.vehicleId,
        issue: request.issue,
        status: JobStatus.accepted,
        carOwnerLocation: request.carOwnerLocation,
        createdAt: DateTime.now(),
        acceptedAt: DateTime.now(),
      ).toFirestore(),
    );
    batch.update(requestRef, {
      'status': ServiceRequestStatus.matched.value,
      'jobId': jobRef.id,
    });
    for (final doc in quotesSnap.docs) {
      batch.update(doc.reference, {
        'status': doc.id == quote.mechanicId
            ? QuoteStatus.accepted.value
            : QuoteStatus.declined.value,
      });
    }
    await batch.commit();
    return jobRef.id;
  }

  /// Car-owner-side: dismisses one mechanic's quote without accepting it.
  Future<void> declineQuote(String requestId, String mechanicId) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .collection('quotes')
          .doc(mechanicId)
          .update({'status': QuoteStatus.declined.value});
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  /// Car-owner-side: a quote's 30-second response window lapsed without an
  /// accept or decline — distinct from [declineQuote], since this is "didn't
  /// decide in time" rather than "said no". The mechanic can still rebid;
  /// resubmitting (see [submitQuote]) always resets status back to pending.
  Future<void> expireQuote(String requestId, String mechanicId) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .collection('quotes')
          .doc(mechanicId)
          .update({'status': QuoteStatus.expired.value});
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> cancelRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .update({'status': ServiceRequestStatus.cancelled.value});
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  // Cancels the internal Firestore listener only — never touches `state`.
  // Nothing in the app watches this notifier's own state (the searching
  // screen reads serviceRequestByIdProvider instead), and callers rely on
  // being able to call this from dispose(), where Riverpod forbids any
  // provider state mutation (it happens inside Flutter's locked tree-teardown
  // pass, the same restriction that blocks mutating state during build).
  void stopWatching() {
    _requestSub?.cancel();
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }
}

final serviceRequestProvider =
    StateNotifierProvider<ServiceRequestNotifier, ServiceRequestState>(
      (ref) => ServiceRequestNotifier(),
    );

/// Real-time stream of quotes on a request, oldest first — used by the car
/// owner's searching screen to show incoming offers as they arrive. Only
/// still-pending quotes are surfaced; accepted/declined ones drop out on
/// their own once their status changes.
final quotesForRequestProvider =
    StreamProvider.family<List<QuoteModel>, String>((ref, requestId) {
      return FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .collection('quotes')
          .orderBy('createdAt')
          .snapshots()
          .map(
            (snap) => snap.docs
                .map(QuoteModel.fromFirestore)
                .where((q) => q.status == QuoteStatus.pending)
                .toList(),
          );
    });

/// Real-time watch of a single service request by id — used by the
/// mechanic's send-quote screen so it can react if the request gets
/// matched or cancelled by someone else while they're filling in a price.
final serviceRequestByIdProvider =
    StreamProvider.family<ServiceRequestModel?, String>((ref, requestId) {
      return FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .snapshots()
          .map(
            (doc) => doc.exists ? ServiceRequestModel.fromFirestore(doc) : null,
          );
    });

/// Real-time stream of every currently open service request — the
/// unfiltered base for [nearbyServiceRequestsProvider] below. Foreground
/// only, matching the app's other live-query cases (Rule 13): mechanics see
/// new requests pop in while the app is open.
final openServiceRequestsProvider = StreamProvider<List<ServiceRequestModel>>((
  ref,
) {
  return FirebaseFirestore.instance
      .collection('serviceRequests')
      .where('status', isEqualTo: ServiceRequestStatus.open.value)
      .snapshots()
      .map((snap) => snap.docs.map(ServiceRequestModel.fromFirestore).toList());
});

/// An open request paired with its real distance from a mechanic, in
/// kilometres — null when either location is unavailable.
class NearbyServiceRequest {
  final ServiceRequestModel request;
  final double? distanceKm;
  const NearbyServiceRequest({required this.request, this.distanceKm});
}

/// Open requests within their own broadcast radius of [mechanicId]'s
/// stored location, nearest first. Firestore has no native radius query —
/// same approach as [nearbyMechanicsProvider]: fetch the (small, actively
/// open) set and filter by real distance client-side. A derived [Provider],
/// not a [StreamProvider] — it recomputes whenever either of the two async
/// sources it watches emits, without touching the raw stream directly.
final nearbyServiceRequestsProvider =
    Provider.family<AsyncValue<List<NearbyServiceRequest>>, String>((
      ref,
      mechanicId,
    ) {
      final requestsAsync = ref.watch(openServiceRequestsProvider);
      final MechanicModel? mechanic = ref
          .watch(mechanicByIdProvider(mechanicId))
          .valueOrNull;
      final mechanicLocation = mechanic?.location;

      return requestsAsync.whenData((requests) {
        return requests
            // A request targeted at a specific mechanic is invisible to everyone
            // else — untargeted (broadcast) requests are visible to all, as before.
            .where(
              (r) =>
                  r.targetMechanicId == null ||
                  r.targetMechanicId == mechanicId,
            )
            .map((request) {
              double? distanceKm;
              if (mechanicLocation != null &&
                  request.carOwnerLocation != null) {
                distanceKm =
                    Geolocator.distanceBetween(
                      mechanicLocation.latitude,
                      mechanicLocation.longitude,
                      request.carOwnerLocation!.latitude,
                      request.carOwnerLocation!.longitude,
                    ) /
                    1000;
              }
              return NearbyServiceRequest(
                request: request,
                distanceKm: distanceKm,
              );
            })
            .where((entry) {
              // A request targeted at this mechanic always reaches them, regardless
              // of distance — that's the whole point of requesting by ID.
              if (entry.request.targetMechanicId == mechanicId) return true;
              // Otherwise, only hide a request once we can prove it's out of range —
              // an unknown distance (no location yet) still gets shown rather than
              // silently dropped.
              return entry.distanceKm == null ||
                  entry.distanceKm! <= entry.request.radiusKm;
            })
            .toList()
          ..sort((a, b) {
            if (a.distanceKm == null && b.distanceKm == null) return 0;
            if (a.distanceKm == null) return 1;
            if (b.distanceKm == null) return -1;
            return a.distanceKm!.compareTo(b.distanceKm!);
          });
      });
    });
