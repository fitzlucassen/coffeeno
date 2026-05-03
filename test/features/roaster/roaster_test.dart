import 'package:coffeeno/features/roaster/domain/roaster.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Roaster round-trips through Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final roaster = Roaster(
      id: '',
      name: 'ACME Roasters',
      country: 'FR',
      claimedBy: 'u1',
      claimStatus: 'approved',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );
    final ref =
        await firestore.collection('roasters').add(roaster.toFirestore());
    final round = Roaster.fromFirestore(await ref.get());

    expect(round.name, 'ACME Roasters');
    expect(round.country, 'FR');
    expect(round.claimedBy, 'u1');
    expect(round.source, 'ai');
  });

  test('nameLower is indexed for case-insensitive lookups', () {
    final roaster = Roaster(
      id: '',
      name: 'Blue Bottle',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    expect(roaster.toFirestore()['nameLower'], 'blue bottle');
  });
}
