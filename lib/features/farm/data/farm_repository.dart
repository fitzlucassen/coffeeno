import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/farm.dart';

class FarmRepository {
  FarmRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('farms');

  Future<String> addFarm(Farm farm) async {
    final docRef = await _collection.add(farm.toFirestore());
    return docRef.id;
  }

  Future<Farm?> getFarm(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Farm.fromFirestore(doc);
  }

  Stream<Farm?> watchFarm(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Farm.fromFirestore(doc);
    });
  }

  Future<void> updateFarm(Farm farm) async {
    await _collection.doc(farm.id).update(farm.toFirestore());
  }

  Future<Farm?> findByName(String name, {String? country}) async {
    var query = _collection.where('nameLower',
        isEqualTo: name.toLowerCase().trim());
    if (country != null && country.isNotEmpty) {
      query = query.where('country', isEqualTo: country);
    }
    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return Farm.fromFirestore(snapshot.docs.first);
  }

  Stream<List<Farm>> getAllFarms({int limit = 50}) {
    return _collection
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Farm.fromFirestore(doc)).toList());
  }
}
