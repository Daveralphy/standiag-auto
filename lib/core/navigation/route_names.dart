// Defines every named route in StanDiag Auto.
// Never use hardcoded route strings anywhere in the app — always use this class.
// GoRouter uses these names for navigation and deep linking.

import '../../features/auth/models/user_model.dart';

class RouteNames {
  // Private constructor — this class is never instantiated.
  RouteNames._();

  // ─── App Entry ─────────────────────────────────────────────────────────────

  static const String splashOne = '/splash-one';
  static const String splashTwo = '/splash-two';
  static const String onboarding = '/onboarding';
  static const String profileTypePicker = '/profile-type-picker';

  // ─── Authentication ────────────────────────────────────────────────────────

  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String otpPhone = '/otp-phone';
  static const String otpEmail = '/otp-email';

  // User signup steps
  static const String userSignupStepOne = '/signup/user/step-one';
  static const String userSignupStepTwo = '/signup/user/step-two';
  static const String userSignupStepThree = '/signup/user/step-three';

  // Mechanic signup steps
  static const String mechanicSignupStepOne = '/signup/mechanic/step-one';
  static const String mechanicSignupStepTwo = '/signup/mechanic/step-two';
  static const String mechanicSignupStepThree = '/signup/mechanic/step-three';

  // ─── User Screens ──────────────────────────────────────────────────────────

  static const String userHome = '/user/home';
  static const String userVehicle = '/user/vehicle';
  static const String userScan = '/user/scan';
  static const String userMechanics = '/user/mechanics';

  // Mechanic search flow
  static const String mechanicProfile = '/user/mechanic-profile';
  static const String userSearchingMechanic = '/user/searching-mechanic';
  static const String inAppCall = '/user/in-app-call';

  // Job flow — user side
  static const String userMechanicAccepted = '/user/mechanic-accepted';
  static const String userTracking = '/user/tracking';
  static const String userMechanicArrived = '/user/mechanic-arrived';
  static const String userJobInProgress = '/user/job-in-progress';
  static const String userJobCompleted = '/user/job-completed';
  static const String userRateMechanic = '/user/rate-mechanic';

  // User profile (a tab root — no drawer)
  static const String userProfile = '/user/profile';
  static const String userProfileEdit = '/user/profile/edit';
  static const String myVehicles = '/user/vehicles';
  static const String addVehicle = '/user/add-vehicle';
  static const String editVehicle = '/user/edit-vehicle';
  static const String serviceHistory = '/user/service-history';
  static const String userScanHistory = '/user/scan-history';
  static const String scanDetail = '/user/scan-detail';

  // User credits
  static const String userCredits = '/user/credits';
  static const String userBuyCredits = '/user/buy-credits';
  static const String userCreditsHistory = '/user/credits-history';

  static const String userNotifications = '/user/notifications';

  // User settings
  static const String userSettings = '/user/settings';
  static const String userNotificationSettings = '/user/settings/notifications';
  static const String userLanguage = '/user/settings/language';
  static const String userAppearance = '/user/settings/appearance';
  static const String userPrivacy = '/user/settings/privacy';
  static const String userChangePassword = '/user/settings/change-password';
  static const String userVerifyPasswordChange =
      '/user/settings/verify-password-change';
  static const String userDeleteAccount = '/user/settings/delete-account';
  static const String userHelpSupport = '/user/settings/help';

  // ─── Mechanic Screens ──────────────────────────────────────────────────────

  static const String mechanicHome = '/mechanic/home';
  static const String mechanicScan = '/mechanic/scan';
  static const String mechanicUsers = '/mechanic/users';

  // Call flow — mechanic side
  static const String mechanicIncomingCall = '/mechanic/incoming-call';
  static const String mechanicActiveCall = '/mechanic/active-call';
  static const String mechanicPostCall = '/mechanic/post-call';

  // Quote flow — mechanic side
  static const String sendQuote = '/mechanic/send-quote';

  // Job flow — mechanic side
  static const String mechanicEnRoute = '/mechanic/en-route';
  static const String mechanicJobInProgress = '/mechanic/job-in-progress';
  static const String mechanicJobCompleted = '/mechanic/job-completed';

  // Mechanic profile and drawer screens
  static const String mechanicProfileView = '/mechanic/profile';
  static const String mechanicProfileEdit = '/mechanic/profile/edit';
  static const String myJobs = '/mechanic/my-jobs';
  static const String jobHistory = '/mechanic/job-history';

  // Mechanic credits
  static const String mechanicCredits = '/mechanic/credits';
  static const String mechanicBuyCredits = '/mechanic/buy-credits';
  static const String mechanicCreditsHistory = '/mechanic/credits-history';

  static const String mechanicNotifications = '/mechanic/notifications';

  // Mechanic settings (shares same screens as user settings)
  static const String mechanicSettings = '/mechanic/settings';
  static const String mechanicNotificationSettings =
      '/mechanic/settings/notifications';
  static const String mechanicLanguage = '/mechanic/settings/language';
  static const String mechanicAppearance = '/mechanic/settings/appearance';
  static const String mechanicPrivacy = '/mechanic/settings/privacy';
  static const String mechanicChangePassword =
      '/mechanic/settings/change-password';
  static const String mechanicVerifyPasswordChange =
      '/mechanic/settings/verify-password-change';
  static const String mechanicDeleteAccount =
      '/mechanic/settings/delete-account';
  static const String mechanicHelpSupport = '/mechanic/settings/help';

  // ─── Type-aware helpers ────────────────────────────────────────────────────
  // Several screens (settings, its children, drawers) are shared between
  // both `/user/...` and `/mechanic/...` route trees. These helpers pick the
  // right variant for the signed-in user's profile type so a mechanic never
  // gets routed into a CarOwner-only screen, and vice versa.

  static String homeFor(UserType type) =>
      type == UserType.mechanic ? mechanicHome : userHome;

  static String notificationsFor(UserType type) =>
      type == UserType.mechanic ? mechanicNotifications : userNotifications;

  static String settingsFor(UserType type) =>
      type == UserType.mechanic ? mechanicSettings : userSettings;

  static String notificationSettingsFor(UserType type) =>
      type == UserType.mechanic
      ? mechanicNotificationSettings
      : userNotificationSettings;

  static String languageFor(UserType type) =>
      type == UserType.mechanic ? mechanicLanguage : userLanguage;

  static String appearanceFor(UserType type) =>
      type == UserType.mechanic ? mechanicAppearance : userAppearance;

  static String privacyFor(UserType type) =>
      type == UserType.mechanic ? mechanicPrivacy : userPrivacy;

  static String changePasswordFor(UserType type) =>
      type == UserType.mechanic ? mechanicChangePassword : userChangePassword;

  static String verifyPasswordChangeFor(UserType type) =>
      type == UserType.mechanic
      ? mechanicVerifyPasswordChange
      : userVerifyPasswordChange;

  static String deleteAccountFor(UserType type) =>
      type == UserType.mechanic ? mechanicDeleteAccount : userDeleteAccount;

  static String helpSupportFor(UserType type) =>
      type == UserType.mechanic ? mechanicHelpSupport : userHelpSupport;
}
