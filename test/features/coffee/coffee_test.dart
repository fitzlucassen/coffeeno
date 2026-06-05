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

    // The label is derived from peakEndDays (single source of truth shared with
    // the notification scheduler). For a medium/unknown roast peakEndDays = 18,
    // so: resting < 4 (18~/4), peak <= 18, use soon <= 32 (peakEnd + 14),
    // past peak afterwards.
    group('medium/unknown roast (peakEndDays = 18)', () {
      test('resting before the first quarter', () {
        expect(withRoastDaysAgo(3).freshnessLabel, 'Resting');
      });

      test('peak up to and including peakEndDays', () {
        expect(withRoastDaysAgo(4).freshnessLabel, 'Peak freshness');
        expect(withRoastDaysAgo(16).freshnessLabel, 'Peak freshness');
        expect(withRoastDaysAgo(18).freshnessLabel, 'Peak freshness');
      });

      test('use soon within the 14-day grace window past peak', () {
        expect(withRoastDaysAgo(19).freshnessLabel, 'Use soon');
        expect(withRoastDaysAgo(32).freshnessLabel, 'Use soon');
      });

      test('past peak after the grace window', () {
        expect(withRoastDaysAgo(33).freshnessLabel, 'Past peak');
        expect(withRoastDaysAgo(40).freshnessLabel, 'Past peak');
      });
    });

    // The label must track the roast-level-dependent window, not a fixed one:
    // a dark roast (peakEndDays = 14) leaves peak earlier than a light roast
    // (peakEndDays = 21) for the same number of days since roast.
    test('tracks roast level: same day, different labels', () {
      expect(withRoastDaysAgo(16, level: 'Dark').freshnessLabel, 'Use soon');
      expect(
          withRoastDaysAgo(16, level: 'Light').freshnessLabel, 'Peak freshness');
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
