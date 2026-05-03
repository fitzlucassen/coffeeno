import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeText', () {
    test('strips accents and lowercases', () {
      expect(normalizeText('Café'), 'cafe');
      expect(normalizeText('ÉMILIE'), 'emilie');
      expect(normalizeText('Señor'), 'senor');
      expect(normalizeText('Ça'), 'ca');
    });

    test('trims whitespace', () {
      expect(normalizeText('  Coffee  '), 'coffee');
    });
  });

  group('Coffee serialization', () {
    late FakeFirebaseFirestore firestore;

    setUp(() => firestore = FakeFirebaseFirestore());

    test('round-trips through Firestore', () async {
      final createdAt = DateTime(2026, 3, 1);
      final roastDate = DateTime(2026, 2, 15);
      final coffee = Coffee(
        id: '',
        uid: 'u1',
        roaster: 'Blue Bottle',
        name: 'Ethiopia Sidama',
        originCountry: 'Ethiopia',
        roastDate: roastDate,
        roastLevel: 'Light',
        flavorNotes: const ['berry', 'floral'],
        avgRating: 4.2,
        ratingsCount: 5,
        createdAt: createdAt,
      );

      final ref =
          await firestore.collection('coffees').add(coffee.toFirestore());
      final round = Coffee.fromFirestore(await ref.get());

      expect(round.roaster, 'Blue Bottle');
      expect(round.name, 'Ethiopia Sidama');
      expect(round.flavorNotes, ['berry', 'floral']);
      expect(round.avgRating, 4.2);
      expect(round.roastDate, roastDate);
    });

    test('stores normalized roaster/name for case-insensitive search',
        () async {
      final coffee = Coffee(
        id: '',
        uid: 'u1',
        roaster: 'Café  Rémy',
        name: 'HOUSE Blend',
        originCountry: 'Colombia',
        createdAt: DateTime(2026, 3, 1),
      );

      final map = coffee.toFirestore();
      expect(map['roasterNormalized'], 'cafe  remy');
      expect(map['nameNormalized'], 'house blend');
    });

    test('defaults optional fields when absent', () async {
      final ref = await firestore.collection('coffees').add({
        'uid': 'u1',
        'roaster': 'R',
        'name': 'N',
        'originCountry': 'C',
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 1)),
      });
      final c = Coffee.fromFirestore(await ref.get());
      expect(c.flavorNotes, isEmpty);
      expect(c.avgRating, 0.0);
      expect(c.ratingsCount, 0);
      expect(c.freshnessNotified, isFalse);
    });
  });

  group('Coffee.freshnessLabel', () {
    Coffee withRoastDaysAgo(int days, {String? level}) => Coffee(
          id: '',
          uid: 'u',
          roaster: 'r',
          name: 'n',
          originCountry: 'c',
          roastDate: DateTime.now().subtract(Duration(days: days)),
          roastLevel: level,
          createdAt: DateTime.now(),
        );

    test('returns null when roast date is unknown', () {
      final c = Coffee(
        id: '',
        uid: 'u',
        roaster: 'r',
        name: 'n',
        originCountry: 'c',
        createdAt: DateTime.now(),
      );
      expect(c.freshnessLabel, isNull);
      expect(c.daysSinceRoast, isNull);
    });

    test('resting (< 5 days)', () {
      expect(withRoastDaysAgo(3).freshnessLabel, 'Resting');
    });

    test('peak (5..14 days)', () {
      expect(withRoastDaysAgo(7).freshnessLabel, 'Peak freshness');
      expect(withRoastDaysAgo(14).freshnessLabel, 'Peak freshness');
    });

    test('use soon (15..28 days)', () {
      expect(withRoastDaysAgo(20).freshnessLabel, 'Use soon');
      expect(withRoastDaysAgo(28).freshnessLabel, 'Use soon');
    });

    test('past peak (> 28 days)', () {
      expect(withRoastDaysAgo(40).freshnessLabel, 'Past peak');
    });
  });

  group('Coffee.peakEndDays', () {
    Coffee withLevel(String? level) => Coffee(
          id: '',
          uid: 'u',
          roaster: 'r',
          name: 'n',
          originCountry: 'c',
          roastLevel: level,
          createdAt: DateTime.now(),
        );

    test('light roast peaks later', () {
      expect(withLevel('Light').peakEndDays, 21);
    });

    test('dark roast peaks earlier', () {
      expect(withLevel('Dark').peakEndDays, 14);
    });

    test('medium/unknown defaults to 18', () {
      expect(withLevel('Medium').peakEndDays, 18);
      expect(withLevel(null).peakEndDays, 18);
    });
  });
}
