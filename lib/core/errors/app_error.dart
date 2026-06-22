// Defines the AppError model used throughout StanDiag Auto.
// Every exception in the app is caught and converted into an AppError
// before it ever reaches the UI layer.
// Raw exceptions never leave the error handler.

// Represents every possible error category in the app.
// Used by ErrorHandler to map raw exceptions to the right AppError.
enum AppErrorType {
  // Authentication
  wrongPassword,
  userNotFound,
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  networkRequestFailed,
  invalidVerificationCode,
  codeExpired,
  sessionExpired,
  authUnknown,

  // Network
  noConnection,
  timeout,
  serverError,

  // Firestore
  permissionDenied,
  notFound,
  firestoreUnavailable,
  firestoreUnknown,

  // Credits
  insufficientCredits,
  transactionFailed,
  purchaseFailed,

  // Jobs
  jobCreationFailed,
  jobUpdateFailed,
  jobNotFound,
  jobAlreadyAccepted,

  // Calls
  callFailedToJoin,
  callConnectionLost,
  callTokenFailed,
  microphoneDenied,

  // OBD / Bluetooth
  bluetoothDisabled,
  bluetoothDeviceNotFound,
  bluetoothConnectionFailed,
  scanFailed,
  bluetoothPermissionDenied,

  // Profile / Upload
  uploadFailed,
  uploadTooLarge,
  profileUpdateFailed,

  // General
  unknown,
  maintenance,
}

// A structured error that carries a user-friendly message and a type.
// This is the only error object that the UI layer ever sees.
class AppError {
  /// The category of this error. Used for logging and conditional UI logic.
  final AppErrorType type;

  /// The message shown to the user. Always human-friendly.
  /// Sourced from ErrorMessages — never a raw exception message.
  final String message;

  /// The internal error code for developer logs. Never shown to users.
  final String code;

  const AppError({
    required this.type,
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'AppError(type: $type, code: $code, message: $message)';
}