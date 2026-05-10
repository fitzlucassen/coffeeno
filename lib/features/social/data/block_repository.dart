import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_block.dart';

/// Handles mutual user blocks.
///
/// Writes are always done as a pair: outgoing (in the actor's `blocked`
/// subcollection) and incoming (in the target's `blocked_by` subcollection),
/// in a single batch. Reads are done per-user from whichever subcollection
/// is relevant.
class BlockRepository {
  BlockRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _outgoingRef(String actor, String target) =>
      _firestore
          .collection('users')
          .doc(actor)
          .collection('blocked')
          .doc(target);

  DocumentReference<Map<String, dynamic>> _incomingRef(String target, String actor) =>
      _firestore
          .collection('users')
          .doc(target)
          .collection('blocked_by')
          .doc(actor);

  /// Creates a mutual block: [actor] blocks [target].
  Future<void> block({required String actor, required String target}) async {
    if (actor == target) {
      throw ArgumentError('A user cannot block themselves');
    }
    final now = DateTime.now();
    final payload = UserBlock(uid: target, createdAt: now).toFirestore();

    final batch = _firestore.batch()
      ..set(_outgoingRef(actor, target), payload)
      ..set(_incomingRef(target, actor), UserBlock(uid: actor, createdAt: now).toFirestore());
    await batch.commit();
  }

  /// Removes a mutual block created by [actor] against [target].
  Future<void> unblock({required String actor, required String target}) async {
    final batch = _firestore.batch()
      ..delete(_outgoingRef(actor, target))
      ..delete(_incomingRef(target, actor));
    await batch.commit();
  }

  /// Streams the UIDs that [uid] has blocked.
  Stream<Set<String>> watchOutgoing(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  /// Streams the UIDs that have blocked [uid].
  Stream<Set<String>> watchIncoming(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('blocked_by')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  /// Streams the full set of UIDs [uid] cannot see / cannot be seen by. This
  /// is the union used for all client-side filtering.
  Stream<Set<String>> watchBlockedUnion(String uid) {
    return watchOutgoing(uid).asyncMap((outgoing) async {
      final incoming = await _firestore
          .collection('users')
          .doc(uid)
          .collection('blocked_by')
          .get();
      return {...outgoing, ...incoming.docs.map((d) => d.id)};
    });
  }
}
