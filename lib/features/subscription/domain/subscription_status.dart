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

  bool get isPremium {
    if (tier != SubscriptionTier.premium) return false;
    if (premiumUntil == null) return true;
    return premiumUntil!.isAfter(DateTime.now());
  }

  bool get isRoasterPro {
    if (!roasterPro) return false;
    if (roasterProUntil == null) return true;
    return roasterProUntil!.isAfter(DateTime.now());
  }
}
