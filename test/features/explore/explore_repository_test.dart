import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/explore/data/explore_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _seedCoffee(
  FakeFirebaseFirestore firestore, {
  required String name,
  double avgRating = 0,
  int ratingsCount = 0,
  String originCountry = 'Ethiopia',
  String? roasterId,
  DateTime? createdAt,
}) async {
  await firestore.collection('coffees').add({
    'name': name,
    'roaster': 'R',
    'roasterId': roasterId,
    'originCountry': originCountry,
    'avgRating': avgRating,
    'ratingsCount': ratingsCount,
    'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
  });
}

Future<void> _seedRoaster(
  FakeFirebaseFirestore firestore, {
  required String id,
  required String country,
}) async {
  await firestore.collection('roasters').doc(id).set({
    'name': id,
    'country': country,
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ExploreRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = ExploreRepository(firestore: firestore);
  });

  test(
    'getTrendingCoffees excludes unrated and orders by ratingsCount',
    () async {
      await _seedCoffee(firestore, name: 'Hot', ratingsCount: 10, avgRating: 4);
      await _seedCoffee(firestore, name: 'Warm', ratingsCount: 3, avgRating: 4);
      await _seedCoffee(firestore, name: 'Cold', ratingsCount: 0, avgRating: 0);

      final result = await repo.getTrendingCoffees();
      expect(result.map((c) => c.name), ['Hot', 'Warm']);
    },
  );

  test('getRecentlyAdded orders by createdAt descending', () async {
    await _seedCoffee(firestore, name: 'Old', createdAt: DateTime(2026, 1, 1));
    await _seedCoffee(firestore, name: 'New', createdAt: DateTime(2026, 6, 1));

    final result = await repo.getRecentlyAdded();
    expect(result.first.name, 'New');
  });

  test('getTopRated requires at least 3 ratings', () async {
    await _seedCoffee(
      firestore,
      name: 'Established',
      ratingsCount: 3,
      avgRating: 4.8,
    );
    await _seedCoffee(
      firestore,
      name: 'TooFew',
      ratingsCount: 2,
      avgRating: 5.0,
    );

    final result = await repo.getTopRated();
    expect(result.map((c) => c.name), ['Established']);
  });

  test(
    'getPopularNearMe returns rated coffees from roasters in the country',
    () async {
      await _seedRoaster(firestore, id: 'fr_roaster', country: 'France');
      await _seedRoaster(firestore, id: 'br_roaster', country: 'Brazil');

      await _seedCoffee(
        firestore,
        name: 'Local',
        roasterId: 'fr_roaster',
        ratingsCount: 2,
        avgRating: 4,
      );
      await _seedCoffee(
        firestore,
        name: 'Foreign',
        roasterId: 'br_roaster',
        ratingsCount: 2,
        avgRating: 4,
      );
      await _seedCoffee(
        firestore,
        name: 'LocalUnrated',
        roasterId: 'fr_roaster',
        ratingsCount: 0,
      );

      final result = await repo.getPopularNearMe('France');
      expect(result.map((c) => c.name), ['Local']);
    },
  );

  test(
    'getPopularNearMe returns empty when no roaster is in the country',
    () async {
      await _seedRoaster(firestore, id: 'br_roaster', country: 'Brazil');
      await _seedCoffee(
        firestore,
        name: 'Foreign',
        roasterId: 'br_roaster',
        ratingsCount: 2,
        avgRating: 4,
      );

      expect(await repo.getPopularNearMe('France'), isEmpty);
    },
  );

  test('respects the limit parameter', () async {
    for (var i = 0; i < 5; i++) {
      await _seedCoffee(firestore, name: 'C$i', ratingsCount: 2, avgRating: 4);
    }
    final result = await repo.getTrendingCoffees(limit: 2);
    expect(result.length, 2);
  });
}
