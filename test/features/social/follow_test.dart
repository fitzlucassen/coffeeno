import 'package:coffeeno/features/social/domain/follow.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Follow round-trips through Firestore (userId comes from doc id)',
      () async {
    final firestore = FakeFirebaseFirestore();
    final follow = Follow(
      userId: 'alice',
      followedAt: DateTime(2026, 3, 1),
    );

    await firestore
        .collection('users')
        .doc('bob')
        .collection('followers')
        .doc(follow.userId)
        .set(follow.toFirestore());

    final snap = await firestore
        .collection('users')
        .doc('bob')
        .collection('followers')
        .doc('alice')
        .get();

    final round = Follow.fromFirestore(snap);
    expect(round.userId, 'alice');
    expect(round.followedAt, DateTime(2026, 3, 1));
  });
}
