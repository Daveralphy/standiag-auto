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