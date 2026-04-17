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
    'Ethiopia': (code: 'ET', lat: 9.145, lng: 40.489),
    'Colombia': (code: 'CO', lat: 4.571, lng: -74.297),
    'Brazil': (code: 'BR', lat: -14.235, lng: -51.925),
    'Kenya': (code: 'KE', lat: -0.024, lng: 37.906),
    'Guatemala': (code: 'GT', lat: 15.784, lng: -90.231),
    'Costa Rica': (code: 'CR', lat: 9.749, lng: -83.754),
    'Indonesia': (code: 'ID', lat: -0.790, lng: 113.921),
    'Vietnam': (code: 'VN', lat: 14.058, lng: 108.277),
    'Honduras': (code: 'HN', lat: 15.200, lng: -86.242),
    'Peru': (code: 'PE', lat: -9.190, lng: -75.015),
    'Mexico': (code: 'MX', lat: 23.635, lng: -102.553),
    'Rwanda': (code: 'RW', lat: -1.940, lng: 29.874),
    'Burundi': (code: 'BI', lat: -3.373, lng: 29.919),
    'Tanzania': (code: 'TZ', lat: -6.369, lng: 34.889),
    'Uganda': (code: 'UG', lat: 1.373, lng: 32.290),
    'India': (code: 'IN', lat: 12.972, lng: 77.580),
    'Yemen': (code: 'YE', lat: 15.553, lng: 48.516),
    'Panama': (code: 'PA', lat: 8.538, lng: -80.782),
    'El Salvador': (code: 'SV', lat: 13.795, lng: -88.897),
    'Nicaragua': (code: 'NI', lat: 12.866, lng: -85.207),
    'Jamaica': (code: 'JM', lat: 18.110, lng: -77.297),
    'USA': (code: 'US', lat: 19.896, lng: -155.582), // Hawaii
    'Papua New Guinea': (code: 'PG', lat: -6.315, lng: 143.956),
    'Myanmar': (code: 'MM', lat: 21.914, lng: 95.956),
    'Thailand': (code: 'TH', lat: 15.870, lng: 100.993),
    'Laos': (code: 'LA', lat: 19.856, lng: 102.495),
    'China': (code: 'CN', lat: 25.042, lng: 102.710), // Yunnan
  };

  /// Resolves coordinates from the known origins map, with a fallback of (0, 0).
  static OriginStats fromAggregation({
    required String country,
    required int coffeeCount,
    required double avgRating,
  }) {
    final known = knownOrigins[country];
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
