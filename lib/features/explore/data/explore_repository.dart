import 'package:cloud_firestore/cloud_firestore.dart';

import '../../coffee/domain/coffee.dart';
import '../../roaster/domain/roaster.dart';

class ExploreRepository {
  ExploreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Coffee>> getTrendingCoffees({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('coffees')
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        .orderBy('ratingsCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList();
  }

  Future<List<Coffee>> getRecentlyAdded({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('coffees')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList();
  }

  Future<List<Coffee>> getTopRated({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('coffees')
        .where('ratingsCount', isGreaterThanOrEqualTo: 3)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList();
  }

  Future<List<Roaster>> getNewRoasters({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('roasters')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Roaster.fromFirestore(doc)).toList();
  }

  /// Fetches popular coffees from roasters located in the user's country,
  /// ordered by average rating descending. Only includes coffees with at least
  /// one rating so the results are meaningful.
  ///
  /// "Near me" means the *roaster* is local, not the bean's growing origin —
  /// comparing the user's residence country to `originCountry` (a producing
  /// country like Ethiopia) would match almost nothing for a typical consumer.
  Future<List<Coffee>> getPopularNearMe(
    String userCountry, {
    int limit = 20,
  }) async {
    // 1. Find roasters in the user's country.
    final roasterSnapshot = await _firestore
        .collection('roasters')
        .where('country', isEqualTo: userCountry)
        .get();
    final roasterIds = roasterSnapshot.docs.map((d) => d.id).toList();
    if (roasterIds.isEmpty) return [];

    // 2. Fetch their rated coffees. Firestore `whereIn` is capped at 30 values,
    // so batch the roaster ids and merge the results client-side.
    final coffees = <Coffee>[];
    for (var i = 0; i < roasterIds.length; i += 30) {
      final batch = roasterIds.sublist(
        i,
        i + 30 > roasterIds.length ? roasterIds.length : i + 30,
      );
      final snapshot = await _firestore
          .collection('coffees')
          .where('roasterId', whereIn: batch)
          .where('ratingsCount', isGreaterThanOrEqualTo: 1)
          .get();
      coffees.addAll(snapshot.docs.map((doc) => Coffee.fromFirestore(doc)));
    }

    coffees.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    return coffees.take(limit).toList();
  }
}
