import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/tasting.dart';

class TastingRepository {
  TastingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tastings =>
      _firestore.collection('tastings');

  CollectionReference<Map<String, dynamic>> get _coffees =>
      _firestore.collection('coffees');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Adds a new tasting and updates the parent coffee's avgRating and
  /// ratingsCount atomically.
  ///
  /// Uses a transaction (not a batch) so the read-modify-write of the running
  /// average is consistent: two tastings added concurrently would otherwise
  /// both read the same count/avg and the second commit would clobber the
  /// first, corrupting `avgRating` and undercounting `ratingsCount`.
  Future<String> addTasting(Tasting tasting) async {
    final tastingRef = _tastings.doc();
    final coffeeRef = _coffees.doc(tasting.coffeeId);
    final userRef = _users.doc(tasting.userId);

    await _firestore.runTransaction((txn) async {
      final coffeeDoc = await txn.get(coffeeRef);
      final coffeeData = coffeeDoc.data();

      final currentCount = (coffeeData?['ratingsCount'] as int?) ?? 0;
      final currentAvg = (coffeeData?['avgRating'] as num?)?.toDouble() ?? 0.0;

      final newCount = currentCount + 1;
      final newAvg =
          ((currentAvg * currentCount) + tasting.overallRating) / newCount;

      txn.set(tastingRef, tasting.toFirestore());
      // `set` with merge rather than `update`: `update` throws if the coffee
      // doc is missing (e.g. an orphaned tasting on a deleted coffee), which
      // would fail the whole transaction.
      txn.set(coffeeRef, {
        'avgRating': newAvg,
        'ratingsCount': newCount,
      }, SetOptions(merge: true));
      // Keep the profile-visible `tastingsCount` in sync. `set` with merge so
      // the write also succeeds on legacy user docs that never had the field.
      txn.set(userRef, {
        'tastingsCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    });

    return tastingRef.id;
  }

  /// Fetches a single tasting by its document ID.
  Future<Tasting?> getTasting(String tastingId) async {
    final doc = await _tastings.doc(tastingId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Tasting.fromFirestore(doc);
  }

  /// Updates an existing tasting document.
  Future<void> updateTasting(Tasting tasting) async {
    await _tastings.doc(tasting.id).update(tasting.toFirestore());
  }

  /// Deletes a tasting and adjusts the parent coffee's rating stats.
  ///
  /// Runs in a transaction for the same consistency reason as [addTasting]:
  /// the new average is derived from the current count/avg, so concurrent
  /// mutations must be serialized. All reads happen before any write, as
  /// Firestore transactions require.
  Future<void> deleteTasting(String tastingId) async {
    final tastingRef = _tastings.doc(tastingId);

    await _firestore.runTransaction((txn) async {
      final tastingDoc = await txn.get(tastingRef);
      if (!tastingDoc.exists || tastingDoc.data() == null) return;

      final tasting = Tasting.fromFirestore(tastingDoc);
      final coffeeRef = _coffees.doc(tasting.coffeeId);
      final coffeeDoc = await txn.get(coffeeRef);

      txn.delete(tastingRef);

      // Only adjust the coffee's stats if it still exists — the tasting may be
      // an orphan whose parent coffee was already deleted, in which case
      // `update` would throw and abort the delete.
      if (coffeeDoc.exists) {
        final coffeeData = coffeeDoc.data();
        final currentCount = (coffeeData?['ratingsCount'] as int?) ?? 0;
        final currentAvg =
            (coffeeData?['avgRating'] as num?)?.toDouble() ?? 0.0;

        final newCount = (currentCount - 1).clamp(0, currentCount);
        final newAvg = newCount > 0
            ? ((currentAvg * currentCount) - tasting.overallRating) / newCount
            : 0.0;

        txn.update(coffeeRef, {'avgRating': newAvg, 'ratingsCount': newCount});
      }

      // `set` with merge rather than `update` so a legacy user doc without the
      // field (or a since-deleted user) doesn't abort the transaction.
      txn.set(_users.doc(tasting.userId), {
        'tastingsCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));
    });
  }

  /// Streams tastings for a specific coffee, ordered by creation date
  /// descending.
  Stream<List<Tasting>> getTastingsForCoffee(String coffeeId) {
    return _tastings
        .where('coffeeId', isEqualTo: coffeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList(),
        );
  }

  /// Counts the number of tastings a user created **this calendar month**
  /// (server-side count query). Used for free-tier gating.
  Future<int> countForUserInMonth(String userId, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final startOfMonth = DateTime(reference.year, reference.month, 1);
    final startOfNextMonth = DateTime(reference.year, reference.month + 1, 1);

    final snapshot = await _tastings
        .where('userId', isEqualTo: userId)
        .where(
          'tastingDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('tastingDate', isLessThan: Timestamp.fromDate(startOfNextMonth))
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Streams a user's tastings, ordered by creation date descending.
  Stream<List<Tasting>> getUserTastings(String userId) {
    return _tastings
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList(),
        );
  }
}
