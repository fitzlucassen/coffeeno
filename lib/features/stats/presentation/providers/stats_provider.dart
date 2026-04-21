import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:coffeeno/features/tasting/domain/tasting.dart';

/// Fetches all tastings for a given user, ordered by creation date descending.
final userAllTastingsProvider =
    FutureProvider.family<List<Tasting>, String>((ref, userId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('tastings')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .get();
  return snapshot.docs.map((doc) => Tasting.fromFirestore(doc)).toList();
});
