import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/map/data/map_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Seeds one coffee doc with the given origin + rating.
Future<void> _seedCoffee(
  FakeFirebaseFirestore firestore, {
  required String origin,
  required double rating,
}) async {
  await firestore.collection('coffees').add({
    'originCountry': origin,
    'avgRating': rating,
    'ratingsCount': 1,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MapRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = MapRepository(firestore: firestore);
  });

  test('getOriginStats groups coffees by country and sorts by count', () async {
    await _seedCoffee(firestore, origin: 'Ethiopia', rating: 4.5);
    await _seedCoffee(firestore, origin: 'Ethiopia', rating: 4.0);
    await _seedCoffee(firestore, origin: 'Ethiopia', rating: 3.5);
    await _seedCoffee(firestore, origin: 'Colombia', rating: 4.0);

    final stats = await repo.getOriginStats().first;
    expect(stats.length, 2);
    expect(stats.first.country, 'Ethiopia');
    expect(stats.first.coffeeCount, 3);
    expect(stats.first.avgRating, closeTo(4.0, 0.0001));
  });

  test('getOriginStats ignores coffees with no origin', () async {
    await _seedCoffee(firestore, origin: 'Ethiopia', rating: 4.5);

    final stats = await repo.getOriginStats().first;
    expect(stats.map((s) => s.country), ['Ethiopia']);
  });

  test(
    'global stats include docs even when originCountry field is absent',
    () async {
      // A legacy/partial doc with no originCountry field at all must not be
      // dropped by a server-side filter — it's simply skipped client-side while
      // valid docs are still counted. (Regression guard for the previous
      // `isNotEqualTo: ''` filter, which excluded missing fields entirely.)
      await firestore.collection('coffees').add({
        'avgRating': 3.0,
        'ratingsCount': 1,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      await _seedCoffee(firestore, origin: 'Colombia', rating: 4.0);

      final stats = await repo.getOriginStats().first;
      expect(stats.map((s) => s.country), ['Colombia']);
    },
  );

  test(
    'getOriginStats scoped to a uid only counts that user\'s coffees',
    () async {
      await firestore.collection('coffees').add({
        'uid': 'me',
        'originCountry': 'Kenya',
        'avgRating': 4.0,
        'ratingsCount': 1,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      await firestore.collection('coffees').add({
        'uid': 'other',
        'originCountry': 'Brazil',
        'avgRating': 3.0,
        'ratingsCount': 1,
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      final stats = await repo.getOriginStats(uid: 'me').first;
      expect(stats.map((s) => s.country), ['Kenya']);
    },
  );
}
