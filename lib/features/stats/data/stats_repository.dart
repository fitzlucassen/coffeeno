import 'package:cloud_firestore/cloud_firestore.dart';

import '../../coffee/domain/coffee.dart';
import '../../tasting/domain/tasting.dart';
import '../domain/tasting_stats.dart';

/// Owns the Firestore reads backing the Stats & Insights screen and turns the
/// raw coffee/tasting documents into a precomputed [TastingStats].
class StatsRepository {
  StatsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Streams the user's coffees, ordered by creation date descending.
  ///
  /// Mirrors `CoffeeRepository.getUserCoffees` (the query the stats screen
  /// previously relied on via `userCoffeesProvider`), including its 30-document
  /// page limit, so the computed stats match what the library shows.
  Stream<List<Coffee>> watchUserCoffees(String uid, {int limit = 30}) {
    return _firestore
        .collection('coffees')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList(),
        );
  }

  /// Fetches all of the user's tastings, ordered by creation date descending.
  Future<List<Tasting>> getUserTastings(String uid) async {
    final snapshot = await _firestore
        .collection('tastings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList();
  }

  /// Streams precomputed [TastingStats] for the given user.
  ///
  /// Tastings are fetched once, then the coffees stream drives updates so the
  /// summary/library-derived figures stay live (matching the previous behavior
  /// where coffees came from a real-time provider and tastings from a one-shot
  /// fetch).
  Stream<TastingStats> watchStats(String uid) async* {
    final tastings = await getUserTastings(uid);
    yield* watchUserCoffees(
      uid,
    ).map((coffees) => TastingStats.from(coffees: coffees, tastings: tastings));
  }
}
