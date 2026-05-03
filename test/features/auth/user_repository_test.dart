import 'package:coffeeno/features/auth/data/user_repository.dart';
import 'package:coffeeno/features/auth/domain/app_user.dart';
import 'package:coffeeno/features/auth/domain/user_role.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

AppUser _user(String uid, {String? username}) => AppUser(
      uid: uid,
      email: '$uid@x',
      displayName: uid,
      username: username ?? uid,
      roles: {UserRole.user},
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late FakeFirebaseFirestore firestore;
  late UserRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = UserRepository(firestore: firestore);
  });

  test('createUser writes the user doc under its uid', () async {
    await repo.createUser(_user('alice'));
    final fetched = await repo.getUser('alice');
    expect(fetched, isNotNull);
    expect(fetched!.username, 'alice');
  });

  test('getUser returns null when the doc does not exist', () async {
    expect(await repo.getUser('nope'), isNull);
  });

  test('updateUser merges only given fields', () async {
    await repo.createUser(_user('bob'));
    await repo.updateUser('bob', {'bio': 'hello'});
    final fetched = await repo.getUser('bob');
    expect(fetched!.bio, 'hello');
    expect(fetched.displayName, 'bob');
  });

  group('searchUsersByUsername', () {
    setUp(() async {
      await repo.createUser(_user('alice', username: 'alice'));
      await repo.createUser(_user('alex', username: 'alex'));
      await repo.createUser(_user('bob', username: 'bob'));
    });

    test('returns users with matching prefix', () async {
      final results = await repo.searchUsersByUsername('al');
      final usernames = results.map((u) => u.username).toSet();
      expect(usernames, containsAll(<String>['alice', 'alex']));
      expect(usernames, isNot(contains('bob')));
    });

    test('returns empty list for empty query', () async {
      expect(await repo.searchUsersByUsername(''), isEmpty);
    });

    test('respects the limit parameter', () async {
      final results = await repo.searchUsersByUsername('al', limit: 1);
      expect(results.length, 1);
    });
  });

  test('watchUser streams latest changes', () async {
    await repo.createUser(_user('carla'));

    final events = <String?>[];
    final sub = repo.watchUser('carla').listen((u) => events.add(u?.bio));

    // Let the initial snapshot arrive before mutating.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.updateUser('carla', {'bio': 'updated'});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();

    expect(events, contains(null));
    expect(events, contains('updated'));
  });
}
