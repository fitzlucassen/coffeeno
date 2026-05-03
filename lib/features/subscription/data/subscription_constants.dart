/// RevenueCat entitlement identifiers. Must match exactly the values
/// configured in the RevenueCat dashboard — any rename there must be
/// mirrored here.
library;

/// Coffeeno Pro entitlement (standard premium features).
const kPremiumEntitlementId = 'coffeeno_pro';

/// Coffeeno Roaster Pro entitlement (premium + roaster analytics).
/// By product rule, holding this entitlement implies holding Pro.
const kRoasterProEntitlementId = 'coffeeno_roaster_pro';

/// RevenueCat offering identifier for the Roaster Pro subscription.
const kRoasterOfferingId = 'roaster';

/// Aliases that the RevenueCat dashboard historically used. Included here so a
/// rename in one place (dashboard or code) doesn't silently break detection.
/// Check at runtime against all known aliases.
const kPremiumEntitlementAliases = <String>[
  kPremiumEntitlementId,
  'Coffeeno Pro',
];

const kRoasterProEntitlementAliases = <String>[
  kRoasterProEntitlementId,
  'Coffeeno Roaster Pro',
];
