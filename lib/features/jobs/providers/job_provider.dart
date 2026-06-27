// Job provider — owns the active job state for both user and mechanic.
// Uses a Firestore real-time stream during an active job.
// Disposes the stream when the job is completed or the screen is disposed.

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> fetchHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: fetch from Firestore jobs collection where carOwnerId or mechanicId == userId
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false, jobHistory: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String jobId, JobStatus status) async {
    try {
      // TODO: update Firestore jobs/{jobId}.status
      if (state.activeJob != null) {
        state = state.copyWith(
            activeJob: state.activeJob!.copyWith(status: status));
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> submitRating(
      String jobId, double rating, String? comment) async {
    try {
      // TODO: update Firestore jobs/{jobId} with rating and ratingComment
      state = state.copyWith(clearActiveJob: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearActiveJob() {
    state = state.copyWith(clearActiveJob: true);
  }
}

final jobProvider =
    StateNotifierProvider<JobNotifier, JobState>((ref) => JobNotifier());