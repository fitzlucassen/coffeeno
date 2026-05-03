enum SubscriptionTier { free, premium }

class SubscriptionStatus {
  const SubscriptionStatus({
    this.tier = SubscriptionTier.free,
    this.premiumUntil,
    this.roasterPro = false,
    this.roasterProUntil,
  });

  final SubscriptionTier tier;
  final DateTime? premiumUntil;
  final bool roasterPro;
  final DateTime? roasterProUntil;

  bool get isPremium => tier == SubscriptionTier.premium;

  bool get isRoasterPro => roasterPro;
}
