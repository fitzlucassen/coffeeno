import 'package:coffeeno/features/roaster/data/roaster_repository.dart';
import 'package:coffeeno/features/roaster/domain/roaster.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Roaster _roaster(String name) => Roaster(
      id: '',
      name: name,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late RoasterRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = RoasterRepository(firestore: firestore);
  });

  test('addRoaster persists the doc and returns an id', () async {
    final id = await repo.addRoaster(_roaster('ACME'));
    expect(id, isNotEmpty);
    expect((await repo.getRoaster(id))!.name, 'ACME');
  });

  test('getRoaster returns null when missing', () async {
    expect(await repo.getRoaster('nope'), isNull);
  });

  test('findByName matches case-insensitively via nameLower index', () async {
    await repo.addRoaster(_roaster('Blue Bottle'));
    final found = await repo.findByName('BLUE bottle');
    expect(found, isNotNull);
    expect(found!.name, 'Blue Bottle');
  });

  test('findByName returns null when no roaster matches', () async {
    expect(await repo.findByName('ghost'), isNull);
  });

  test('getAllRoasters streams up to the limit, ordered by name', () async {
    await repo.addRoaster(_roaster('Bravo'));
    await repo.addRoaster(_roaster('Alpha'));
    await repo.addRoaster(_roaster('Charlie'));

    final list = await repo.getAllRoasters(limit: 2).first;
    expect(list.length, 2);
    // Ordered alphabetically by name.
    expect(list.first.name, 'Alpha');
  });
}
