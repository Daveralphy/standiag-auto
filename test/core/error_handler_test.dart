// Tests for error_handler.dart — verifies that exceptions are correctly
// mapped to AppError user messages and do not expose raw error details.

import 'package:flutter_test/flutter_test.dart';
import 'package:standiag_auto/core/errors/app_error.dart';
import 'package:standiag_auto/core/errors/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('maps network exception to a non-empty user message', () {
      final error = ErrorHandler.handle(
          Exception('network timeout'), StackTrace.current);
      expect(error, isA<AppError>());
      expect(error.message, isNotEmpty);
    });

    test('maps generic exception to a non-empty fallback message', () {
      final error = ErrorHandler.handle(
          Exception('something unknown'), StackTrace.current);
      expect(error, isA<AppError>());
      expect(error.message, isNotEmpty);
    });

    test('error message never exposes raw exception text', () {
      final error = ErrorHandler.handle(
          Exception('firebase: permission-denied on /users/123'),
          StackTrace.current);
      expect(error.message, isNot(contains('firebase')));
      expect(error.message, isNot(contains('permission-denied')));
      expect(error.message, isNot(contains('/users/123')));
    });
  });
}