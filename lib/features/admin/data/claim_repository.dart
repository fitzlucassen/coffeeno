import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/claim.dart';

class ClaimRepository {
  ClaimRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _claims =>
      _firestore.collection('claims');

  Future<String> submitClaim(Claim claim) async {
    final docRef = await _claims.add(claim.toFirestore());
    return docRef.id;
  }

  Stream<List<Claim>> getPendingClaims() {
    return _claims
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Claim.fromFirestore(doc)).toList());
  }

  Stream<List<Claim>> getUserClaims(String userId) {
    return _claims
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Claim.fromFirestore(doc)).toList());
  }

  Future<void> approveClaim(String claimId, String adminUid) async {
    final claimDoc = await _claims.doc(claimId).get();
    if (!claimDoc.exists) return;
    final claim = Claim.fromFirestore(claimDoc);

    final batch = _firestore.batch();

    batch.update(_claims.doc(claimId), {
      'status': 'approved',
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    final entityCollection = claim.entityType == 'roaster' ? 'roasters' : 'farms';
    batch.update(_firestore.collection(entityCollection).doc(claim.entityId), {
      'claimedBy': claim.userId,
      'claimStatus': 'approved',
      'source': 'claimed',
    });

    final role = claim.entityType == 'roaster' ? 'roaster' : 'farmer';
    batch.update(_firestore.collection('users').doc(claim.userId), {
      'role': role,
    });

    await batch.commit();
  }

  Future<void> rejectClaim(String claimId, String adminUid) async {
    await _claims.doc(claimId).update({
      'status': 'rejected',
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
