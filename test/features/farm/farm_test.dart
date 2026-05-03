import 'package:coffeeno/features/farm/domain/farm.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Farm round-trips through Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final farm = Farm(
      id: '',
      name: 'Finca La Esperanza',
      country: 'Colombia',
      region: 'Huila',
      farmerName: 'Don Pedro',
      altitude: '1800m',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 2),
    );
    final ref =
        await firestore.collection('farms').add(farm.toFirestore());
    final round = Farm.fromFirestore(await ref.get());

    expect(round.name, 'Finca La Esperanza');
    expect(round.region, 'Huila');
    expect(round.altitude, '1800m');
    expect(round.source, 'ai');
  });

  test('copyWith updates only given fields', () {
    final farm = Farm(
      id: '1',
      name: 'F',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final updated = farm.copyWith(name: 'F2');
    expect(updated.name, 'F2');
    expect(updated.id, '1');
  });
}
