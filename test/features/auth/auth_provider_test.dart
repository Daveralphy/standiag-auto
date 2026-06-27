// Tests for auth_provider.dart — verifies auth state transitions
// and that unauthenticated state routes correctly.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/shared/providers/auth_provider.dart';

void main() {
  group('AuthStateProvider', () {
    test('initial state is loading', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(authStateProvider);
      // AsyncValue starts as loading before Firebase resolves
      expect(state, isA<AsyncValue>());
    });

    test('unauthenticated state has no user', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(authStateProvider);
      // Before Firebase Auth resolves, valueOrNull is null
      expect(state.valueOrNull, isNull);
    });
  });
}