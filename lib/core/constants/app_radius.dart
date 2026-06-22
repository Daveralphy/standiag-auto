// Defines every border radius value used in StanDiag Auto.
// Never use raw numbers for border radius — always reference this class.
// All values are derived directly from the HTML design files in /design/.

class AppRadius {
  // Private constructor — this class is never instantiated.
  AppRadius._();

  // ─── Base Scale ────────────────────────────────────────────────────────────

  /// 8px. Used for small tags, close buttons, and tiny chips.
  static const double xs = 8;

  /// 10px. Used for small buttons, icon containers, and settings item icons.
  static const double sm = 10;

  /// 12px. Used for input fields, OTP boxes, and small cards.
  static const double md = 12;

  /// 14px. Used for standard buttons, ghost buttons, and modal buttons.
  static const double lg = 14;

  /// 16px. Used for standard list cards and history cards.
  static const double xl = 16;

  /// 18px. Used for vehicle cards and history cards.
  static const double xl2 = 18;

  /// 20px. Used for large profile cards, job cards, and mechanic cards.
  static const double xl3 = 20;

  /// 22px. Used for credits balance card.
  static const double xl4 = 22;

  /// 24px. Used for modals (log out, delete account, sign out).
  static const double xl5 = 24;

  /// 28px. Used for the floating navigation bar.
  static const double navBar = 28;

  /// 54px. Used for the phone frame in design reference only.
  /// Never applied to actual app UI elements.
  static const double phoneFrame = 54;

  /// 99px. Used for pill buttons, toggles, avatar borders, and any fully-rounded element.
  static const double full = 99;

  // ─── Semantic Aliases ──────────────────────────────────────────────────────

  /// Border radius for all primary pill buttons.
  static const double buttonPrimary = full;

  /// Border radius for ghost/secondary buttons.
  static const double buttonSecondary = lg;

  /// Border radius for all text input fields.
  static const double input = md;

  /// Border radius for OTP digit boxes.
  static const double otpBox = md;

  /// Border radius for standard content cards.
  static const double card = xl3;

  /// Border radius for small list cards (history, jobs).
  static const double cardSmall = xl;

  /// Border radius for modals and bottom sheets.
  static const double modal = xl5;

  /// Border radius for the floating navigation bar.
  static const double floatingNav = navBar;

  /// Border radius for tag/expertise pills.
  static const double tag = full;

  /// Border radius for settings item icon containers.
  static const double iconContainer = sm;

  /// Border radius for avatar images (makes them circular).
  static const double avatar = full;

  /// Border radius for the credits balance card.
  static const double creditsCard = xl4;

  /// Border radius for toggle switches.
  static const double toggle = full;
}