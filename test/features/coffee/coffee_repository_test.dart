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
}) => Coffee(
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

    expect(
      (await firestore.collection('coffees').doc(coffeeId).get()).exists,
      isFalse,
    );
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

  test(
    'getCommunityAverageRating averages only rated coffees for a pair',
    () async {
      await repo.addCoffee(
        _coffee(roaster: 'ACME', name: 'Honduras', avgRating: 4.0),
      );
      await repo.addCoffee(
        _coffee(
          roaster: 'acme', // case-insensitive match
          name: 'HONDURAS',
          avgRating: 5.0,
        ),
      );
      await repo.addCoffee(
        _coffee(
          roaster: 'acme',
          name: 'honduras',
          avgRating: 0, // unrated — ignored
        ),
      );

      final result = await repo.getCommunityAverageRating('ACME', 'Honduras');
      expect(result, isNotNull);
      expect(result!.count, 2);
      expect(result.average, closeTo(4.5, 0.0001));
    },
  );

  test('getCommunityAverageRating returns null when nothing matches', () async {
    final result = await repo.getCommunityAverageRating('ghost', 'none');
    expect(result, isNull);
  });

  group('findCanonicalMatchForUser', () {
    test('matches an existing coffee by roaster + name + origin', () async {
      await repo.addCoffee(
        _coffee(
          uid: 'me',
          roaster: 'Blue Bottle',
          name: 'Bella Donovan',
          originCountry: 'Ethiopia',
        ),
      );

      // Case/accent variations of the same coffee should still match.
      final match = await repo.findCanonicalMatchForUser(
        userId: 'me',
        roaster: 'blue bottle',
        name: 'BELLA DONOVAN',
        originCountry: 'Ethiopia',
      );
      expect(match, isNotNull);
      expect(match!.name, 'Bella Donovan');
    });

    test('does not match another user\'s coffee', () async {
      await repo.addCoffee(
        _coffee(
          uid: 'other',
          roaster: 'Blue Bottle',
          name: 'Bella Donovan',
          originCountry: 'Ethiopia',
        ),
      );

      final match = await repo.findCanonicalMatchForUser(
        userId: 'me',
        roaster: 'Blue Bottle',
        name: 'Bella Donovan',
        originCountry: 'Ethiopia',
      );
      expect(match, isNull);
    });

    test('does not match when origin differs', () async {
      await repo.addCoffee(
        _coffee(
          uid: 'me',
          roaster: 'R',
          name: 'Blend',
          originCountry: 'Ethiopia',
        ),
      );

      final match = await repo.findCanonicalMatchForUser(
        userId: 'me',
        roaster: 'R',
        name: 'Blend',
        originCountry: 'Colombia',
      );
      expect(match, isNull);
    });

    test('returns the most recently added match', () async {
      await repo.addCoffee(
        _coffee(
          uid: 'me',
          roaster: 'R',
          name: 'N',
          originCountry: 'Ethiopia',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      await repo.addCoffee(
        _coffee(
          uid: 'me',
          roaster: 'R',
          name: 'N',
          originCountry: 'Ethiopia',
          avgRating: 4.2,
          createdAt: DateTime(2026, 5, 1),
        ),
      );

      final match = await repo.findCanonicalMatchForUser(
        userId: 'me',
        roaster: 'R',
        name: 'N',
        originCountry: 'Ethiopia',
      );
      expect(match, isNotNull);
      expect(match!.avgRating, 4.2);
    });
  });

  group('communityOwnerCount', () {
    test('counts distinct owners of the same canonical coffee', () async {
      await repo.addCoffee(
        _coffee(uid: 'a', roaster: 'R', name: 'N', originCountry: 'Ethiopia'),
      );
      await repo.addCoffee(
        _coffee(uid: 'b', roaster: 'R', name: 'N', originCountry: 'Ethiopia'),
      );
      // Same user, second bag — still one owner.
      await repo.addCoffee(
        _coffee(uid: 'a', roaster: 'R', name: 'N', originCountry: 'Ethiopia'),
      );
      // Different coffee — excluded.
      await repo.addCoffee(
        _coffee(
          uid: 'c',
          roaster: 'R',
          name: 'Other',
          originCountry: 'Ethiopia',
        ),
      );

      final count = await repo.communityOwnerCount(
        roaster: 'R',
        name: 'N',
        originCountry: 'Ethiopia',
      );
      expect(count, 2);
    });

    test('returns zero when nobody owns it', () async {
      final count = await repo.communityOwnerCount(
        roaster: 'Ghost',
        name: 'None',
        originCountry: 'Nowhere',
      );
      expect(count, 0);
    });
  });

  group('searchCoffees', () {
    setUp(() async {
      await repo.addCoffee(_coffee(roaster: 'Blue Bottle', name: 'Kenya AA'));
      await repo.addCoffee(_coffee(roaster: 'Café Rémy', name: 'House Blend'));
      await repo.addCoffee(_coffee(roaster: 'Onyx', name: 'Geometry'));
    });

    test('matches a name prefix case-insensitively', () async {
      // Lowercase query must still match the mixed-case "Kenya AA" because the
      // query runs against the normalized field.
      final results = await repo.searchCoffees('kenya');
      expect(results.map((c) => c.name), contains('Kenya AA'));
    });

    test('matches a roaster prefix case-insensitively', () async {
      final results = await repo.searchCoffees('blue');
      expect(results.map((c) => c.roaster), contains('Blue Bottle'));
    });

    test('matches accent-insensitively via normalization', () async {
      // "Cafe Remy" (no accents) must find "Café Rémy".
      final results = await repo.searchCoffees('cafe');
      expect(results.map((c) => c.roaster), contains('Café Rémy'));
    });

    test('returns empty for a blank query', () async {
      expect(await repo.searchCoffees('   '), isEmpty);
    });

    test('does not match unrelated coffees', () async {
      final results = await repo.searchCoffees('kenya');
      expect(results.map((c) => c.name), isNot(contains('Geometry')));
    });
  });
}
