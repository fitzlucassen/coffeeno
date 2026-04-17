import 'package:cloud_firestore/cloud_firestore.dart';

class Follow {
  const Follow({
    required this.userId,
    required this.followedAt,
  });

  final String userId;
  final DateTime followedAt;

  factory Follow.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Follow(
      userId: doc.id,
      followedAt: (data['followedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'followedAt': Timestamp.fromDate(followedAt),
    };
  }
}
