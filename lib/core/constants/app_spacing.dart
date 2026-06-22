// Defines every spacing value used in StanDiag Auto.
// Never use raw numbers for padding, margin, or gaps — always reference this class.
// All values are derived directly from the HTML design files in /design/.

class AppSpacing {
  // Private constructor — this class is never instantiated.
  AppSpacing._();

  // ─── Base Scale ────────────────────────────────────────────────────────────

  /// 2px. Used for the tightest internal gaps (e.g. between icon and dot).
  static const double xxs = 2;

  /// 4px. Used for icon gaps and tight inline spacing.
  static const double xs = 4;

  /// 6px. Used for small gaps between inline elements and tag padding.
  static const double sm = 6;

  /// 8px. Used for button inner gaps, small card spacing, and list item gaps.
  static const double md = 8;

  /// 10px. Used for card internal row gaps and avatar-to-text spacing.
  static const double lg = 10;

  /// 12px. Used for card internal padding and standard list item spacing.
  static const double xl = 12;

  /// 14px. Used for card padding and modal internal spacing.
  static const double xl2 = 14;

  /// 16px. Used for nav bar positioning offset from screen edges.
  static const double xl3 = 16;

  /// 18px. Used for screen horizontal padding (the standard page margin).
  static const double pageHorizontal = 18;

  /// 20px. Used for larger card padding and profile card spacing.
  static const double xl4 = 20;

  /// 22px. Used for drawer top padding and credits card internal padding.
  static const double xl5 = 22;

  /// 24px. Used for large section spacing and modal button area padding.
  static const double xxl = 24;

  /// 28px. Used for modal horizontal padding and large section gaps.
  static const double xxl2 = 28;

  /// 32px. Used for page-level bottom padding and large gaps.
  static const double xxl3 = 32;

  /// 36px. Used for drawer bottom padding.
  static const double xxl4 = 36;

  /// 48px. Used for splash screen and large vertical centering gaps.
  static const double xxxl = 48;

  /// 52px. Used for splash screen spinner bottom padding.
  static const double xxxl2 = 52;

  // ─── Semantic Aliases ──────────────────────────────────────────────────────
  // These make intent clear when reading widget code.

  /// Standard horizontal padding applied to every screen's content area.
  static const double screenPadding = pageHorizontal;

  /// Gap between avatar and text in header rows.
  static const double avatarGap = lg;

  /// Gap between icon and label inside buttons.
  static const double buttonIconGap = md;

  /// Internal padding for standard cards.
  static const double cardPadding = xl2;

  /// Gap between cards in a list.
  static const double cardGap = md;

  /// Gap between two buttons placed side by side.
  static const double buttonRowGap = lg;

  /// Padding inside tag/pill widgets.
  static const double tagPaddingH = md;
  static const double tagPaddingV = xs;

  /// Gap between tags in a wrap row.
  static const double tagGap = xs;

  /// Bottom padding to clear the floating nav bar.
  static const double navBarClearance = 90;

  /// Distance from screen bottom edge to nav bar bottom.
  static const double navBarBottomOffset = xl3;

  /// Distance from screen edges to nav bar left and right.
  static const double navBarSideOffset = xl3;

  /// Height of the floating nav bar.
  static const double navBarHeight = 60;

  /// Size of the active nav item protruding circle.
  static const double navBarActiveSize = 46;

  /// How far the active nav item protrudes above the nav bar.
  static const double navBarActiveProtrude = 18;

  /// Standard icon button size (bell, search, history top-right buttons).
  static const double iconButtonSize = 32;
}