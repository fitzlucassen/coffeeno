enum BrewMethod {
  v60('V60'),
  espresso('Espresso'),
  aeropress('AeroPress'),
  frenchPress('French Press'),
  chemex('Chemex'),
  mokaPot('Moka Pot'),
  coldBrew('Cold Brew'),
  sipho('Siphon'),
  turkishCoffee('Turkish Coffee'),
  pourOver('Pour Over (Other)'),
  other('Other');

  const BrewMethod(this.label);
  final String label;
}

enum GrindSize {
  extraFine('Extra Fine'),
  fine('Fine'),
  mediumFine('Medium-Fine'),
  medium('Medium'),
  mediumCoarse('Medium-Coarse'),
  coarse('Coarse'),
  extraCoarse('Extra Coarse');

  const GrindSize(this.label);
  final String label;
}

enum ProcessingMethod {
  washed('Washed'),
  natural('Natural'),
  honey('Honey'),
  anaerobic('Anaerobic'),
  wetHulled('Wet Hulled'),
  experimental('Experimental'),
  other('Other');

  const ProcessingMethod(this.label);
  final String label;
}

enum RoastLevel {
  light('Light'),
  mediumLight('Medium-Light'),
  medium('Medium'),
  mediumDark('Medium-Dark'),
  dark('Dark');

  const RoastLevel(this.label);
  final String label;
}

abstract final class AppConstants {
  static const maxRating = 5.0;
  static const ratingStep = 0.5;
  static const maxTastingScore = 5;
  static const feedPageSize = 20;
  static const libraryPageSize = 30;
  static const leaderboardSize = 50;

  static const freeTierMaxCoffees = 10;
  static const freeTierMaxTastingsPerMonth = 3;
}
