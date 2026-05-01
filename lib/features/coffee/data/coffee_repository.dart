import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/coffee.dart' show Coffee, normalizeText;

class CoffeeRepository {
  CoffeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('coffees');

  /// Creates a new coffee document and returns its ID.
  Future<String> addCoffee(Coffee coffee) async {
    final docRef = await _collection.add(coffee.toFirestore());
    return docRef.id;
  }

  /// Fetches a single coffee by its document ID.
  Future<Coffee?> getCoffee(String coffeeId) async {
    final doc = await _collection.doc(coffeeId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Coffee.fromFirestore(doc);
  }

  /// Streams a single coffee document for real-time updates.
  Stream<Coffee?> watchCoffee(String coffeeId) {
    return _collection.doc(coffeeId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Coffee.fromFirestore(doc);
    });
  }

  /// Updates an existing coffee document.
  Future<void> updateCoffee(Coffee coffee) async {
    await _collection.doc(coffee.id).update(coffee.toFirestore());
  }

  /// Deletes a coffee document and all its associated tastings.
  Future<void> deleteCoffee(String coffeeId) async {
    final tastingsSnapshot = await _firestore
        .collection('tastings')
        .where('coffeeId', isEqualTo: coffeeId)
        .get();

    final batch = _firestore.batch();
    for (final doc in tastingsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_collection.doc(coffeeId));
    await batch.commit();
  }

  /// Streams the coffees belonging to a specific user, ordered by creation
  /// date descending. Results are paginated using [limit].
  Stream<List<Coffee>> getUserCoffees(String userId, {int limit = 30}) {
    return _collection
        .where('uid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList());
  }

  /// Searches coffees whose name or roaster matches the [query] string.
  ///
  /// Firestore does not support full-text search natively. This implementation
  /// uses a prefix range query on the `name` field followed by a client-side
  /// filter on `roaster`.  For production use, consider Algolia or Typesense.
  Future<List<Coffee>> searchCoffees(String query, {int limit = 20}) async {
    final lowerQuery = query.toLowerCase();

    // Search by name prefix
    final nameSnapshot = await _collection
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(limit)
        .get();

    // Search by roaster prefix
    final roasterSnapshot = await _collection
        .orderBy('roaster')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(limit)
        .get();

    // Merge results, deduplicating by document ID
    final Map<String, Coffee> results = {};
    for (final doc in nameSnapshot.docs) {
      results[doc.id] = Coffee.fromFirestore(doc);
    }
    for (final doc in roasterSnapshot.docs) {
      results.putIfAbsent(doc.id, () => Coffee.fromFirestore(doc));
    }

    // Secondary client-side filter for partial matches
    return results.values.where((coffee) {
      return coffee.name.toLowerCase().contains(lowerQuery) ||
          coffee.roaster.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Stream<List<Coffee>> getCoffeesForRoaster(String roasterId,
      {int limit = 30}) {
    return _collection
        .where('roasterId', isEqualTo: roasterId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList());
  }

  Stream<List<Coffee>> getCoffeesForFarm(String farmId, {int limit = 30}) {
    return _collection
        .where('farmId', isEqualTo: farmId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList());
  }

  Stream<List<Coffee>> getCoffeesByOrigin(String country, {int limit = 30}) {
    return _collection
        .where('originCountry', isEqualTo: country)
        .orderBy('avgRating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Coffee.fromFirestore(doc)).toList());
  }

  /// Returns the community average rating and user count for coffees
  /// matching the given [roaster] and [name] (normalized).
  ///
  /// Returns `null` if no matching coffees have ratings.
  Future<({double average, int count})?> getCommunityAverageRating(
    String roaster,
    String name,
  ) async {
    final normalizedRoaster = normalizeText(roaster);
    final normalizedName = normalizeText(name);

    final snapshot = await _collection
        .where('roasterNormalized', isEqualTo: normalizedRoaster)
        .where('nameNormalized', isEqualTo: normalizedName)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final ratings = snapshot.docs
        .map((doc) => (doc.data()['avgRating'] as num?)?.toDouble() ?? 0.0)
        .where((r) => r > 0)
        .toList();

    if (ratings.isEmpty) return null;

    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    return (average: average, count: ratings.length);
  }
}
