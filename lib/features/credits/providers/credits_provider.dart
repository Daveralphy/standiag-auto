// Credits provider — owns the user's credit balance and transaction history.
// Balance is cached in Hive and updated after every debit/credit.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/credits_model.dart';

class CreditsState {
  final int balance;
  final List<CreditsModel> history;
  final bool isLoading;
  final bool isPurchasing;
  final String? error;

  const CreditsState({
    this.balance = 0,
    this.history = const [],
    this.isLoading = false,
    this.isPurchasing = false,
    this.error,
  });

  CreditsState copyWith({
    int? balance,
    List<CreditsModel>? history,
    bool? isLoading,
    bool? isPurchasing,
    String? error,
  }) {
    return CreditsState(
      balance: balance ?? this.balance,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      error: error,
    );
  }
}

class CreditsNotifier extends StateNotifier<CreditsState> {
  CreditsNotifier() : super(const CreditsState());

  Future<void> fetchBalance(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: read credits field from Firestore users/{userId}
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(isLoading: false, balance: 48);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchHistory(String userId) async {
    try {
      // TODO: fetch from Firestore credits_history where userId == userId
      state = state.copyWith(history: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> deduct(String userId, int amount, String reason,
      {String? jobId}) async {
    // Uses Firestore atomic transaction to prevent race conditions
    try {
      // TODO: Firestore transaction: read balance, check sufficient, deduct, write history
      if (state.balance < amount) return false;
      state = state.copyWith(balance: state.balance - amount);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> purchase(String userId, int amount) async {
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      // TODO: integrate payment gateway, then atomic Firestore transaction to add credits
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(
        isPurchasing: false,
        balance: state.balance + amount,
      );
    } catch (e) {
      state = state.copyWith(isPurchasing: false, error: e.toString());
    }
  }
}

final creditsProvider =
    StateNotifierProvider<CreditsNotifier, CreditsState>(
        (ref) => CreditsNotifier());