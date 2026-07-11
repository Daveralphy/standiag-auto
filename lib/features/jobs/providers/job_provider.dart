// Job provider — owns the active job state for both user and mechanic.
// Uses Firestore snapshots only for the active job and one-time fetches elsewhere.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_handler.dart';

import '../models/job_model.dart';

class JobState {
  final JobModel? activeJob;
  final List<JobModel> jobHistory;
  final bool isLoading;
  final String? error;

  const JobState({
    this.activeJob,
    this.jobHistory = const [],
    this.isLoading = false,
    this.error,
  });

  JobState copyWith({
    JobModel? activeJob,
    List<JobModel>? jobHistory,
    bool? isLoading,
    String? error,
    bool clearActiveJob = false,
  }) {
    return JobState(
      activeJob: clearActiveJob ? null : (activeJob ?? this.activeJob),
      jobHistory: jobHistory ?? this.jobHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobNotifier extends StateNotifier<JobState> {
  JobNotifier() : super(const JobState());

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _activeJobSubscription;

  Future<void> fetchHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final firestore = FirebaseFirestore.instance;
      final ownerQuery = await firestore
          .collection('jobs')
          .where('carOwnerId', isEqualTo: userId)
          .get();
      final mechanicQuery = await firestore
          .collection('jobs')
          .where('mechanicId', isEqualTo: userId)
          .get();

      final Map<String, JobModel> merged = {
        for (final doc in ownerQuery.docs) doc.id: JobModel.fromFirestore(doc),
        for (final doc in mechanicQuery.docs) doc.id: JobModel.fromFirestore(doc),
      };
      final history = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(isLoading: false, jobHistory: history);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  void watchActiveJob(String jobId) {
    _activeJobSubscription?.cancel();
    _activeJobSubscription = FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        state = state.copyWith(
          clearActiveJob: true,
          error: ErrorHandler.handle(
            StateError('Job not found'),
            StackTrace.current,
          ).message,
        );
        return;
      }

      state = state.copyWith(activeJob: JobModel.fromFirestore(snapshot));
    }, onError: (Object error, StackTrace stackTrace) {
      state = state.copyWith(
        error: ErrorHandler.handle(error, stackTrace).message,
      );
    });
  }

  /// Creates the `jobs/{id}` document a CarOwner's call initiates, and
  /// starts watching it immediately so the caller lands on a screen that
  /// already has real data. Returns the new job's id.
  Future<String> createJob({
    required String carOwnerId,
    required String mechanicId,
    required String vehicleId,
    required String issue,
  }) async {
    final doc = await FirebaseFirestore.instance.collection('jobs').add(
      JobModel(
        id: '',
        carOwnerId: carOwnerId,
        mechanicId: mechanicId,
        vehicleId: vehicleId,
        issue: issue,
        status: JobStatus.pending,
        createdAt: DateTime.now(),
      ).toFirestore(),
    );
    watchActiveJob(doc.id);
    return doc.id;
  }

  /// Writes the mechanic's current position onto the job doc — the one
  /// Rule-13-sanctioned write side of an otherwise real-time-only field.
  Future<void> updateMechanicLocation(String jobId, GeoPoint location) async {
    try {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .update({'mechanicLocation': location});
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'status': status.value,
        if (status == JobStatus.accepted) 'acceptedAt': FieldValue.serverTimestamp(),
        if (status == JobStatus.completed) 'completedAt': FieldValue.serverTimestamp(),
      });
      if (state.activeJob != null) {
        state = state.copyWith(activeJob: state.activeJob!.copyWith(status: status));
      }
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> submitRating(
      String jobId, double rating, String? comment) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'rating': rating,
        'ratingComment': comment,
        'completedAt': FieldValue.serverTimestamp(),
      });
      state = state.copyWith(clearActiveJob: true);
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  void clearActiveJob() {
    state = state.copyWith(clearActiveJob: true);
  }

  @override
  void dispose() {
    _activeJobSubscription?.cancel();
    super.dispose();
  }
}

final jobProvider =
    StateNotifierProvider<JobNotifier, JobState>((ref) => JobNotifier());

/// One-time fetch of every pending job request addressed to this mechanic —
/// used by mechanic_users_screen's request list. Not real-time (Rule 13):
/// browsing a list isn't one of the allowed live-query cases.
final pendingJobsForMechanicProvider =
    FutureProvider.family<List<JobModel>, String>((ref, mechanicId) async {
  final snap = await FirebaseFirestore.instance
      .collection('jobs')
      .where('mechanicId', isEqualTo: mechanicId)
      .where('status', isEqualTo: JobStatus.pending.value)
      .get();
  return snap.docs.map(JobModel.fromFirestore).toList();
});

/// Real-time listener for an incoming job request addressed to this
/// mechanic — the one Rule-13-sanctioned case for this query. Foreground
/// only: it's watched from mechanic_home_screen while the app is open.
final pendingJobForMechanicProvider =
    StreamProvider.family<JobModel?, String>((ref, mechanicId) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('mechanicId', isEqualTo: mechanicId)
      .where('status', isEqualTo: JobStatus.pending.value)
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty ? null : JobModel.fromFirestore(snap.docs.first));
});