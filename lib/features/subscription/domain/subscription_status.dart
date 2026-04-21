enum SubscriptionTier { free, premium }

class SubscriptionStatus {
  const SubscriptionStatus({
    this.tier = SubscriptionTier.free,
    this.premiumUntil,
  });

  final SubscriptionTier tier;
  final DateTime? premiumUntil;

  bool get isPremium {
    if (tier != SubscriptionTier.premium) return false;
    if (premiumUntil == null) return true;
    return premiumUntil!.isAfter(DateTime.now());
  }
}
