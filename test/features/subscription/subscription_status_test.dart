import 'package:coffeeno/features/subscription/domain/subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionStatus', () {
    test('free default has no premium access', () {
      const s = SubscriptionStatus();
      expect(s.isPremium, isFalse);
      expect(s.isRoasterPro, isFalse);
    });

    test('premium tier alone grants premium but not roaster pro', () {
      const s = SubscriptionStatus(tier: SubscriptionTier.premium);
      expect(s.isPremium, isTrue);
      expect(s.isRoasterPro, isFalse);
    });

    test('roaster pro alone grants premium (superset rule)', () {
      const s = SubscriptionStatus(roasterPro: true);
      expect(s.isPremium, isTrue);
      expect(s.isRoasterPro, isTrue);
    });

    test('holding both entitlements still exposes both flags', () {
      const s = SubscriptionStatus(
        tier: SubscriptionTier.premium,
        roasterPro: true,
      );
      expect(s.isPremium, isTrue);
      expect(s.isRoasterPro, isTrue);
    });

    test('equality uses all fields', () {
      final until = DateTime(2026, 6, 1);
      final a = SubscriptionStatus(
        tier: SubscriptionTier.premium,
        premiumUntil: until,
      );
      final b = SubscriptionStatus(
        tier: SubscriptionTier.premium,
        premiumUntil: until,
      );
      final c = SubscriptionStatus(
        tier: SubscriptionTier.premium,
        premiumUntil: DateTime(2027, 1, 1),
      );
      expect(a, b);
      expect(a, isNot(c));
    });

    test('copyWith updates only specified fields', () {
      const base = SubscriptionStatus();
      final updated = base.copyWith(roasterPro: true);
      expect(updated.roasterPro, isTrue);
      expect(updated.tier, SubscriptionTier.free);
    });
  });
}
