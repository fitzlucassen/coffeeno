import 'package:coffeeno/features/farm/data/farm_repository.dart';
import 'package:coffeeno/features/farm/domain/farm.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Farm _farm(String name, {String? country}) => Farm(
      id: '',
      name: name,
      country: country,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late FarmRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = FarmRepository(firestore: firestore);
  });

  test('addFarm + getFarm round-trips', () async {
    final id = await repo.addFarm(_farm('Finca Esperanza'));
    final fetched = await repo.getFarm(id);
    expect(fetched!.name, 'Finca Esperanza');
  });

  test('findByName disambiguates identical names by country', () async {
    await repo.addFarm(_farm('Finca Luna', country: 'CO'));
    await repo.addFarm(_farm('Finca Luna', country: 'GT'));

    final co = await repo.findByName('finca luna', country: 'CO');
    expect(co!.country, 'CO');

    final gt = await repo.findByName('finca luna', country: 'GT');
    expect(gt!.country, 'GT');
  });

  test('findByName returns null if nothing matches', () async {
    expect(await repo.findByName('ghost'), isNull);
  });
}
