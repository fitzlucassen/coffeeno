import 'package:coffeeno/features/gamification/domain/gamification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpertLevel.fromPoints — tier boundaries', () {
    test('zero points is the lowest tier', () {
      final l = ExpertLevel.fromPoints(0);
      expect(l.tier, ExpertTier.beanSprout);
      expect(l.nextTier, ExpertTier.homeBrewer);
    });

    test('negative points clamps to zero / lowest tier', () {
      final l = ExpertLevel.fromPoints(-50);
      expect(l.points, 0);
      expect(l.tier, ExpertTier.beanSprout);
    });

    test('exact threshold enters the new tier', () {
      expect(ExpertLevel.fromPoints(100).tier, ExpertTier.homeBrewer);
      expect(ExpertLevel.fromPoints(300).tier, ExpertTier.enthusiast);
      expect(ExpertLevel.fromPoints(600).tier, ExpertTier.cupper);
      expect(ExpertLevel.fromPoints(1000).tier, ExpertTier.connoisseur);
      expect(ExpertLevel.fromPoints(1500).tier, ExpertTier.masterTaster);
    });

    test('one point below a threshold stays in the lower tier', () {
      expect(ExpertLevel.fromPoints(99).tier, ExpertTier.beanSprout);
      expect(ExpertLevel.fromPoints(299).tier, ExpertTier.homeBrewer);
      expect(ExpertLevel.fromPoints(1499).tier, ExpertTier.connoisseur);
    });

    test('points beyond the top threshold stay at the top tier', () {
      final l = ExpertLevel.fromPoints(99999);
      expect(l.tier, ExpertTier.masterTaster);
      expect(l.nextTier, isNull);
      expect(l.pointsToNextTier, 0);
      expect(l.progressToNextTier, 1.0);
    });
  });

  group('ExpertLevel.fromPoints — progress', () {
    test('reports points into tier and to next', () {
      // 150 pts: in HomeBrewer (100), next Enthusiast (300).
      final l = ExpertLevel.fromPoints(150);
      expect(l.tier, ExpertTier.homeBrewer);
      expect(l.nextTier, ExpertTier.enthusiast);
      expect(l.pointsIntoTier, 50);
      expect(l.pointsToNextTier, 150);
      // span 200, into 50 -> 0.25
      expect(l.progressToNextTier, closeTo(0.25, 1e-9));
    });

    test('progress is 0 right after entering a tier', () {
      final l = ExpertLevel.fromPoints(100);
      expect(l.progressToNextTier, 0.0);
    });
  });

  group('GamificationPoints', () {
    test('action values are stable', () {
      expect(GamificationPoints.addCoffee, 10);
      expect(GamificationPoints.addTasting, 25);
    });

    test('tiers are strictly ascending by threshold', () {
      final thresholds =
          ExpertTier.values.map((t) => t.threshold).toList();
      for (var i = 1; i < thresholds.length; i++) {
        expect(thresholds[i], greaterThan(thresholds[i - 1]));
      }
    });
  });
}
