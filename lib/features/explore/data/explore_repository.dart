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

  /// Fetches coffees whose [originCountry] matches the user's country,
  /// ordered by average rating descending. Only includes coffees with at
  /// least one rating so the results are meaningful.
  Future<List<Coffee>> getPopularNearMe(
    String userCountry, {
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection('coffees')
        .where('originCountry', isEqualTo: userCountry)
        .where('ratingsCount', isGreaterThanOrEqualTo: 1)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList();
  }
}
