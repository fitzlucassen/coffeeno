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
  /// ratingsCount atomically using a batch write.
  Future<String> addTasting(Tasting tasting) async {
    final tastingRef = _tastings.doc();
    final coffeeRef = _coffees.doc(tasting.coffeeId);

    // Read current coffee data to compute new average
    final coffeeDoc = await coffeeRef.get();
    final coffeeData = coffeeDoc.data();

    final currentCount = (coffeeData?['ratingsCount'] as int?) ?? 0;
    final currentAvg = (coffeeData?['avgRating'] as num?)?.toDouble() ?? 0.0;

    final newCount = currentCount + 1;
    final newAvg =
        ((currentAvg * currentCount) + tasting.overallRating) / newCount;

    final batch = _firestore.batch();
    batch.set(tastingRef, tasting.toFirestore());
    batch.update(coffeeRef, {
      'avgRating': newAvg,
      'ratingsCount': newCount,
    });
    // Keep the profile-visible `tastingsCount` in sync. `set` with merge so
    // the write also succeeds on legacy user docs that never had the field.
    batch.set(
      _users.doc(tasting.userId),
      {'tastingsCount': FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    await batch.commit();

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
  Future<void> deleteTasting(String tastingId) async {
    final tastingDoc = await _tastings.doc(tastingId).get();
    if (!tastingDoc.exists || tastingDoc.data() == null) return;

    final tasting = Tasting.fromFirestore(tastingDoc);
    final coffeeRef = _coffees.doc(tasting.coffeeId);
    final coffeeDoc = await coffeeRef.get();
    final coffeeData = coffeeDoc.data();

    final currentCount = (coffeeData?['ratingsCount'] as int?) ?? 0;
    final currentAvg = (coffeeData?['avgRating'] as num?)?.toDouble() ?? 0.0;

    final newCount = (currentCount - 1).clamp(0, currentCount);
    final newAvg = newCount > 0
        ? ((currentAvg * currentCount) - tasting.overallRating) / newCount
        : 0.0;

    final batch = _firestore.batch();
    batch.delete(_tastings.doc(tastingId));
    batch.update(coffeeRef, {
      'avgRating': newAvg,
      'ratingsCount': newCount,
    });
    batch.update(
      _users.doc(tasting.userId),
      {'tastingsCount': FieldValue.increment(-1)},
    );
    await batch.commit();
  }

  /// Streams tastings for a specific coffee, ordered by creation date
  /// descending.
  Stream<List<Tasting>> getTastingsForCoffee(String coffeeId) {
    return _tastings
        .where('coffeeId', isEqualTo: coffeeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList());
  }

  /// Counts the number of tastings a user created **this calendar month**
  /// (server-side count query). Used for free-tier gating.
  Future<int> countForUserInMonth(String userId, {DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final startOfMonth = DateTime(reference.year, reference.month, 1);
    final startOfNextMonth =
        DateTime(reference.year, reference.month + 1, 1);

    final snapshot = await _tastings
        .where('userId', isEqualTo: userId)
        .where('tastingDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('tastingDate',
            isLessThan: Timestamp.fromDate(startOfNextMonth))
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList());
  }
}
