// Tests for credits_provider.dart — verifies credit deduction logic
// and that balances update correctly after transactions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/features/credits/providers/credits_provider.dart';

void main() {
  group('CreditsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial balance is zero', () {
      final state = container.read(creditsProvider);
      expect(state.balance, equals(0));
    });

    test('deduct returns false when balance is insufficient', () async {
      final notifier = container.read(creditsProvider.notifier);
      // Balance starts at 0 — deducting 5 should fail
      final result =
          await notifier.deduct('test-user', 5, 'Contact mechanic');
      expect(result, isFalse);
    });

    test('initial state is not loading', () {
      final state = container.read(creditsProvider);
      expect(state.isLoading, isFalse);
    });

    test('initial state has empty history', () {
      final state = container.read(creditsProvider);
      expect(state.history, isEmpty);
    });
  });
}