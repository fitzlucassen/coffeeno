import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/social/data/leaderboard_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _seedCoffee(
  FakeFirebaseFirestore firestore, {
  required String name,
  required double avgRating,
  required int ratingsCount,
  String originCountry = 'Ethiopia',
}) async {
  await firestore.collection('coffees').add({
    'name': name,
    'roaster': 'R',
    'originCountry': originCountry,
    'avgRating': avgRating,
    'ratingsCount': ratingsCount,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
  });
}

void main() {
  late FakeFirebaseFirestore firestore;
  late LeaderboardRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = LeaderboardRepository(firestore: firestore);
  });

  test('excludes coffees with no ratings', () async {
    await _seedCoffee(firestore, name: 'Rated', avgRating: 4.0, ratingsCount: 2);
    await _seedCoffee(firestore, name: 'Unrated', avgRating: 0, ratingsCount: 0);

    final entries = await repo.getGlobalLeaderboard().first;
    expect(entries.map((e) => e.coffeeName), ['Rated']);
  });

  test('Bayesian sort keeps a thinly-rated 5.0 below a heavily-rated 4.5',
      () async {
    // The prior pulls a 1-vote 5.0 toward the global mean. With a low global
    // mean (dragged down by the 2.0 filler), the single 5.0 is dampened below
    // the heavily-rated 4.5, which barely moves. Without the Bayesian weight a
    // raw avgRating sort would (wrongly) rank the 5.0 first.
    await _seedCoffee(
        firestore, name: 'OneFiveStar', avgRating: 5.0, ratingsCount: 1);
    await _seedCoffee(
        firestore, name: 'ManyFourHalf', avgRating: 4.5, ratingsCount: 50);
    await _seedCoffee(
        firestore, name: 'Filler', avgRating: 2.0, ratingsCount: 100);

    final entries = await repo.getGlobalLeaderboard().first;
    final names = entries.map((e) => e.coffeeName).toList();
    expect(names.indexOf('ManyFourHalf'), lessThan(names.indexOf('OneFiveStar')),
        reason: 'heavily-rated 4.5 should outrank the dampened 1-vote 5.0');
  });

  test('getLeaderboardByOrigin filters to the requested country', () async {
    await _seedCoffee(firestore,
        name: 'Eth', avgRating: 4.0, ratingsCount: 5, originCountry: 'Ethiopia');
    await _seedCoffee(firestore,
        name: 'Col', avgRating: 4.0, ratingsCount: 5, originCountry: 'Colombia');

    final entries =
        await repo.getLeaderboardByOrigin(originCountry: 'Ethiopia').first;
    expect(entries.map((e) => e.coffeeName), ['Eth']);
  });

  test('respects the limit parameter', () async {
    for (var i = 0; i < 5; i++) {
      await _seedCoffee(firestore,
          name: 'C$i', avgRating: 4.0, ratingsCount: 3);
    }
    final entries = await repo.getGlobalLeaderboard(limit: 2).first;
    expect(entries.length, 2);
  });
}
