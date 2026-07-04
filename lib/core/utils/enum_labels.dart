import 'package:coffeeno/l10n/app_localizations.dart';

import '../constants/app_constants.dart';

/// Localized display labels for the brewing enums. The enum values themselves
/// carry only a stable persisted [BrewMethod.key]; the human-readable string is
/// resolved here so it can be translated.
extension BrewMethodL10n on BrewMethod {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    BrewMethod.v60 => l10n.brewMethodV60,
    BrewMethod.espresso => l10n.brewMethodEspresso,
    BrewMethod.aeropress => l10n.brewMethodAeropress,
    BrewMethod.frenchPress => l10n.brewMethodFrenchPress,
    BrewMethod.chemex => l10n.brewMethodChemex,
    BrewMethod.mokaPot => l10n.brewMethodMokaPot,
    BrewMethod.coldBrew => l10n.brewMethodColdBrew,
    BrewMethod.siphon => l10n.brewMethodSiphon,
    BrewMethod.turkishCoffee => l10n.brewMethodTurkish,
    BrewMethod.pourOver => l10n.brewMethodPourOver,
    BrewMethod.other => l10n.brewMethodOther,
  };
}

extension GrindSizeL10n on GrindSize {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    GrindSize.extraFine => l10n.grindExtraFine,
    GrindSize.fine => l10n.grindFine,
    GrindSize.mediumFine => l10n.grindMediumFine,
    GrindSize.medium => l10n.grindMedium,
    GrindSize.mediumCoarse => l10n.grindMediumCoarse,
    GrindSize.coarse => l10n.grindCoarse,
    GrindSize.extraCoarse => l10n.grindExtraCoarse,
  };
}

extension ProcessingMethodL10n on ProcessingMethod {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    ProcessingMethod.washed => l10n.processWashed,
    ProcessingMethod.natural => l10n.processNatural,
    ProcessingMethod.honey => l10n.processHoney,
    ProcessingMethod.anaerobic => l10n.processAnaerobic,
    ProcessingMethod.wetHulled => l10n.processWetHulled,
    ProcessingMethod.experimental => l10n.processExperimental,
    ProcessingMethod.other => l10n.processOther,
  };
}

extension RoastLevelL10n on RoastLevel {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    RoastLevel.light => l10n.roastLight,
    RoastLevel.mediumLight => l10n.roastMediumLight,
    RoastLevel.medium => l10n.roastMedium,
    RoastLevel.mediumDark => l10n.roastMediumDark,
    RoastLevel.dark => l10n.roastDark,
  };
}

/// The six cupping-score axes, in their canonical display order, each paired
/// with its localized label. Single source of truth shared by the tasting
/// notes input, the score radar chart and the shareable card, which previously
/// each hardcoded (and disagreed on) these strings.
List<String> tastingAxisLabels(AppLocalizations l10n) => [
  l10n.aroma,
  l10n.flavor,
  l10n.acidity,
  l10n.body,
  l10n.sweetness,
  l10n.aftertaste,
];

/// Resolves a *stored* brew-method value (new key or legacy English label) to
/// a localized display string. Convenience for display sites that hold the raw
/// persisted string (e.g. a `Tasting.brewMethod`) rather than the enum.
String brewMethodLabelFromStored(String? stored, AppLocalizations l10n) =>
    BrewMethod.fromStored(stored).displayLabel(l10n);

/// Same as [brewMethodLabelFromStored] but for grind size.
String grindSizeLabelFromStored(String? stored, AppLocalizations l10n) =>
    GrindSize.fromStored(stored).displayLabel(l10n);

extension FlavorFamilyL10n on FlavorFamily {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    FlavorFamily.fruity => l10n.flavorFruity,
    FlavorFamily.sourFermented => l10n.flavorSourFermented,
    FlavorFamily.greenVegetative => l10n.flavorGreenVegetative,
    FlavorFamily.roasted => l10n.flavorRoasted,
    FlavorFamily.spices => l10n.flavorSpices,
    FlavorFamily.nuttyCocoa => l10n.flavorNuttyCocoa,
    FlavorFamily.sweet => l10n.flavorSweet,
    FlavorFamily.floral => l10n.flavorFloral,
    FlavorFamily.other => l10n.flavorOther,
  };
}
