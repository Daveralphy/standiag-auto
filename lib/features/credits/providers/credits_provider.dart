// Credits provider — owns the user's credit balance and transaction history.
// Balance and history are updated through Firestore transactions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/cache/cache_keys.dart';
import '../../../core/cache/cache_manager.dart';
import '../../../core/errors/error_handler.dart';

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
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!snapshot.exists) {
        throw StateError('User not found');
      }

      final balance = (snapshot.data()?['credits'] as num?)?.toInt() ?? 0;
      await CacheManager.instance.write(
        box: CacheKeys.creditsBox,
        key: CacheKeys.creditsBalance,
        value: balance,
      );
      state = state.copyWith(isLoading: false, balance: balance);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<void> fetchHistory(String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('credits_history')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final history = query.docs.map(CreditsModel.fromFirestore).toList();
      await CacheManager.instance.write(
        box: CacheKeys.creditsBox,
        key: CacheKeys.creditsHistory,
        value: history.map((transaction) => transaction.toFirestore()).toList(),
      );
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  Future<bool> deduct(String userId, int amount, String reason,
      {String? jobId}) async {
    try {
      if (state.balance < amount) {
        state = state.copyWith(
          error: ErrorHandler.handle(
            StateError('Insufficient credits'),
            StackTrace.current,
          ).message,
        );
        return false;
      }

      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(userId);
        final snapshot = await transaction.get(userRef);
        final currentBalance = (snapshot.data()?['credits'] as num?)?.toInt() ?? 0;
        if (currentBalance < amount) {
          throw StateError('Insufficient credits');
        }

        transaction.update(userRef, {'credits': currentBalance - amount});
        final historyRef = firestore.collection('credits_history').doc();
        transaction.set(
          historyRef,
          CreditsModel(
            id: historyRef.id,
            userId: userId,
            type: TransactionType.debit,
            amount: amount,
            reason: reason,
            relatedJobId: jobId,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
      });

      final nextBalance = state.balance - amount;
      state = state.copyWith(balance: nextBalance);
      await CacheManager.instance.write(
        box: CacheKeys.creditsBox,
        key: CacheKeys.creditsBalance,
        value: nextBalance,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
      return false;
    }
  }

  Future<void> purchase(String userId, int amount) async {
    state = state.copyWith(isPurchasing: true, error: null);
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(userId);
        final snapshot = await transaction.get(userRef);
        final currentBalance = (snapshot.data()?['credits'] as num?)?.toInt() ?? 0;

        transaction.update(userRef, {'credits': currentBalance + amount});
        final historyRef = firestore.collection('credits_history').doc();
        transaction.set(
          historyRef,
          CreditsModel(
            id: historyRef.id,
            userId: userId,
            type: TransactionType.credit,
            amount: amount,
            reason: 'Purchased credits',
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
      });
      state = state.copyWith(
        isPurchasing: false,
        balance: state.balance + amount,
      );
      await CacheManager.instance.write(
        box: CacheKeys.creditsBox,
        key: CacheKeys.creditsBalance,
        value: state.balance,
      );
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }
}

final creditsProvider =
    StateNotifierProvider<CreditsNotifier, CreditsState>(
        (ref) => CreditsNotifier());