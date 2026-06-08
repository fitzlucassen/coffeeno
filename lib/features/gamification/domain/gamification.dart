// Pure, side-effect-free gamification rules: how actions earn points and how
// cumulative points map to cosmetic "expert" tiers. Kept free of Flutter and
// Firebase so it's trivially unit-testable and easy to retune.

/// Points awarded per user action. Centralized so award sites can't drift.
abstract final class GamificationPoints {
  /// Adding a coffee to the library.
  static const int addCoffee = 10;

  /// Logging a tasting.
  static const int addTasting = 25;
}

/// A cosmetic expertise tier. Order matters: [index] is the rank, ascending.
enum ExpertTier {
  beanSprout(0),
  homeBrewer(100),
  enthusiast(300),
  cupper(600),
  connoisseur(1000),
  masterTaster(1500);

  const ExpertTier(this.threshold);

  /// Minimum cumulative points required to reach this tier.
  final int threshold;
}

/// The user's gamification standing derived purely from a point total.
class ExpertLevel {
  const ExpertLevel({
    required this.points,
    required this.tier,
    required this.nextTier,
    required this.pointsIntoTier,
    required this.pointsToNextTier,
    required this.progressToNextTier,
  });

  final int points;
  final ExpertTier tier;

  /// The next tier up, or null when already at the top tier.
  final ExpertTier? nextTier;

  /// Points earned since entering the current tier.
  final int pointsIntoTier;

  /// Points still needed to reach [nextTier]; 0 when at the top tier.
  final int pointsToNextTier;

  /// Progress from the current tier toward the next, in 0..1. 1.0 at the top.
  final double progressToNextTier;

  /// Computes the level for a (non-negative) [points] total. Negative input is
  /// treated as 0.
  factory ExpertLevel.fromPoints(int points) {
    final safe = points < 0 ? 0 : points;

    // Highest tier whose threshold is reached.
    var tier = ExpertTier.beanSprout;
    for (final t in ExpertTier.values) {
      if (safe >= t.threshold) {
        tier = t;
      } else {
        break;
      }
    }

    final tierIndex = tier.index;
    final isTop = tierIndex == ExpertTier.values.length - 1;
    final next = isTop ? null : ExpertTier.values[tierIndex + 1];

    final pointsIntoTier = safe - tier.threshold;
    if (isTop) {
      return ExpertLevel(
        points: safe,
        tier: tier,
        nextTier: null,
        pointsIntoTier: pointsIntoTier,
        pointsToNextTier: 0,
        progressToNextTier: 1.0,
      );
    }

    final span = next!.threshold - tier.threshold;
    final pointsToNext = next.threshold - safe;
    final progress = span <= 0 ? 1.0 : (pointsIntoTier / span).clamp(0.0, 1.0);

    return ExpertLevel(
      points: safe,
      tier: tier,
      nextTier: next,
      pointsIntoTier: pointsIntoTier,
      pointsToNextTier: pointsToNext,
      progressToNextTier: progress,
    );
  }
}
