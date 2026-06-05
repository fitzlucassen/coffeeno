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
  DateTime? createdAt,
}) async {
  await firestore.collection('coffees').add({
    'name': name,
    'roaster': 'R',
    'originCountry': originCountry,
    'avgRating': avgRating,
    'ratingsCount': ratingsCount,
    'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ExploreRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = ExploreRepository(firestore: firestore);
  });

  test('getTrendingCoffees excludes unrated and orders by ratingsCount',
      () async {
    await _seedCoffee(firestore, name: 'Hot', ratingsCount: 10, avgRating: 4);
    await _seedCoffee(firestore, name: 'Warm', ratingsCount: 3, avgRating: 4);
    await _seedCoffee(firestore, name: 'Cold', ratingsCount: 0, avgRating: 0);

    final result = await repo.getTrendingCoffees();
    expect(result.map((c) => c.name), ['Hot', 'Warm']);
  });

  test('getRecentlyAdded orders by createdAt descending', () async {
    await _seedCoffee(firestore, name: 'Old', createdAt: DateTime(2026, 1, 1));
    await _seedCoffee(firestore, name: 'New', createdAt: DateTime(2026, 6, 1));

    final result = await repo.getRecentlyAdded();
    expect(result.first.name, 'New');
  });

  test('getTopRated requires at least 3 ratings', () async {
    await _seedCoffee(firestore, name: 'Established', ratingsCount: 3, avgRating: 4.8);
    await _seedCoffee(firestore, name: 'TooFew', ratingsCount: 2, avgRating: 5.0);

    final result = await repo.getTopRated();
    expect(result.map((c) => c.name), ['Established']);
  });

  test('getPopularNearMe filters by country and excludes unrated', () async {
    await _seedCoffee(firestore,
        name: 'Local', originCountry: 'France', ratingsCount: 2, avgRating: 4);
    await _seedCoffee(firestore,
        name: 'Foreign', originCountry: 'Brazil', ratingsCount: 2, avgRating: 4);
    await _seedCoffee(firestore,
        name: 'LocalUnrated', originCountry: 'France', ratingsCount: 0);

    final result = await repo.getPopularNearMe('France');
    expect(result.map((c) => c.name), ['Local']);
  });

  test('respects the limit parameter', () async {
    for (var i = 0; i < 5; i++) {
      await _seedCoffee(firestore, name: 'C$i', ratingsCount: 2, avgRating: 4);
    }
    final result = await repo.getTrendingCoffees(limit: 2);
    expect(result.length, 2);
  });
}
