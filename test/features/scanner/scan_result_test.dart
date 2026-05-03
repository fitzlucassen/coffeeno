import 'package:coffeeno/features/scanner/domain/scan_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanResult.fromJson', () {
    test('maps snake_case keys correctly', () {
      final result = ScanResult.fromJson({
        'roaster': 'Blue Bottle',
        'name': 'Sidama',
        'origin_country': 'Ethiopia',
        'origin_region': 'Sidama',
        'farm_name': 'Testi',
        'farmer_name': 'Yirgalem',
        'altitude': '2000m',
        'variety': 'Heirloom',
        'processing_method': 'Washed',
        'roast_date': '2026-03-01',
        'roast_level': 'Light',
        'flavor_notes': ['berry', 'floral'],
        'additional_info': 'extra',
      });

      expect(result.roaster, 'Blue Bottle');
      expect(result.originCountry, 'Ethiopia');
      expect(result.originRegion, 'Sidama');
      expect(result.farmName, 'Testi');
      expect(result.farmerName, 'Yirgalem');
      expect(result.flavorNotes, ['berry', 'floral']);
    });

    test('tolerates missing fields', () {
      final result = ScanResult.fromJson({});
      expect(result.roaster, isNull);
      expect(result.flavorNotes, isEmpty);
    });
  });

  group('ScanResult.fromJsonString', () {
    test('strips markdown code fences around JSON', () {
      const raw = '```json\n{"roaster": "ACME"}\n```';
      final result = ScanResult.fromJsonString(raw);
      expect(result.roaster, 'ACME');
    });

    test('parses plain JSON without fences', () {
      final result = ScanResult.fromJsonString('{"name": "Sidama"}');
      expect(result.name, 'Sidama');
    });
  });

  test('toJson is symmetric with fromJson for known fields', () {
    const original = ScanResult(
      roaster: 'R',
      name: 'N',
      originCountry: 'C',
      flavorNotes: ['a', 'b'],
      rawOcrText: '',
    );
    final round = ScanResult.fromJson(original.toJson());
    expect(round.roaster, original.roaster);
    expect(round.name, original.name);
    expect(round.originCountry, original.originCountry);
    expect(round.flavorNotes, original.flavorNotes);
  });

  test('copyWith replaces only the given fields', () {
    const original = ScanResult(roaster: 'A', rawOcrText: '');
    final updated = original.copyWith(roaster: 'B');
    expect(updated.roaster, 'B');
  });
}
