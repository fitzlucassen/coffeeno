import 'package:coffeeno/features/tasting/data/tasting_repository.dart';
import 'package:coffeeno/features/tasting/domain/tasting.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Tasting _tasting({
  String userId = 'u',
  String coffeeId = 'c',
  double overallRating = 4.0,
  DateTime? tastingDate,
}) =>
    Tasting(
      id: '',
      userId: userId,
      coffeeId: coffeeId,
      coffeeName: 'name',
      roasterName: 'r',
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
      tastingDate: tastingDate ?? DateTime(2026, 4, 1),
      createdAt: tastingDate ?? DateTime(2026, 4, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late TastingRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = TastingRepository(firestore: firestore);
  });

  test('addTasting updates the parent coffee avg rating atomically', () async {
    await firestore.collection('coffees').doc('c').set({
      'avgRating': 0.0,
      'ratingsCount': 0,
    });

    await repo.addTasting(_tasting(overallRating: 4.0));
    await repo.addTasting(_tasting(overallRating: 5.0));

    final coffee = await firestore.collection('coffees').doc('c').get();
    expect(coffee.data()!['ratingsCount'], 2);
    expect(coffee.data()!['avgRating'], closeTo(4.5, 0.0001));
  });

  test('deleteTasting decrements rating count and recomputes average',
      () async {
    await firestore.collection('coffees').doc('c').set({
      'avgRating': 4.5,
      'ratingsCount': 2,
    });
    final tastingId =
        await repo.addTasting(_tasting(overallRating: 4.5));
    // After add: ratingsCount=3, avgRating = (4.5*2 + 4.5)/3 = 4.5
    await repo.deleteTasting(tastingId);

    final coffee = await firestore.collection('coffees').doc('c').get();
    expect(coffee.data()!['ratingsCount'], 2);
    expect(coffee.data()!['avgRating'], closeTo(4.5, 0.0001));
  });

  test('deleteTasting is safe when the tasting does not exist', () async {
    await expectLater(repo.deleteTasting('missing'), completes);
  });

  test('countForUserInMonth counts only the current calendar month',
      () async {
    await firestore.collection('coffees').doc('c').set({
      'avgRating': 0.0,
      'ratingsCount': 0,
    });
    // 2 in March, 1 in February.
    await repo.addTasting(_tasting(tastingDate: DateTime(2026, 3, 2)));
    await repo.addTasting(_tasting(tastingDate: DateTime(2026, 3, 20)));
    await repo.addTasting(_tasting(tastingDate: DateTime(2026, 2, 28)));

    expect(await repo.countForUserInMonth('u', now: DateTime(2026, 3, 31)), 2);
    expect(await repo.countForUserInMonth('u', now: DateTime(2026, 2, 15)), 1);
    expect(await repo.countForUserInMonth('ghost', now: DateTime(2026, 3, 1)),
        0);
  });

  test('getTastingsForCoffee streams tastings for a single coffee', () async {
    await firestore.collection('coffees').doc('c1').set({
      'avgRating': 0.0,
      'ratingsCount': 0,
    });
    await firestore.collection('coffees').doc('c2').set({
      'avgRating': 0.0,
      'ratingsCount': 0,
    });

    await repo.addTasting(_tasting(coffeeId: 'c1'));
    await repo.addTasting(_tasting(coffeeId: 'c2'));

    final list = await repo.getTastingsForCoffee('c1').first;
    expect(list.length, 1);
    expect(list.first.coffeeId, 'c1');
  });

  test('getUserTastings streams only the owner\'s tastings', () async {
    await firestore.collection('coffees').doc('c').set({
      'avgRating': 0.0,
      'ratingsCount': 0,
    });
    await repo.addTasting(_tasting(userId: 'alice'));
    await repo.addTasting(_tasting(userId: 'bob'));

    final list = await repo.getUserTastings('alice').first;
    expect(list.length, 1);
    expect(list.first.userId, 'alice');
  });
}
