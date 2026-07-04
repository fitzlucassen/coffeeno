import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_provider.dart';

/// Shared purchase-flow helper for the paywalls.
///
/// Wraps the [SubscriptionRepository] purchase/restore calls together with the
/// post-purchase "wait for entitlement" polling. We can't trust the boolean
/// returned by `purchase()` because RevenueCat's entitlement flag flips active
/// asynchronously via the customer-info update listener — so after kicking off
/// a purchase we poll the relevant provider until it reflects the new state.
class PurchaseController {
  const PurchaseController(this._ref);

  final WidgetRef _ref;

  static const int _pollAttempts = 30;
  static const Duration _pollInterval = Duration(milliseconds: 100);

  /// Polls [provider] until it turns `true` (or attempts run out), then returns
  /// its final value.
  Future<bool> _waitForEntitlement(Provider<bool> provider) async {
    for (var i = 0; i < _pollAttempts; i++) {
      if (_ref.read(provider)) break;
      await Future<void>.delayed(_pollInterval);
    }
    return _ref.read(provider);
  }

  /// Kicks off a Pro purchase and waits for the premium entitlement to
  /// propagate. Returns whether the user is premium once polling completes.
  Future<bool> purchasePremium() async {
    await _ref.read(subscriptionRepositoryProvider).purchase();
    return _waitForEntitlement(isPremiumProvider);
  }

  /// Kicks off a Roaster Pro purchase and waits for the entitlement to
  /// propagate. Returns whether the user has Roaster Pro once polling completes.
  Future<bool> purchaseRoasterPro() async {
    await _ref.read(subscriptionRepositoryProvider).purchaseRoasterPro();
    return _waitForEntitlement(isRoasterProProvider);
  }

  /// Restores purchases, returning the repository's success flag directly.
  Future<bool> restore() {
    return _ref.read(subscriptionRepositoryProvider).restore();
  }

  /// Restores purchases and waits for the premium entitlement to propagate.
  /// Returns whether the user is premium once polling completes.
  Future<bool> restoreAndWaitForPremium() async {
    await _ref.read(subscriptionRepositoryProvider).restore();
    return _waitForEntitlement(isPremiumProvider);
  }
}
