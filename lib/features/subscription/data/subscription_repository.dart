import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/subscription_status.dart';

class SubscriptionRepository {
  SubscriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<SubscriptionStatus> watchStatus() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const SubscriptionStatus());

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return const SubscriptionStatus();

      final premium = data['premium'] as bool? ?? false;
      final premiumUntil = (data['premiumUntil'] as Timestamp?)?.toDate();

      return SubscriptionStatus(
        tier: premium ? SubscriptionTier.premium : SubscriptionTier.free,
        premiumUntil: premiumUntil,
      );
    });
  }

  Future<int> getUserCoffeeCount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final snapshot = await _firestore
        .collection('coffees')
        .where('uid', isEqualTo: uid)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  Future<int> getUserTastingsThisMonth() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _firestore
        .collection('tastings')
        .where('userId', isEqualTo: uid)
        .where('tastingDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
