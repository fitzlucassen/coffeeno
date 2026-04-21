import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/roaster.dart';

class RoasterRepository {
  RoasterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('roasters');

  Future<String> addRoaster(Roaster roaster) async {
    final docRef = await _collection.add(roaster.toFirestore());
    return docRef.id;
  }

  Future<Roaster?> getRoaster(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Roaster.fromFirestore(doc);
  }

  Stream<Roaster?> watchRoaster(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Roaster.fromFirestore(doc);
    });
  }

  Future<void> updateRoaster(Roaster roaster) async {
    await _collection.doc(roaster.id).update(roaster.toFirestore());
  }

  Future<Roaster?> findByName(String name) async {
    final snapshot = await _collection
        .where('nameLower', isEqualTo: name.toLowerCase().trim())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Roaster.fromFirestore(snapshot.docs.first);
  }

  Stream<List<Roaster>> getAllRoasters({int limit = 50}) {
    return _collection
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Roaster.fromFirestore(doc)).toList());
  }
}
