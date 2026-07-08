// Defines every static string used in StanDiag Auto.
// Never hardcode user-facing strings in widget files — always reference this class.
// This makes future localisation straightforward and keeps all copy in one place.

class AppStrings {
  // Private constructor — this class is never instantiated.
  AppStrings._();

  // ─── App Identity ──────────────────────────────────────────────────────────

  static const String appName = 'StanDiag Auto';
  static const String appTagline = 'Your mechanic, on demand.';
  static const String supportEmail = 'support@standiagauto.com';

  // ─── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';

  static const String onboarding1Title = 'Find a Mechanic\nNearby';
  static const String onboarding1Body =
      'Discover qualified mechanics in your area instantly.';

  static const String onboarding2Title = 'Diagnose\nYour Car';
  static const String onboarding2Body =
      'Use our OBD scanner to get a full health report on your vehicle.';

  static const String onboarding3Title = 'Get Back\non the Road';
  static const String onboarding3Body =
      'Connect with a mechanic, agree on a price, and get the job done.';

  // ─── Profile Type Picker ───────────────────────────────────────────────────

  static const String profileTypeTitle = 'Who are you?';
  static const String profileTypeSubtitle =
      'Choose your account type to get started';
  static const String profileTypeCarOwner = 'Car Owner';
  static const String profileTypeCarOwnerSub = 'I need a mechanic';
  static const String profileTypeMechanic = 'Mechanic';
  static const String profileTypeMechanicSub = 'I fix cars';
  static const String profileTypeContinue = 'Continue';

  // ─── Authentication ────────────────────────────────────────────────────────

  static const String login = 'Log In';
  static const String loginUsername = 'Username or Email';
  static const String loginPassword = 'Password';
  static const String loginForgotPassword = 'Forgot password?';
  static const String loginWithPhone = 'Login with phone number';
  static const String loginNoAccount = "Don't have an account? ";
  static const String loginSignUp = 'Sign Up';
  static const String loginOrDivider = 'OR';
  static const String loginGoogle = 'Google';
  static const String loginApple = 'Apple';

  static const String signUp = 'Create Account';
  static const String signUpAlreadyHave = 'Already have an account? ';
  static const String signUpLogIn = 'Log In';

  static const String otpTitle = 'Enter Code';
  static const String otpSubtitlePhone =
      'We sent a 6-digit code to your phone number.';
  static const String otpSubtitleEmail =
      'We sent a 6-digit code to your email address.';
  static const String otpResend = 'Resend';
  static const String otpVerify = 'Verify';
  static const String otpSkip = 'Skip';

  // ─── Signup Fields ─────────────────────────────────────────────────────────

  static const String fieldFirstName = 'First Name';
  static const String fieldLastName = 'Last Name';
  static const String fieldGender = 'Gender';
  static const String fieldDob = 'Date of Birth';
  static const String fieldPhone = 'Phone Number';
  static const String fieldEmail = 'Email Address';
  static const String fieldAddress = 'Address';
  static const String fieldUsername = 'Username';
  static const String fieldPassword = 'Password';
  static const String fieldConfirmPassword = 'Confirm Password';
  static const String fieldWorkshop = 'Workshop Address';
  static const String fieldExpertise = 'Expertise';
  static const String fieldExperience = 'Years of Experience';

  // ─── Home ──────────────────────────────────────────────────────────────────

  static const String homeGreeting = 'Hi,';
  static const String homeDashboard = 'Your Dashboard';
  static const String homeDiagnoseCar = 'Diagnose a Car';
  static const String homeNearbyMechanics = 'Nearby Mechanics';
  static const String homeScanTitle = "Let's Diagnose";
  static const String homeScanSubtitle = 'Your Vehicle';
  static const String homeMechanicScanTitle = 'Scan Customer';
  static const String homeMechanicScanSubtitle = 'Vehicle';
  static const String homeTapToScan = 'Tap to Scan';
  static const String homeOBDConnected = 'OBD Connected';
  static const String homeOBDHint =
      "Ask the customer to plug the OBD adapter into their car's OBD-II port before scanning.";
  static const String homeMechanicsTitle = 'Great Mechanics';
  static const String homeMechanicsSubtitle = 'Standby Nearby';
  static const String homeFindNearby = 'Find Nearby Mechanics';
  static const String homeJobRequests = 'Job Requests';
  static const String homeNearbyUsers = 'Nearby users';

  // ─── Mechanic Search Flow ──────────────────────────────────────────────────

  static const String searchRadius = 'Search Radius';
  static const String searchDefault = '1 km';
  static const String searchFindMechanics = 'Find Nearby Mechanics';
  static const String searchSearching = 'Searching for mechanics...';
  static const String searchCancel = 'Cancel Search';
  static const String searchResultOf = 'of';
  static const String searchSubscribeLock = 'Subscribe';
  static const String searchDismiss = 'Dismiss';
  static const String searchViewProfile = 'View Profile';
  static const String searchCallMechanic = 'Call Mechanic';
  static const String searchTapToCall = 'Tap to call';

  // ─── Job Flow ──────────────────────────────────────────────────────────────

  static const String jobAcceptedTitle = 'Mechanic Accepted';
  static const String jobAcceptedSubtitle = "He's on his way";
  static const String jobAcceptedBanner = 'Mechanic accepted!';
  static const String jobAcceptedBannerSub = "He's on his way to you";
  static const String jobLiveTracking = 'Live · Tap to track';

  static const String jobEnRouteTitle = 'En Route';
  static const String jobEnRouteSubtitle = 'Head to the user';

  static const String jobTrackingTitle = 'Tracking';
  static const String jobTrackingSubtitle = 'Mechanic en route';

  static const String jobArrivedTitle = 'Mechanic Arrived';
  static const String jobArrivedSubtitle = "He's here";
  static const String jobArrivedBanner = 'Kwame is here!';
  static const String jobArrivedBannerSub = 'Ready to get started';
  static const String jobConfirmStart = 'Confirm Job Started';

  static const String jobInProgressTitle = 'Job In Progress';
  static const String jobInProgressUserSub = 'Sit tight';
  static const String jobInProgressMechSub = 'Working now';
  static const String jobMarkDone = 'Mark Job as Done';
  static const String jobAwaitingConfirmation = 'Awaiting confirmation';
  static const String jobAwaitingConfirmationSub =
      'Waiting for customer to confirm';

  static const String jobCompletedTitle = 'Job Completed';
  static const String jobCompletedUserSub = 'Great work!';
  static const String jobCompletedMechSub = 'Well done!';
  static const String jobCompletedBanner = 'Job marked as done!';
  static const String jobCompletedMechBanner = 'Job completed!';
  static const String jobRatePrompt =
      'Help them grow by leaving a rating.\nIt only takes a second.';
  static const String jobRateMechanic = 'Rate Mechanic';
  static const String jobSkipRating = 'Skip';

  static const String jobRateTitle = 'Rate Mechanic';
  static const String jobRateSubtitle = 'How was the job?';
  static const String jobRateTapStar = 'Tap a star to rate';
  static const String jobRateCommentLabel = 'Comment (optional)';
  static const String jobRateCommentHint =
      'e.g. Great work, very professional...';
  static const String jobRateSubmit = 'Submit';
  static const String jobCustomerRating = 'Customer rating';

  static const String callIncoming = 'Incoming Call';
  static const String callActive = 'StanDiag Call';
  static const String callAccept = 'Accept Call';
  static const String callDecline = 'Decline';
  static const String callEnd = 'End Call';
  static const String callMute = 'Mute';
  static const String callSpeaker = 'Speaker';
  static const String callKeypad = 'Keypad';
  static const String callCompleted = 'Call completed';
  static const String callReadyForJob = 'Ready to take this job?';
  static const String callAcceptJob = 'Accept Job';
  static const String callRejectJob = 'Reject Job';

  static const String navigate = 'Navigate';
  static const String callMechanic = 'Call Mechanic';
  static const String chat = 'Chat';
  static const String call = 'Call';

  // ─── Drawer ────────────────────────────────────────────────────────────────

  static const String drawerProfile = 'Profile';
  static const String drawerMyVehicles = 'My Vehicles';
  static const String drawerServiceHistory = 'Service History';
  static const String drawerScanHistory = 'Scan History';
  static const String drawerCredits = 'Credits';
  static const String drawerSettings = 'Settings';
  static const String drawerHelp = 'Help & Support';
  static const String drawerLogOut = 'Log Out';
  static const String drawerMyJobs = 'My Jobs';
  static const String drawerJobHistory = 'Job History';

  // ─── Log Out Modal ─────────────────────────────────────────────────────────

  static const String logOutTitle = 'Log Out';
  static const String logOutMessage =
      'Are you sure you want to log out of your StanDiag account?';
  static const String logOutConfirm = 'Log Out';
  static const String logOutCancel = 'Cancel';

  // ─── Profile ───────────────────────────────────────────────────────────────

  static const String profileTitle = 'My Profile';
  static const String profileEdit = 'Edit';
  static const String profileSave = 'Save Changes';
  static const String profileCancel = 'Cancel';
  static const String profileChangePhoto = 'Change Photo';
  static const String profileMyVehicles = 'My Vehicles';
  static const String profileRating = 'Rating';
  static const String profileExpertise = 'Expertise';

  // ─── Vehicles ──────────────────────────────────────────────────────────────

  static const String vehiclesTitle = 'My Vehicles';
  static const String vehiclesAdd = '+ Add';
  static const String addVehicleTitle = 'Add Vehicle';
  static const String addVehicleSubtitle =
      'Type to search and select your vehicle details.';
  static const String addVehicleSave = 'Save Vehicle';
  static const String vehicleFieldMake = 'Make';
  static const String vehicleFieldModel = 'Model';
  static const String vehicleFieldYear = 'Year';
  static const String vehicleFieldType = 'Type';
  static const String vehicleFieldColour = 'Colour';
  static const String vehicleFieldPlate = 'Plate Number';
  static const String vehicleFieldFuel = 'Fuel Type';

  // ─── History ───────────────────────────────────────────────────────────────

  static const String serviceHistoryTitle = 'Service History';
  static const String scanHistoryTitle = 'Scan History';
  static const String jobHistoryTitle = 'Job History';
  static const String myJobsTitle = 'My Jobs';
  static const String statusCompleted = 'Completed';
  static const String statusInProgress = 'In Progress';
  static const String closeJob = 'Close Job';
    static const String errorLoadData = 'Unable to load data';
    static const String errorTryAgain = 'Try again';

  // ─── Settings ──────────────────────────────────────────────────────────────

  static const String settingsTitle = 'Settings';
  static const String settingsNotifications = 'Notifications';
  static const String settingsLanguage = 'Language';
  static const String settingsAppearance = 'Appearance';
  static const String settingsPrivacy = 'Privacy';
  static const String settingsChangePassword = 'Change Password';
  static const String settingsDeleteAccount = 'Delete Account';

  static const String notificationsTitle = 'Notifications';
  static const String languageTitle = 'Language';
  static const String appearanceTitle = 'Appearance';
  static const String privacyTitle = 'Privacy';

  static const String appearanceTheme = 'Theme';
  static const String appearanceDark = 'Dark';
  static const String appearanceLight = 'Light';
  static const String appearanceTextSize = 'Text Size';
  static const String appearanceDefault = 'Default';

  // ─── Help & Support ────────────────────────────────────────────────────────

  static const String helpTitle = 'Help & Support';
  static const String helpFaqLabel = 'FAQs';
  static const String helpStillNeed = 'Still need help?';
  static const String helpEmail = 'Email';
  static const String helpLiveChat = 'Live Chat';

  // ─── Change Password ───────────────────────────────────────────────────────

  static const String changePasswordTitle = 'Change Password';
  static const String changePasswordSubtitle =
      'Enter your current password then choose a new one. You\'ll receive a code on your email to confirm.';
  static const String changePasswordCurrent = 'Current Password';
  static const String changePasswordNew = 'New Password';
  static const String changePasswordConfirm = 'Confirm New Password';
  static const String changePasswordStrength = 'Password strength';
  static const String changePasswordSave = 'Save Changes';

  static const String verifyChangeTitle = 'Verify Change';
  static const String verifyChangeCheckEmail = 'Check your email';
  static const String verifyChangeSubtitle =
      'We sent a 6-digit code to your email address.';
  static const String verifyChangeVerify = 'Verify';

  // ─── Delete Account ────────────────────────────────────────────────────────

  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountMessage =
      'This action is permanent and cannot be undone. All your data, vehicles, history and credits will be lost forever.';
  static const String deleteAccountConfirm = 'Delete';
  static const String deleteAccountCancel = 'Cancel';

  // ─── Credits ───────────────────────────────────────────────────────────────

  static const String creditsTitle = 'My Credits';
  static const String creditsBalance = 'Your Balance';
  static const String creditsBuy = 'Buy Credits';
  static const String creditsHowItWorks = 'How Credits Work';
  static const String creditsRecentActivity = 'Recent Activity';
  static const String creditsContactMechanic = 'Contact a mechanic';
  static const String creditsOBDScan = 'OBD Scan';
  static const String creditsContactCost = '5 cr';
  static const String creditsScanCost = '10 cr';

  static const String buyCreditsTitle = 'Buy Credits';
  static const String buyCreditsSubtitle =
      'Credits never expire. Use them whenever you need.';
  static const String buyCreditsWelcome = 'Welcome Gift';
  static const String buyCreditsWelcomeSub = 'First time only';
  static const String buyCreditsWelcomeClaimed = 'Already claimed';
  static const String buyCreditsChoose = 'Choose a Bundle';
  static const String buyCreditsConfirm = 'Purchase Credits';
  static const String buyCreditsUnit = 'Credits';
  static const String buyCreditsbestValue = 'Best Value';
  static const String buyCreditsPayPrefix = 'Pay ';

  static const String creditsHistoryTitle = 'Transactions';

  // ─── General UI ────────────────────────────────────────────────────────────

  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String pending = 'Pending';
  static const String active = 'Active';
  static const String live = 'Live';
  static const String away = 'km away';
  static const String minAway = 'min away';
  static const String kmRemaining = 'km remaining';
  static const String kmCovered = 'km covered';
  static const String startedAt = 'Started';
  static const String healthScore = 'Health Score';
  static const String outOf = '/ 10';
  static const String good = 'Good';
  static const String fair = 'Fair';
  static const String poor = 'Poor';
  static const String standiagBrand = 'StanDiag';
  static const String jobs = 'jobs';
  static const String years = 'years';
  static const String yrs = 'yrs';
}