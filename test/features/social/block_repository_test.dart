import 'package:coffeeno/features/social/data/block_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BlockRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = BlockRepository(firestore: firestore);
  });

  test('block writes both outgoing and incoming mirror docs', () async {
    await repo.block(actor: 'alice', target: 'bob');

    final outgoing = await firestore
        .collection('users')
        .doc('alice')
        .collection('blocked')
        .doc('bob')
        .get();
    final incoming = await firestore
        .collection('users')
        .doc('bob')
        .collection('blocked_by')
        .doc('alice')
        .get();

    expect(outgoing.exists, isTrue);
    expect(incoming.exists, isTrue);
  });

  test('block refuses self-block', () {
    expect(
      () => repo.block(actor: 'alice', target: 'alice'),
      throwsArgumentError,
    );
  });

  test('unblock removes both mirror docs', () async {
    await repo.block(actor: 'alice', target: 'bob');
    await repo.unblock(actor: 'alice', target: 'bob');

    final outgoing = await firestore
        .collection('users')
        .doc('alice')
        .collection('blocked')
        .doc('bob')
        .get();
    final incoming = await firestore
        .collection('users')
        .doc('bob')
        .collection('blocked_by')
        .doc('alice')
        .get();

    expect(outgoing.exists, isFalse);
    expect(incoming.exists, isFalse);
  });

  test('watchOutgoing streams the set of blocked target UIDs', () async {
    await repo.block(actor: 'alice', target: 'bob');
    await repo.block(actor: 'alice', target: 'carol');

    final set = await repo.watchOutgoing('alice').first;
    expect(set, {'bob', 'carol'});
  });

  test('watchIncoming streams the set of UIDs who blocked me', () async {
    await repo.block(actor: 'bob', target: 'alice');
    await repo.block(actor: 'carol', target: 'alice');

    final set = await repo.watchIncoming('alice').first;
    expect(set, {'bob', 'carol'});
  });

  test('watchBlockedUnion combines outgoing and incoming', () async {
    // alice has blocked bob, and dave has blocked alice.
    await repo.block(actor: 'alice', target: 'bob');
    await repo.block(actor: 'dave', target: 'alice');

    final union = await repo.watchBlockedUnion('alice').first;
    expect(union, {'bob', 'dave'});
  });
}
