import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/tasting/domain/tasting.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Tasting _base() => Tasting(
      id: '',
      userId: 'u1',
      coffeeId: 'c1',
      coffeeName: 'Sidama',
      roasterName: 'Blue Bottle',
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
      overallRating: 4.2,
      flavorNotes: const ['berry'],
      tastingDate: DateTime(2026, 4, 1),
      createdAt: DateTime(2026, 4, 1, 12),
    );

void main() {
  test('Tasting round-trips through Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final tasting = _base();

    final ref =
        await firestore.collection('tastings').add(tasting.toFirestore());
    final round = Tasting.fromFirestore(await ref.get());

    expect(round.coffeeName, 'Sidama');
    expect(round.overallRating, 4.2);
    expect(round.flavorNotes, ['berry']);
    expect(round.tastingDate, DateTime(2026, 4, 1));
  });

  test('Tasting defaults fields from a minimal doc', () async {
    final firestore = FakeFirebaseFirestore();
    final ref = await firestore.collection('tastings').add({
      'userId': 'u',
      'coffeeId': 'c',
      'coffeeName': 'n',
      'roasterName': 'r',
      'tastingDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    final t = Tasting.fromFirestore(await ref.get());

    expect(t.aroma, 3);
    expect(t.flavor, 3);
    expect(t.overallRating, 0.0);
    expect(t.flavorNotes, isEmpty);
  });

  test('copyWith replaces only given fields', () {
    final t = _base();
    final updated = t.copyWith(overallRating: 5.0);
    expect(updated.overallRating, 5.0);
    expect(updated.aroma, t.aroma);
  });

  test('equality uses content, not identity', () {
    expect(_base(), _base());
  });
}
