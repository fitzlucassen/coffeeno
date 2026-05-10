import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:coffeeno/features/roaster/data/roaster_stats_repository.dart';
import 'package:coffeeno/features/roaster/domain/roaster_stats.dart';
import 'package:coffeeno/features/tasting/domain/tasting.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Coffee _coffee({
  required String id,
  String roasterId = 'r1',
  double avgRating = 0,
  int ratingsCount = 0,
}) =>
    Coffee(
      id: id,
      uid: 'u1',
      roaster: 'ACME',
      name: 'Coffee $id',
      originCountry: 'Ethiopia',
      roasterId: roasterId,
      avgRating: avgRating,
      ratingsCount: ratingsCount,
      createdAt: DateTime(2026, 1, 1),
    );

Tasting _tasting({
  required String coffeeId,
  required DateTime createdAt,
  double overallRating = 4.0,
  String userId = 'u2',
}) =>
    Tasting(
      id: '',
      userId: userId,
      coffeeId: coffeeId,
      coffeeName: 'Coffee $coffeeId',
      roasterName: 'ACME',
      brewMethod: 'V60',
      grindSize: 'medium',
      doseGrams: 15,
      waterMl: 250,
      ratio: '1:16.7',
      brewTimeSec: 180,
      aroma: 4,
      flavor: 4,
      acidity: 3,
      body: 4,
      sweetness: 4,
      aftertaste: 3,
      overallRating: overallRating,
      tastingDate: createdAt,
      createdAt: createdAt,
    );

Future<String> _seedCoffee(
    FakeFirebaseFirestore firestore, Coffee coffee) async {
  final ref = await firestore.collection('coffees').add(coffee.toFirestore());
  return ref.id;
}

Future<void> _seedTasting(
    FakeFirebaseFirestore firestore, Tasting tasting) async {
  await firestore.collection('tastings').add(tasting.toFirestore());
}

void main() {
  late FakeFirebaseFirestore firestore;
  late RoasterStatsRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = RoasterStatsRepository(firestore: firestore);
  });

  group('getRecentTastingsForRoaster', () {
    test('returns tastings for this roaster\'s coffees, newest first',
        () async {
      final c1 = await _seedCoffee(firestore, _coffee(id: 'x'));
      final c2 = await _seedCoffee(firestore, _coffee(id: 'y'));
      // Different roaster — must be excluded.
      final c3 = await _seedCoffee(
          firestore, _coffee(id: 'z', roasterId: 'r2'));

      await _seedTasting(
          firestore, _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 1)));
      await _seedTasting(
          firestore, _tasting(coffeeId: c2, createdAt: DateTime(2026, 5, 5)));
      await _seedTasting(
          firestore, _tasting(coffeeId: c3, createdAt: DateTime(2026, 5, 10)));

      final results = await repo.getRecentTastingsForRoaster('r1');
      expect(results.length, 2);
      expect(results.first.createdAt.isAfter(results.last.createdAt), isTrue);
    });

    test('returns empty list when the roaster has no coffees', () async {
      final results = await repo.getRecentTastingsForRoaster('ghost');
      expect(results, isEmpty);
    });
  });

  group('getTimeseriesForRoaster', () {
    test('30-day period returns 30 daily buckets', () async {
      final now = DateTime(2026, 5, 10);
      await _seedCoffee(firestore, _coffee(id: 'x'));
      final points = await repo.getTimeseriesForRoaster(
        'r1',
        period: StatsPeriod.last30Days,
        now: now,
      );
      expect(points.length, 30);
    });

    test('12-month period returns 12 monthly buckets', () async {
      final now = DateTime(2026, 5, 10);
      await _seedCoffee(firestore, _coffee(id: 'x'));
      final points = await repo.getTimeseriesForRoaster(
        'r1',
        period: StatsPeriod.last12Months,
        now: now,
      );
      expect(points.length, 12);
    });

    test('tastings are attributed to the correct bucket', () async {
      final now = DateTime(2026, 5, 10);
      final c1 = await _seedCoffee(firestore, _coffee(id: 'x'));
      await _seedTasting(firestore,
          _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 10)));
      await _seedTasting(firestore,
          _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 10)));
      await _seedTasting(firestore,
          _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 5)));

      final points = await repo.getTimeseriesForRoaster(
        'r1',
        period: StatsPeriod.last30Days,
        now: now,
      );
      // Last bucket = today.
      expect(points.last.tastingsCount, 2);
      final fifthMay = points.firstWhere((p) =>
          p.date.year == 2026 && p.date.month == 5 && p.date.day == 5);
      expect(fifthMay.tastingsCount, 1);
    });

    test('empty roaster still returns a stable number of buckets', () async {
      final now = DateTime(2026, 5, 10);
      final points = await repo.getTimeseriesForRoaster(
        'ghost',
        period: StatsPeriod.last3Months,
        now: now,
      );
      expect(points.length, 13);
      expect(points.every((p) => p.tastingsCount == 0), isTrue);
    });
  });

  group('buildRoasterExportCsv', () {
    test('produces a CSV with a header row and one row per tasting',
        () async {
      final c1 = await _seedCoffee(firestore, _coffee(id: 'x'));
      await _seedTasting(firestore,
          _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 1)));
      await _seedTasting(firestore,
          _tasting(coffeeId: c1, createdAt: DateTime(2026, 5, 2)));

      final csv = await repo.buildRoasterExportCsv('r1');
      final lines = csv.trim().split('\n');
      expect(lines.first, startsWith('coffee,date,rating,method'));
      expect(lines.length, 3); // header + 2 tastings
    });

    test('escapes commas in coffee names', () async {
      final ref = await firestore.collection('coffees').add({
        'uid': 'u1',
        'roaster': 'ACME',
        'name': 'Hello, world',
        'originCountry': 'Ethiopia',
        'roasterId': 'r1',
        'avgRating': 0,
        'ratingsCount': 0,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      await _seedTasting(firestore,
          _tasting(coffeeId: ref.id, createdAt: DateTime(2026, 5, 1)));

      final csv = await repo.buildRoasterExportCsv('r1');
      expect(csv, contains('"Hello, world"'));
    });

    test('returns just the header when the roaster has no coffees',
        () async {
      final csv = await repo.buildRoasterExportCsv('ghost');
      expect(csv.trim().split('\n').length, 1);
      expect(csv, startsWith('coffee,date'));
    });
  });
}
