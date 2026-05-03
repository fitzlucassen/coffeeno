import 'package:coffeeno/features/subscription/data/subscription_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Subscription constants', () {
    test('primary entitlement ID is in the alias list', () {
      expect(kPremiumEntitlementAliases, contains(kPremiumEntitlementId));
      expect(
        kRoasterProEntitlementAliases,
        contains(kRoasterProEntitlementId),
      );
    });

    test('alias lists are non-empty — renaming requires at least one entry',
        () {
      expect(kPremiumEntitlementAliases, isNotEmpty);
      expect(kRoasterProEntitlementAliases, isNotEmpty);
    });

    test('pro and roaster-pro alias lists are disjoint', () {
      final premium = kPremiumEntitlementAliases.toSet();
      final roasterPro = kRoasterProEntitlementAliases.toSet();
      expect(premium.intersection(roasterPro), isEmpty);
    });

    test('roaster offering id is stable', () {
      expect(kRoasterOfferingId, 'roaster');
    });
  });
}
