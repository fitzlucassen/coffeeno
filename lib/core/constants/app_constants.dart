/// Coffee brewing enums.
///
/// Each value carries a stable [key] that is what gets **persisted** (to
/// Firestore and used as a wire/storage identifier) and a legacy English
/// [label] that older documents stored directly. Display strings are localized
/// separately via `BrewMethodL10n` (see core/utils/enum_labels.dart); the
/// English [label] is retained only so `fromStored` can read pre-migration
/// documents that persisted the label instead of the key.
enum BrewMethod {
  v60('v60', 'V60'),
  espresso('espresso', 'Espresso'),
  aeropress('aeropress', 'AeroPress'),
  frenchPress('frenchPress', 'French Press'),
  chemex('chemex', 'Chemex'),
  mokaPot('mokaPot', 'Moka Pot'),
  coldBrew('coldBrew', 'Cold Brew'),
  siphon('siphon', 'Siphon'),
  turkishCoffee('turkishCoffee', 'Turkish Coffee'),
  pourOver('pourOver', 'Pour Over (Other)'),
  other('other', 'Other');

  const BrewMethod(this.key, this.label);

  /// Stable identifier persisted to storage.
  final String key;

  /// Legacy English label (pre-i18n). Only used for reading old documents.
  final String label;

  /// Resolves a stored value to an enum, accepting both the new [key] and the
  /// legacy English [label]. Falls back to [other] for unknown values.
  static BrewMethod fromStored(String? value) =>
      _enumFromStored(BrewMethod.values, value, BrewMethod.other);
}

enum GrindSize {
  extraFine('extraFine', 'Extra Fine'),
  fine('fine', 'Fine'),
  mediumFine('mediumFine', 'Medium-Fine'),
  medium('medium', 'Medium'),
  mediumCoarse('mediumCoarse', 'Medium-Coarse'),
  coarse('coarse', 'Coarse'),
  extraCoarse('extraCoarse', 'Extra Coarse');

  const GrindSize(this.key, this.label);

  final String key;
  final String label;

  static GrindSize fromStored(String? value) =>
      _enumFromStored(GrindSize.values, value, GrindSize.medium);
}

enum ProcessingMethod {
  washed('washed', 'Washed'),
  natural('natural', 'Natural'),
  honey('honey', 'Honey'),
  anaerobic('anaerobic', 'Anaerobic'),
  wetHulled('wetHulled', 'Wet Hulled'),
  experimental('experimental', 'Experimental'),
  other('other', 'Other');

  const ProcessingMethod(this.key, this.label);

  final String key;
  final String label;

  static ProcessingMethod fromStored(String? value) =>
      _enumFromStored(ProcessingMethod.values, value, ProcessingMethod.other);
}

enum RoastLevel {
  light('light', 'Light'),
  mediumLight('mediumLight', 'Medium-Light'),
  medium('medium', 'Medium'),
  mediumDark('mediumDark', 'Medium-Dark'),
  dark('dark', 'Dark');

  const RoastLevel(this.key, this.label);

  final String key;
  final String label;

  static RoastLevel fromStored(String? value) =>
      _enumFromStored(RoastLevel.values, value, RoastLevel.medium);
}

/// Shared resolver for the enum `fromStored` factories: matches a stored value
/// against each value's `key` first, then its legacy `label`, else [fallback].
T _enumFromStored<T extends Enum>(List<T> values, String? stored, T fallback) {
  if (stored == null) return fallback;
  for (final v in values) {
    final key = (v as dynamic).key as String;
    final label = (v as dynamic).label as String;
    if (key == stored || label == stored) return v;
  }
  return fallback;
}

/// Stable identifiers for the top-level SCA flavor families used for quick
/// taste-preference capture (e.g. onboarding). Persisted as-is; localized for
/// display via `flavorFamilyLabel` in core/utils/enum_labels.dart.
enum FlavorFamily {
  fruity('fruity'),
  sourFermented('sourFermented'),
  greenVegetative('greenVegetative'),
  roasted('roasted'),
  spices('spices'),
  nuttyCocoa('nuttyCocoa'),
  sweet('sweet'),
  floral('floral'),
  other('other');

  const FlavorFamily(this.key);

  final String key;
}

abstract final class AppConstants {
  static const maxRating = 5.0;
  static const ratingStep = 0.5;
  static const maxTastingScore = 5;
  static const feedPageSize = 20;
  static const libraryPageSize = 30;
  static const leaderboardSize = 50;

  static const freeTierMaxCoffees = 10;
  static const freeTierMaxTastingsPerMonth = 7;
}
