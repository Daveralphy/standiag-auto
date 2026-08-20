// Routes every credit-gated action through the secure, server-verified
// chargeForAction/refundCredits Cloud Functions first, and only falls back
// to the client-enforced CreditsNotifier.deduct()/refund() when those
// functions genuinely aren't deployed yet (no Blaze) — never when a
// function actually runs and says no. This is why call sites (contact
// mechanic, OBD scan) need no changes at all the day Blaze/Functions go
// live: the exact same call starts resolving through the secure path
// automatically, with zero code change.
//
// The client-side fallback is real enforcement (a genuine Firestore
// transaction, a genuine balance check) — just not server-verified, so a
// determined user could still bypass it by editing their own document
// directly. That gap is accepted deliberately for now: the alternative
// (blocking scanning/calling entirely until Blaze is enabled) would break
// the app for the current pilot users, which matters more right now than
// closing a hole only a technically-inclined user would even find.
//
// Takes the already-resolved CreditsNotifier directly rather than a Ref —
// call sites live in both widget code (WidgetRef) and a plain
// StateNotifier (ScanNotifier, no WidgetRef available), and both can
// already do `ref.read(creditsProvider.notifier)` themselves.

import 'package:cloud_functions/cloud_functions.dart';

import '../../../core/errors/error_handler.dart';
import '../providers/credits_provider.dart';

class CreditsGateway {
  CreditsGateway._();

  static bool _looksUndeployed(FirebaseFunctionsException e) =>
      e.code == 'not-found' || e.code == 'unavailable';

  /// Charges for a gated action. Returns true if the action may proceed,
  /// false if it was blocked (insufficient credits, or a real server
  /// error) — either way, any user-facing message is already set on
  /// [creditsNotifier]'s `error` field for the caller to surface.
  static Future<bool> charge(
    CreditsNotifier creditsNotifier, {
    required String userId,
    required String action,
    required int fallbackAmount,
    required String reason,
    String? relatedEntityId,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('chargeForAction').call({
        'action': action,
        if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      });
      await creditsNotifier.fetchBalance(userId);
      return true;
    } on FirebaseFunctionsException catch (e) {
      if (_looksUndeployed(e)) {
        return creditsNotifier.deduct(
          userId,
          fallbackAmount,
          reason,
          relatedEntityId: relatedEntityId,
        );
      }
      creditsNotifier.setError(
        e.code == 'resource-exhausted'
            ? 'You don\'t have enough credits for this.'
            : ErrorHandler.handle(e, StackTrace.current).message,
      );
      return false;
    } catch (e, stackTrace) {
      // Anything else (no network, engine not initialized, etc.) — can't
      // tell this apart from "not deployed" here, and a hard failure to
      // even attempt the secure path isn't a reason to block the pilot.
      ErrorHandler.handle(e, stackTrace, screen: 'CreditsGateway.charge');
      return creditsNotifier.deduct(
        userId,
        fallbackAmount,
        reason,
        relatedEntityId: relatedEntityId,
      );
    }
  }

  /// Refunds a charge for a system-caused failure — never called for a
  /// user-caused one (e.g. they just decided not to proceed).
  static Future<void> refund(
    CreditsNotifier creditsNotifier, {
    required String userId,
    required int amount,
    required String reason,
    String? relatedEntityId,
  }) async {
    try {
      await FirebaseFunctions.instance.httpsCallable('refundCredits').call({
        'amount': amount,
        'reason': reason,
        if (relatedEntityId != null) 'relatedEntityId': relatedEntityId,
      });
      await creditsNotifier.fetchBalance(userId);
    } on FirebaseFunctionsException catch (e) {
      if (_looksUndeployed(e)) {
        await creditsNotifier.refund(
          userId,
          amount,
          reason,
          relatedEntityId: relatedEntityId,
        );
      }
      // A real rejection (e.g. no matching un-refunded charge found
      // server-side) is left alone — never fall back to granting credits
      // anyway just because the server said no.
    } catch (_) {
      await creditsNotifier.refund(
        userId,
        amount,
        reason,
        relatedEntityId: relatedEntityId,
      );
    }
  }
}
