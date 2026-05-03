enum SubscriptionTier { free, premium }

/// Represents a user's full subscription state.
///
/// Product rule: Roaster Pro is a **superset** of Pro. A user who holds the
/// Roaster Pro entitlement automatically has access to all Pro features — so
/// [isPremium] returns `true` if either [tier] is [SubscriptionTier.premium]
/// **or** [roasterPro] is active, regardless of what was explicitly purchased.
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

  /// True iff the user currently has access to Pro features — either via the
  /// Pro entitlement or via the Roaster Pro entitlement (which implies Pro).
  bool get isPremium =>
      tier == SubscriptionTier.premium || roasterPro;

  bool get isRoasterPro => roasterPro;

  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    DateTime? premiumUntil,
    bool? roasterPro,
    DateTime? roasterProUntil,
  }) {
    return SubscriptionStatus(
      tier: tier ?? this.tier,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      roasterPro: roasterPro ?? this.roasterPro,
      roasterProUntil: roasterProUntil ?? this.roasterProUntil,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatus &&
          runtimeType == other.runtimeType &&
          tier == other.tier &&
          premiumUntil == other.premiumUntil &&
          roasterPro == other.roasterPro &&
          roasterProUntil == other.roasterProUntil;

  @override
  int get hashCode =>
      Object.hash(tier, premiumUntil, roasterPro, roasterProUntil);
}
