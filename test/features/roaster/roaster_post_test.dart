import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/roaster/domain/roaster_post.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

RoasterPost _base({
  DateTime? createdAt,
  DateTime? expiresAt,
  String? coffeeId,
}) {
  final now = createdAt ?? DateTime(2026, 5, 1);
  return RoasterPost(
    id: 'p1',
    roasterId: 'r1',
    authorUid: 'u1',
    roasterName: 'ACME',
    title: 'Nouveau Yirgacheffe',
    body: 'Arrive demain',
    coffeeId: coffeeId,
    coffeeName: coffeeId != null ? 'Yirgacheffe' : null,
    createdAt: now,
    expiresAt: expiresAt ?? now.add(RoasterPost.defaultLifetime),
  );
}

void main() {
  test('default lifetime is 30 days', () {
    expect(RoasterPost.defaultLifetime, const Duration(days: 30));
  });

  test('isExpired flips after expiresAt passes', () {
    final past = _base(
      createdAt: DateTime(2020, 1, 1),
      expiresAt: DateTime(2020, 2, 1),
    );
    final future = _base(
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
    );
    expect(past.isExpired, isTrue);
    expect(future.isExpired, isFalse);
  });

  test('round-trips through Firestore', () async {
    final firestore = FakeFirebaseFirestore();
    final original = _base(coffeeId: 'c1');

    final ref = await firestore
        .collection('roaster_posts')
        .add(original.toFirestore());
    final round = RoasterPost.fromFirestore(await ref.get());

    expect(round.roasterId, original.roasterId);
    expect(round.authorUid, original.authorUid);
    expect(round.title, original.title);
    expect(round.body, original.body);
    expect(round.coffeeId, 'c1');
    expect(round.coffeeName, 'Yirgacheffe');
    expect(round.createdAt, original.createdAt);
    expect(round.expiresAt, original.expiresAt);
  });

  test('tolerates a post written without optional fields', () async {
    final firestore = FakeFirebaseFirestore();
    final ref = await firestore.collection('roaster_posts').add({
      'roasterId': 'r1',
      'authorUid': 'u1',
      'roasterName': 'ACME',
      'title': 'Hello',
      'body': 'Body',
      'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
      'expiresAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
    });
    final post = RoasterPost.fromFirestore(await ref.get());

    expect(post.coffeeId, isNull);
    expect(post.ctaLabel, isNull);
    expect(post.ctaUrl, isNull);
  });

  test('copyWith updates only the given fields', () {
    final post = _base();
    final updated = post.copyWith(title: 'Updated');
    expect(updated.title, 'Updated');
    expect(updated.body, post.body);
    expect(updated.id, post.id);
  });
}
