import 'package:coffeeno/features/social/data/social_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_user_docs.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SocialRepository repo;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repo = SocialRepository(firestore: firestore);
    await seedUser(firestore, uid: 'alice');
    await seedUser(firestore, uid: 'bob');
  });

  group('followUser', () {
    test('writes both mirror docs and increments both counts', () async {
      await repo.followUser(userId: 'alice', targetId: 'bob');

      final following = await firestore
          .collection('users')
          .doc('alice')
          .collection('following')
          .doc('bob')
          .get();
      final followers = await firestore
          .collection('users')
          .doc('bob')
          .collection('followers')
          .doc('alice')
          .get();
      expect(following.exists, isTrue);
      expect(followers.exists, isTrue);

      final alice = (await firestore.collection('users').doc('alice').get())
          .data();
      final bob = (await firestore.collection('users').doc('bob').get()).data();
      expect(alice!['followingCount'], 1);
      expect(bob!['followersCount'], 1);
    });

    test('isFollowing reflects the relationship', () async {
      expect(await repo.isFollowing(userId: 'alice', targetId: 'bob'), isFalse);
      await repo.followUser(userId: 'alice', targetId: 'bob');
      expect(await repo.isFollowing(userId: 'alice', targetId: 'bob'), isTrue);
    });
  });

  group('unfollowUser', () {
    test('removes both mirror docs and decrements both counts', () async {
      await repo.followUser(userId: 'alice', targetId: 'bob');
      await repo.unfollowUser(userId: 'alice', targetId: 'bob');

      expect(await repo.isFollowing(userId: 'alice', targetId: 'bob'), isFalse);

      final alice = (await firestore.collection('users').doc('alice').get())
          .data();
      final bob = (await firestore.collection('users').doc('bob').get()).data();
      expect(alice!['followingCount'], 0);
      expect(bob!['followersCount'], 0);
    });
  });

  group('getFollowers / getFollowing', () {
    test('stream the respective relationship sets', () async {
      await seedUser(firestore, uid: 'carla');
      await repo.followUser(userId: 'alice', targetId: 'bob');
      await repo.followUser(userId: 'carla', targetId: 'bob');

      final followersOfBob = await repo.getFollowers('bob').first;
      expect(
        followersOfBob.map((f) => f.userId),
        containsAll(['alice', 'carla']),
      );

      final aliceFollowing = await repo.getFollowing('alice').first;
      expect(aliceFollowing.map((f) => f.userId), ['bob']);
    });
  });

  group('searchUsers', () {
    setUp(() async {
      await seedUser(
        firestore,
        uid: 'u_alice',
        overrides: {
          'username': 'alice',
          'usernameLower': 'alice',
          'displayName': 'Alice',
          'displayNameLower': 'alice',
        },
      );
      await seedUser(
        firestore,
        uid: 'u_alex',
        overrides: {
          'username': 'alex',
          'usernameLower': 'alex',
          'displayName': 'Alex',
          'displayNameLower': 'alex',
        },
      );
      await seedUser(
        firestore,
        uid: 'u_bob',
        overrides: {
          'username': 'bob',
          'usernameLower': 'bob',
          'displayName': 'Bob',
          'displayNameLower': 'bob',
        },
      );
    });

    test('returns username-prefix matches case-insensitively', () async {
      final results = await repo.searchUsers('AL');
      final uids = results.map((r) => r.uid).toSet();
      expect(uids, containsAll(['u_alice', 'u_alex']));
      expect(uids, isNot(contains('u_bob')));
    });

    test('returns empty for a blank query', () async {
      expect(await repo.searchUsers('   '), isEmpty);
    });

    test(
      'deduplicates a user matched by both username and display name',
      () async {
        // "alice" matches both usernameLower and displayNameLower; should appear
        // once.
        final results = await repo.searchUsers('alice');
        expect(results.where((r) => r.uid == 'u_alice').length, 1);
      },
    );
  });
}
