import 'package:coffeeno/features/coffee/data/coffee_repository.dart';
import 'package:coffeeno/features/coffee/domain/coffee.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Coffee _coffee({
  String uid = 'u',
  String roaster = 'R',
  String name = 'N',
  String originCountry = 'Ethiopia',
  String? roasterId,
  String? farmId,
  double avgRating = 0,
  int ratingsCount = 0,
  DateTime? createdAt,
}) =>
    Coffee(
      id: '',
      uid: uid,
      roaster: roaster,
      name: name,
      originCountry: originCountry,
      roasterId: roasterId,
      farmId: farmId,
      avgRating: avgRating,
      ratingsCount: ratingsCount,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late CoffeeRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = CoffeeRepository(firestore: firestore);
  });

  test('addCoffee returns the new document id and persists the doc', () async {
    final id = await repo.addCoffee(_coffee());
    expect(id, isNotEmpty);
    final doc = await firestore.collection('coffees').doc(id).get();
    expect(doc.exists, isTrue);
  });

  test('getCoffee returns null for missing id', () async {
    expect(await repo.getCoffee('nope'), isNull);
  });

  test('getCoffee returns a Coffee for an existing id', () async {
    final id = await repo.addCoffee(_coffee(name: 'Sidama'));
    final fetched = await repo.getCoffee(id);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'Sidama');
  });

  test('deleteCoffee removes the coffee and all its tastings', () async {
    final coffeeId = await repo.addCoffee(_coffee());
    // Seed two linked tastings and an unrelated one.
    await firestore.collection('tastings').add({'coffeeId': coffeeId});
    await firestore.collection('tastings').add({'coffeeId': coffeeId});
    await firestore.collection('tastings').add({'coffeeId': 'other'});

    await repo.deleteCoffee(coffeeId);

    expect((await firestore.collection('coffees').doc(coffeeId).get()).exists,
        isFalse);
    final remaining = await firestore.collection('tastings').get();
    expect(remaining.docs.length, 1);
    expect(remaining.docs.first.data()['coffeeId'], 'other');
  });

  test('getUserCoffees streams only that user\'s coffees', () async {
    await repo.addCoffee(_coffee(uid: 'a'));
    await repo.addCoffee(_coffee(uid: 'b'));
    await repo.addCoffee(_coffee(uid: 'a'));

    final list = await repo.getUserCoffees('a').first;
    expect(list.length, 2);
    expect(list.every((c) => c.uid == 'a'), isTrue);
  });

  test('countForUser uses a server-side count', () async {
    await repo.addCoffee(_coffee(uid: 'a'));
    await repo.addCoffee(_coffee(uid: 'a'));
    await repo.addCoffee(_coffee(uid: 'b'));

    expect(await repo.countForUser('a'), 2);
    expect(await repo.countForUser('b'), 1);
    expect(await repo.countForUser('ghost'), 0);
  });

  test('getCoffeesForRoaster filters by roasterId', () async {
    await repo.addCoffee(_coffee(roasterId: 'r1'));
    await repo.addCoffee(_coffee(roasterId: 'r1'));
    await repo.addCoffee(_coffee(roasterId: 'r2'));

    final list = await repo.getCoffeesForRoaster('r1').first;
    expect(list.length, 2);
    expect(list.every((c) => c.roasterId == 'r1'), isTrue);
  });

  test('getCoffeesForFarm filters by farmId', () async {
    await repo.addCoffee(_coffee(farmId: 'f1'));
    await repo.addCoffee(_coffee(farmId: 'f2'));

    final list = await repo.getCoffeesForFarm('f1').first;
    expect(list.length, 1);
  });

  test('getCommunityAverageRating averages only rated coffees for a pair',
      () async {
    await repo.addCoffee(_coffee(
      roaster: 'ACME',
      name: 'Honduras',
      avgRating: 4.0,
    ));
    await repo.addCoffee(_coffee(
      roaster: 'acme', // case-insensitive match
      name: 'HONDURAS',
      avgRating: 5.0,
    ));
    await repo.addCoffee(_coffee(
      roaster: 'acme',
      name: 'honduras',
      avgRating: 0, // unrated — ignored
    ));

    final result = await repo.getCommunityAverageRating('ACME', 'Honduras');
    expect(result, isNotNull);
    expect(result!.count, 2);
    expect(result.average, closeTo(4.5, 0.0001));
  });

  test('getCommunityAverageRating returns null when nothing matches',
      () async {
    final result = await repo.getCommunityAverageRating('ghost', 'none');
    expect(result, isNull);
  });
}
