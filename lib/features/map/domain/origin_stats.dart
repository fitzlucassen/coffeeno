class OriginStats {
  const OriginStats({
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.coffeeCount,
    required this.avgRating,
  });

  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;
  final int coffeeCount;
  final double avgRating;

  /// Known coffee-producing countries with their approximate center coordinates.
  static const Map<String, ({String code, double lat, double lng})>
      knownOrigins = {
    'ethiopia': (code: 'ET', lat: 9.145, lng: 40.489),
    'colombia': (code: 'CO', lat: 4.571, lng: -74.297),
    'brazil': (code: 'BR', lat: -14.235, lng: -51.925),
    'kenya': (code: 'KE', lat: -0.024, lng: 37.906),
    'guatemala': (code: 'GT', lat: 15.784, lng: -90.231),
    'costa rica': (code: 'CR', lat: 9.749, lng: -83.754),
    'indonesia': (code: 'ID', lat: -0.790, lng: 113.921),
    'vietnam': (code: 'VN', lat: 14.058, lng: 108.277),
    'honduras': (code: 'HN', lat: 15.200, lng: -86.242),
    'peru': (code: 'PE', lat: -9.190, lng: -75.015),
    'mexico': (code: 'MX', lat: 23.635, lng: -102.553),
    'rwanda': (code: 'RW', lat: -1.940, lng: 29.874),
    'burundi': (code: 'BI', lat: -3.373, lng: 29.919),
    'tanzania': (code: 'TZ', lat: -6.369, lng: 34.889),
    'uganda': (code: 'UG', lat: 1.373, lng: 32.290),
    'india': (code: 'IN', lat: 12.972, lng: 77.580),
    'yemen': (code: 'YE', lat: 15.553, lng: 48.516),
    'panama': (code: 'PA', lat: 8.538, lng: -80.782),
    'el salvador': (code: 'SV', lat: 13.795, lng: -88.897),
    'nicaragua': (code: 'NI', lat: 12.866, lng: -85.207),
    'jamaica': (code: 'JM', lat: 18.110, lng: -77.297),
    'usa': (code: 'US', lat: 19.896, lng: -155.582),
    'papua new guinea': (code: 'PG', lat: -6.315, lng: 143.956),
    'myanmar': (code: 'MM', lat: 21.914, lng: 95.956),
    'thailand': (code: 'TH', lat: 15.870, lng: 100.993),
    'laos': (code: 'LA', lat: 19.856, lng: 102.495),
    'china': (code: 'CN', lat: 25.042, lng: 102.710),
    'democratic republic of congo': (code: 'CD', lat: -4.038, lng: 21.759),
    'congo': (code: 'CD', lat: -4.038, lng: 21.759),
    'ivory coast': (code: 'CI', lat: 7.540, lng: -5.548),
    'philippines': (code: 'PH', lat: 12.879, lng: 121.774),
    'hawaii': (code: 'US', lat: 19.896, lng: -155.582),
    'dominican republic': (code: 'DO', lat: 18.736, lng: -70.163),
    'cuba': (code: 'CU', lat: 21.521, lng: -77.781),
    'ecuador': (code: 'EC', lat: -1.831, lng: -78.183),
    'bolivia': (code: 'BO', lat: -16.290, lng: -63.588),
    'cameroon': (code: 'CM', lat: 7.370, lng: 12.354),
    'malawi': (code: 'MW', lat: -13.254, lng: 34.302),
    'zambia': (code: 'ZM', lat: -13.134, lng: 27.849),
    'zimbabwe': (code: 'ZW', lat: -19.015, lng: 29.155),
    'nepal': (code: 'NP', lat: 28.394, lng: 84.124),
  };

  /// Aliases: French and other common alternate names → canonical lowercase key.
  static const Map<String, String> _aliases = {
    'éthiopie': 'ethiopia',
    'ethiopie': 'ethiopia',
    'colombie': 'colombia',
    'brésil': 'brazil',
    'bresil': 'brazil',
    'inde': 'india',
    'mexique': 'mexico',
    'pérou': 'peru',
    'perou': 'peru',
    'tanzanie': 'tanzania',
    'ouganda': 'uganda',
    'yémen': 'yemen',
    'chine': 'china',
    'birmanie': 'myanmar',
    'thaïlande': 'thailand',
    'thailande': 'thailand',
    'indonésie': 'indonesia',
    'indonesie': 'indonesia',
    'papouasie-nouvelle-guinée': 'papua new guinea',
    'papouasie nouvelle guinée': 'papua new guinea',
    'papouasie nouvelle guinee': 'papua new guinea',
    'jamaïque': 'jamaica',
    'jamaique': 'jamaica',
    'salvador': 'el salvador',
    'états-unis': 'usa',
    'etats-unis': 'usa',
    'united states': 'usa',
    'côte d\'ivoire': 'ivory coast',
    'cote d\'ivoire': 'ivory coast',
    'république démocratique du congo': 'democratic republic of congo',
    'republique democratique du congo': 'democratic republic of congo',
    'rdc': 'democratic republic of congo',
    'drc': 'democratic republic of congo',
    'cameroun': 'cameroon',
    'équateur': 'ecuador',
    'equateur': 'ecuador',
    'bolivie': 'bolivia',
    'république dominicaine': 'dominican republic',
    'republique dominicaine': 'dominican republic',
    'népal': 'nepal',
    'philippines': 'philippines',
    'zambie': 'zambia',
    'vietnam': 'vietnam',
    'viêt nam': 'vietnam',
    'viet nam': 'vietnam',
  };

  /// Normalizes a country name to its canonical lowercase key.
  static String _normalize(String country) {
    final lower = country.trim().toLowerCase();
    return _aliases[lower] ?? lower;
  }

  /// Resolves coordinates from the known origins map, with a fallback of (0, 0).
  static OriginStats fromAggregation({
    required String country,
    required int coffeeCount,
    required double avgRating,
  }) {
    final normalized = _normalize(country);
    final known = knownOrigins[normalized];
    return OriginStats(
      country: country,
      countryCode: known?.code ?? '',
      latitude: known?.lat ?? 0,
      longitude: known?.lng ?? 0,
      coffeeCount: coffeeCount,
      avgRating: avgRating,
    );
  }
}
