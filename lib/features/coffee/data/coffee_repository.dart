import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/coffee.dart' show Coffee, normalizeText, coffeeCanonicalKey;

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

  /// Marks a coffee as having had its freshness notification scheduled.
  ///
  /// Writes only the `freshnessNotified` field rather than the whole document,
  /// so it can't clobber a concurrent partial write (e.g. background
  /// enrichment) that happens after this read but before its own write.
  Future<void> markFreshnessNotified(String coffeeId) async {
    await _collection.doc(coffeeId).update({'freshnessNotified': true});
  }

  /// Applies AI-enrichment results to a coffee, writing only the enrichment
  /// fields. Null values are skipped so we never overwrite existing data with
  /// nulls, and — like [markFreshnessNotified] — touching only these fields
  /// avoids clobbering a concurrent writer (e.g. the freshness flag).
  Future<void> applyEnrichment(
    String coffeeId, {
    String? roasterId,
    String? farmId,
    String? roasterUrl,
    String? roasterDescription,
    String? farmUrl,
    String? farmDescription,
  }) async {
    final data = <String, dynamic>{
      'roasterId': ?roasterId,
      'farmId': ?farmId,
      'roasterUrl': ?roasterUrl,
      'roasterDescription': ?roasterDescription,
      'farmUrl': ?farmUrl,
      'farmDescription': ?farmDescription,
    };
    if (data.isEmpty) return;
    await _collection.doc(coffeeId).update(data);
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

  /// Finds an existing coffee in [userId]'s library matching the canonical
  /// identity (roaster + name + origin), if any. Used to detect a re-bought
  /// bag so the user can re-add it without re-typing everything.
  ///
  /// Returns the most recently added match, or null when none exists.
  Future<Coffee?> findCanonicalMatchForUser({
    required String userId,
    required String roaster,
    required String name,
    required String originCountry,
  }) async {
    final key = coffeeCanonicalKey(
      roaster: roaster,
      name: name,
      originCountry: originCountry,
    );
    final snapshot = await _collection
        .where('uid', isEqualTo: userId)
        .where('canonicalKey', isEqualTo: key)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Coffee.fromFirestore(snapshot.docs.first);
  }

  /// Returns how many distinct users have a coffee with the given canonical
  /// identity in their library. Powers the "X people brew this" social signal.
  Future<int> communityOwnerCount({
    required String roaster,
    required String name,
    required String originCountry,
  }) async {
    final key = coffeeCanonicalKey(
      roaster: roaster,
      name: name,
      originCountry: originCountry,
    );
    final snapshot =
        await _collection.where('canonicalKey', isEqualTo: key).get();
    final owners = snapshot.docs
        .map((d) => d.data()['uid'] as String?)
        .whereType<String>()
        .toSet();
    return owners.length;
  }

  /// Searches coffees whose name or roaster matches the [query] string.
  ///
  /// Firestore does not support full-text search natively. This implementation
  /// runs prefix range queries against the normalized (lowercased,
  /// diacritic-folded) `nameNormalized` / `roasterNormalized` fields \u2014 the same
  /// fields written by [Coffee.toFirestore] \u2014 so the match is case- and
  /// accent-insensitive. For production use, consider Algolia or Typesense.
  Future<List<Coffee>> searchCoffees(String query, {int limit = 20}) async {
    final normalizedQuery = normalizeText(query);
    if (normalizedQuery.isEmpty) return [];

    // Search by name prefix
    final nameSnapshot = await _collection
        .orderBy('nameNormalized')
        .startAt([normalizedQuery])
        .endAt(['$normalizedQuery\uf8ff'])
        .limit(limit)
        .get();

    // Search by roaster prefix
    final roasterSnapshot = await _collection
        .orderBy('roasterNormalized')
        .startAt([normalizedQuery])
        .endAt(['$normalizedQuery\uf8ff'])
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

    // Secondary client-side filter for partial (non-prefix) matches.
    return results.values.where((coffee) {
      return normalizeText(coffee.name).contains(normalizedQuery) ||
          normalizeText(coffee.roaster).contains(normalizedQuery);
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

  /// Returns the total number of coffees owned by [userId]. Used for
  /// free-tier gating (e.g. max coffees per account).
  Future<int> countForUser(String userId) async {
    final snapshot =
        await _collection.where('uid', isEqualTo: userId).count().get();
    return snapshot.count ?? 0;
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
