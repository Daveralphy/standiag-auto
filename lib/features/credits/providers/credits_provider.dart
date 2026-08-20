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

  void setError(String message) {
    state = state.copyWith(error: message);
  }

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
      // Sorted client-side rather than via .orderBy() — combining a
      // where-equality filter with an order-by on a different field needs a
      // composite Firestore index, and one user's transaction count is
      // small enough that sorting here costs nothing.
      final query = await FirebaseFirestore.instance
          .collection('credits_history')
          .where('userId', isEqualTo: userId)
          .get();
      final history = query.docs.map(CreditsModel.fromFirestore).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  /// Client-enforced charge — real (a genuine Firestore transaction, a
  /// genuine balance check, a genuine ledger entry), but trusts the caller
  /// on the amount, since nothing stops a client from calling this with
  /// whatever number it wants. [CreditsGateway] tries the server-verified
  /// Cloud Function version of this first and only falls back to calling
  /// this directly if that function isn't deployed yet — see its own
  /// comment for why that's an acceptable interim tradeoff.
  Future<bool> deduct(String userId, int amount, String reason,
      {String? relatedEntityId}) async {
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
            relatedEntityId: relatedEntityId,
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

  /// Client-side fallback refund — the counterpart to [deduct]'s fallback
  /// role. Used when a charged action then fails for a system reason (a
  /// scan whose adapter disconnected mid-read, not the user's fault).
  Future<void> refund(String userId, int amount, String reason,
      {String? relatedEntityId}) async {
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
            reason: reason,
            relatedEntityId: relatedEntityId,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
      });

      final nextBalance = state.balance + amount;
      state = state.copyWith(balance: nextBalance);
      await CacheManager.instance.write(
        box: CacheKeys.creditsBox,
        key: CacheKeys.creditsBalance,
        value: nextBalance,
      );
    } catch (e) {
      state = state.copyWith(
        error: ErrorHandler.handle(e, StackTrace.current).message,
      );
    }
  }

  /// Marks a purchase attempt as in flight — the actual crediting never
  /// happens here anymore. A direct client-side balance increment is
  /// exactly the hole CreditsGateway.initiatePurchase closes: real credit
  /// only ever gets granted by the paystackWebhook Cloud Function, using
  /// Paystack's own server-verified confirmation that money actually
  /// changed hands, never a client's say-so.
  void setPurchasing(bool value) {
    state = state.copyWith(isPurchasing: value, error: null);
  }
}

final creditsProvider =
    StateNotifierProvider<CreditsNotifier, CreditsState>(
        (ref) => CreditsNotifier());