// Maps every AppErrorType to its approved user-facing message.
// These are the only messages users ever see when something goes wrong.
// All messages are sourced from ERRORS.md.
// Never write error strings anywhere else in the codebase.

import 'app_error.dart';

class ErrorMessages {
  // Private constructor — this class is never instantiated.
  ErrorMessages._();

  /// Returns the approved user-facing message for a given AppErrorType.
  static String forType(AppErrorType type) {
    switch (type) {
      // Authentication
      case AppErrorType.wrongPassword:
      case AppErrorType.userNotFound:
        return 'Invalid credentials. Please try again.';
      case AppErrorType.invalidEmail:
        return 'Please enter a valid email address.';
      case AppErrorType.emailAlreadyInUse:
        return 'An account with this email already exists.';
      case AppErrorType.weakPassword:
        return 'Password must be at least 6 characters.';
      case AppErrorType.tooManyRequests:
        return 'Too many attempts. Please try again in a few minutes.';
      case AppErrorType.networkRequestFailed:
        return 'Check your internet connection and try again.';
      case AppErrorType.invalidVerificationCode:
        return 'Incorrect code. Please check and try again.';
      case AppErrorType.codeExpired:
        return 'This code has expired. Please request a new one.';
      case AppErrorType.sessionExpired:
        return 'Your session has expired. Please log in again.';
      case AppErrorType.authUnknown:
        return 'Something went wrong. Please try again.';

      // Network
      case AppErrorType.noConnection:
        return 'No internet connection. Please check your network.';
      case AppErrorType.timeout:
        return 'Request timed out. Please try again.';
      case AppErrorType.serverError:
        return 'Service unavailable. Please contact support.';

      // Firestore
      case AppErrorType.permissionDenied:
        return 'You do not have permission to do that.';
      case AppErrorType.notFound:
        return 'The requested data could not be found.';
      case AppErrorType.firestoreUnavailable:
        return 'Service unavailable. Please contact support.';
      case AppErrorType.firestoreUnknown:
        return 'Something went wrong. Please try again.';

      // Credits
      case AppErrorType.insufficientCredits:
        return 'You do not have enough credits for this action.';
      case AppErrorType.transactionFailed:
        return 'Credit transaction failed. Please try again.';
      case AppErrorType.purchaseFailed:
        return 'Purchase could not be completed. Please try again.';

      // Jobs
      case AppErrorType.jobCreationFailed:
        return 'Could not create the job. Please try again.';
      case AppErrorType.jobUpdateFailed:
        return 'Could not update the job status. Please try again.';
      case AppErrorType.jobNotFound:
        return 'This job no longer exists.';
      case AppErrorType.jobAlreadyAccepted:
        return 'This job has already been accepted by another mechanic.';

      // Calls
      case AppErrorType.callFailedToJoin:
        return 'Could not connect the call. Please try again.';
      case AppErrorType.callConnectionLost:
        return 'Call connection was lost.';
      case AppErrorType.callTokenFailed:
        return 'Could not initiate call. Please try again.';
      case AppErrorType.microphoneDenied:
        return 'Microphone access is required for calls. Please enable it in settings.';

      // OBD / Bluetooth
      case AppErrorType.bluetoothDisabled:
        return 'Please enable Bluetooth to connect the OBD adapter.';
      case AppErrorType.bluetoothDeviceNotFound:
        return 'OBD adapter not found. Make sure it is plugged in and powered on.';
      case AppErrorType.bluetoothConnectionFailed:
        return 'Could not connect to the OBD adapter. Please try again.';
      case AppErrorType.scanFailed:
        return 'Scan could not be completed. Please try again.';
      case AppErrorType.bluetoothPermissionDenied:
        return 'Bluetooth permission is required. Please enable it in settings.';

      // Profile / Upload
      case AppErrorType.uploadFailed:
        return 'Could not upload the image. Please try again.';
      case AppErrorType.uploadTooLarge:
        return 'Image is too large. Please choose a smaller image.';
      case AppErrorType.profileUpdateFailed:
        return 'Could not save your changes. Please try again.';

      // General
      case AppErrorType.maintenance:
        return 'Service unavailable. Please contact support.';
      case AppErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
}