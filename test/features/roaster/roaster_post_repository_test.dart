import 'package:coffeeno/features/roaster/data/roaster_post_repository.dart';
import 'package:coffeeno/features/roaster/domain/roaster_post.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

RoasterPost _post({
  required String roasterId,
  String id = '',
  DateTime? createdAt,
  DateTime? expiresAt,
  String authorUid = 'u1',
}) {
  final now = createdAt ?? DateTime(2026, 5, 1);
  return RoasterPost(
    id: id,
    roasterId: roasterId,
    authorUid: authorUid,
    roasterName: 'ACME',
    title: 'Post',
    body: 'Body',
    createdAt: now,
    expiresAt: expiresAt ?? now.add(RoasterPost.defaultLifetime),
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late RoasterPostRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = RoasterPostRepository(firestore: firestore);
  });

  test('createPost persists the post and returns its id', () async {
    final id = await repo.createPost(_post(roasterId: 'r1'));
    expect(id, isNotEmpty);
    final doc = await firestore.collection('roaster_posts').doc(id).get();
    expect(doc.exists, isTrue);
  });

  test('deletePost removes the post', () async {
    final id = await repo.createPost(_post(roasterId: 'r1'));
    await repo.deletePost(id);
    final doc = await firestore.collection('roaster_posts').doc(id).get();
    expect(doc.exists, isFalse);
  });

  test('watchPostsForRoaster streams only that roaster\'s posts', () async {
    await repo.createPost(_post(roasterId: 'r1'));
    await repo.createPost(_post(roasterId: 'r2'));
    await repo.createPost(_post(roasterId: 'r1'));

    final posts = await repo.watchPostsForRoaster('r1').first;
    expect(posts.length, 2);
    expect(posts.every((p) => p.roasterId == 'r1'), isTrue);
  });

  test('getActivePostsForRoasters filters out expired posts', () async {
    final now = DateTime(2026, 5, 10);
    // Active
    await repo.createPost(_post(
      roasterId: 'r1',
      createdAt: DateTime(2026, 5, 5),
      expiresAt: DateTime(2026, 6, 5),
    ));
    // Expired
    await repo.createPost(_post(
      roasterId: 'r1',
      createdAt: DateTime(2026, 3, 1),
      expiresAt: DateTime(2026, 4, 1),
    ));
    // Different roaster
    await repo.createPost(_post(
      roasterId: 'r2',
      createdAt: DateTime(2026, 5, 5),
      expiresAt: DateTime(2026, 6, 5),
    ));

    final posts = await repo.getActivePostsForRoasters(['r1'], now: now);
    expect(posts.length, 1);
    expect(posts.first.roasterId, 'r1');
    expect(posts.first.isExpired, isFalse);
  });

  test('getActivePostsForRoasters returns empty when input is empty',
      () async {
    final posts = await repo.getActivePostsForRoasters([]);
    expect(posts, isEmpty);
  });

  test('getActivePostsForRoasters merges across > 30 roaster ids', () async {
    // Create 35 distinct roasters with 1 active post each.
    final ids = [for (var i = 0; i < 35; i++) 'r$i'];
    final now = DateTime(2026, 5, 10);
    for (final rid in ids) {
      await repo.createPost(_post(
        roasterId: rid,
        createdAt: DateTime(2026, 5, 1),
        expiresAt: DateTime(2026, 6, 1),
      ));
    }

    final posts =
        await repo.getActivePostsForRoasters(ids, limit: 50, now: now);
    expect(posts.length, 35);
  });
}
