// Catches every exception in the app and converts it into an AppError.
// This is the single entry point for all error handling.
// No raw exception ever reaches the UI — it always passes through here first.
// Technical details are logged to Firebase Crashlytics for developers.

import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app_error.dart';
import 'error_messages.dart';

class ErrorHandler {
  // Private constructor — this class is never instantiated.
  ErrorHandler._();

  /// Converts any exception into an AppError with a user-friendly message.
  /// Also logs the raw technical details to Crashlytics.
  ///
  /// Pass [userId] and [screen] when available so developers can reproduce issues.
  static AppError handle(
    Object exception,
    StackTrace stackTrace, {
    String? userId,
    String? userType,
    String? screen,
  }) {
    // Map the raw exception to an AppErrorType
    final AppErrorType type = _classify(exception);

    // Build the AppError with the approved user message
    final AppError error = AppError(
      type: type,
      message: ErrorMessages.forType(type),
      code: _codeFor(exception),
    );

    // Log the full technical details to Crashlytics — developers see this, users never do
    _log(
      exception: exception,
      stackTrace: stackTrace,
      error: error,
      userId: userId,
      userType: userType,
      screen: screen,
    );

    return error;
  }

  /// Classifies a raw exception into the correct AppErrorType.
  static AppErrorType _classify(Object exception) {
    final String raw = exception.toString().toLowerCase();
    final String typeName = exception.runtimeType.toString();

    // Bluetooth/OBD exceptions from flutter_blue_plus (FlutterBluePlusException)
    // and our own Elm327Service (Elm327ConnectionException) are checked by
    // type name first — flutter_blue_plus's own exception text never
    // actually contains the word "bluetooth", so the generic keyword checks
    // further below never matched it and every real adapter error fell
    // through to the generic "Something went wrong" message.
    if (typeName == 'FlutterBluePlusException' ||
        typeName == 'Elm327ConnectionException') {
      if (raw.contains('permission') || raw.contains('rejected')) {
        return AppErrorType.bluetoothPermissionDenied;
      }
      if (raw.contains(' off') ||
          raw.contains('disabled') ||
          raw.contains('turn it on') ||
          raw.contains('turned off')) {
        return AppErrorType.bluetoothDisabled;
      }
      if (raw.contains('no serial') ||
          raw.contains("doesn't look like") ||
          raw.contains('not connected') ||
          raw.contains('device is disconnected')) {
        return AppErrorType.bluetoothDeviceNotFound;
      }
      if (raw.contains('scan')) {
        return AppErrorType.scanFailed;
      }
      return AppErrorType.bluetoothConnectionFailed;
    }

    // Firebase Auth error codes
    if (raw.contains('wrong-password') || raw.contains('wrong_password')) {
      return AppErrorType.wrongPassword;
    }
    if (raw.contains('user-not-found') || raw.contains('user_not_found')) {
      return AppErrorType.userNotFound;
    }
    if (raw.contains('invalid-email') || raw.contains('invalid_email')) {
      return AppErrorType.invalidEmail;
    }
    if (raw.contains('email-already-in-use') ||
        raw.contains('email_already_in_use')) {
      return AppErrorType.emailAlreadyInUse;
    }
    if (raw.contains('weak-password') || raw.contains('weak_password')) {
      return AppErrorType.weakPassword;
    }
    if (raw.contains('too-many-requests') ||
        raw.contains('too_many_requests')) {
      return AppErrorType.tooManyRequests;
    }
    if (raw.contains('invalid-verification-code') ||
        raw.contains('invalid_verification_code')) {
      return AppErrorType.invalidVerificationCode;
    }
    if (raw.contains('code-expired') || raw.contains('code_expired')) {
      return AppErrorType.codeExpired;
    }
    if (raw.contains('session-expired') || raw.contains('session_expired')) {
      return AppErrorType.sessionExpired;
    }

    // Firestore error codes
    if (raw.contains('permission-denied') || raw.contains('permission_denied')) {
      return AppErrorType.permissionDenied;
    }
    if (raw.contains('not-found') || raw.contains('not_found')) {
      return AppErrorType.notFound;
    }
    if (raw.contains('unavailable')) {
      return AppErrorType.firestoreUnavailable;
    }

    // Network errors
    if (exception is SocketException || raw.contains('no internet') ||
        raw.contains('network')) {
      return AppErrorType.noConnection;
    }
    if (exception is TimeoutException || raw.contains('timeout')) {
      return AppErrorType.timeout;
    }

    // Bluetooth / OBD errors
    if (raw.contains('bluetooth') && raw.contains('disabled')) {
      return AppErrorType.bluetoothDisabled;
    }
    if (raw.contains('bluetooth') && raw.contains('permission')) {
      return AppErrorType.bluetoothPermissionDenied;
    }
    if (raw.contains('bluetooth') && raw.contains('not found')) {
      return AppErrorType.bluetoothDeviceNotFound;
    }
    if (raw.contains('bluetooth')) {
      return AppErrorType.bluetoothConnectionFailed;
    }
    if (raw.contains('microphone') || raw.contains('audio permission')) {
      return AppErrorType.microphoneDenied;
    }

    // Upload errors
    if (raw.contains('upload') || raw.contains('storage')) {
      return AppErrorType.uploadFailed;
    }

    // Catch-all
    return AppErrorType.unknown;
  }

  /// Extracts a short code string from the raw exception for log tagging.
  static String _codeFor(Object exception) {
    final String raw = exception.toString();
    // Firebase exceptions often have a code field — extract it if present
    if (raw.contains('[') && raw.contains(']')) {
      final int start = raw.indexOf('[') + 1;
      final int end = raw.indexOf(']');
      if (end > start) return raw.substring(start, end);
    }
    return exception.runtimeType.toString();
  }

  /// Logs the full technical error to Crashlytics, and to the console —
  /// the console line is what shows up directly in `flutter run`'s output,
  /// which is the fastest way to see the real cause of an error the UI
  /// only shows a sanitized message for.
  static void _log({
    required Object exception,
    required StackTrace stackTrace,
    required AppError error,
    String? userId,
    String? userType,
    String? screen,
  }) {
    // ignore: avoid_print
    print(
        '[AppError] screen=${screen ?? '?'} type=${error.type} code=${error.code} exception=$exception');

    FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      reason: error.code,
      information: [
        if (userId != null) 'userId: $userId',
        if (userType != null) 'userType: $userType',
        if (screen != null) 'screen: $screen',
        'errorType: ${error.type}',
        'timestamp: ${DateTime.now().toIso8601String()}',
      ],
    );
  }
}