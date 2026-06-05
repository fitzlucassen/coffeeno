import 'package:coffeeno/features/map/domain/origin_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OriginStats.fromAggregation', () {
    test('resolves coordinates for a known origin (case-insensitive)', () {
      final stats = OriginStats.fromAggregation(
        country: 'Ethiopia',
        coffeeCount: 3,
        avgRating: 4.2,
      );
      expect(stats.countryCode, 'ET');
      expect(stats.latitude, closeTo(9.145, 0.001));
      expect(stats.longitude, closeTo(40.489, 0.001));
      expect(stats.coffeeCount, 3);
      expect(stats.avgRating, 4.2);
    });

    test('preserves the original display country string', () {
      final stats = OriginStats.fromAggregation(
        country: 'ETHIOPIA',
        coffeeCount: 1,
        avgRating: 0,
      );
      // Display name is kept verbatim; only lookup is normalized.
      expect(stats.country, 'ETHIOPIA');
      expect(stats.countryCode, 'ET');
    });

    test('resolves French alias to the canonical origin', () {
      final stats = OriginStats.fromAggregation(
        country: 'Éthiopie',
        coffeeCount: 1,
        avgRating: 0,
      );
      expect(stats.countryCode, 'ET');
    });

    test('resolves multi-word alias (Brésil → Brazil)', () {
      final stats = OriginStats.fromAggregation(
        country: 'Brésil',
        coffeeCount: 1,
        avgRating: 0,
      );
      expect(stats.countryCode, 'BR');
    });

    test('falls back to empty code and (0,0) for an unknown country', () {
      final stats = OriginStats.fromAggregation(
        country: 'Atlantis',
        coffeeCount: 1,
        avgRating: 0,
      );
      expect(stats.countryCode, '');
      expect(stats.latitude, 0);
      expect(stats.longitude, 0);
    });

    test('trims surrounding whitespace before lookup', () {
      final stats = OriginStats.fromAggregation(
        country: '  Colombia  ',
        coffeeCount: 1,
        avgRating: 0,
      );
      expect(stats.countryCode, 'CO');
    });
  });
}
