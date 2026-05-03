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
        .where('status', isEqualTo: ClaimStatus.pending.wireName)
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

  /// Approves a pending claim. Writes all changes atomically:
  ///   1) marks the claim `approved` and records the reviewing admin.
  ///   2) marks the roaster/farm as claimed by the user.
  ///   3) **adds** the corresponding role to the user's `roles` array —
  ///      existing roles are preserved, so a user who claims a roaster and
  ///      then a farm ends up with both.
  Future<void> approveClaim(String claimId, String adminUid) async {
    final claimDoc = await _claims.doc(claimId).get();
    if (!claimDoc.exists) return;
    final claim = Claim.fromFirestore(claimDoc);

    final batch = _firestore.batch();

    batch.update(_claims.doc(claimId), {
      'status': ClaimStatus.approved.wireName,
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });

    batch.update(
      _firestore.collection(claim.entityType.collection).doc(claim.entityId),
      {
        'claimedBy': claim.userId,
        'claimStatus': ClaimStatus.approved.wireName,
        'source': 'claimed',
      },
    );

    batch.update(_firestore.collection('users').doc(claim.userId), {
      'roles': FieldValue.arrayUnion([claim.entityType.grantedRole.wireName]),
    });

    await batch.commit();
  }

  Future<void> rejectClaim(String claimId, String adminUid) async {
    await _claims.doc(claimId).update({
      'status': ClaimStatus.rejected.wireName,
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
