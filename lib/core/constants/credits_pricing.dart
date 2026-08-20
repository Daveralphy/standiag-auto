// The single source of truth for what every credit-gated action costs (and
// what a new account starts with). Previously these numbers existed only as
// disconnected display strings in app_strings.dart, never actually consumed
// by any charge — this is what both the UI display AND the real charge now
// read from, so the two can never drift apart again.
//
// Mirrored in functions/src/index.ts's own ACTION_PRICING constant for the
// secure, server-verified version of these same charges — keep the two in
// sync.
class CreditsPricing {
  CreditsPricing._();

  static const int contactMechanicCost = 5;
  static const int obdScanCost = 10;

  /// Granted once, at signup, so a brand-new account can try one scan or
  /// one call before ever needing to buy credits.
  static const int signupBonus = 20;
}
