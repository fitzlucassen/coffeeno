import 'package:cloud_firestore/cloud_firestore.dart';

/// A record that user A has blocked user B. Stored under both users to enable
/// mirror-lookup without composite queries:
///
///   users/{A}/blocked/{B}      — A's outgoing blocks (read by A to know who
///                                 they've blocked)
///   users/{B}/blocked_by/{A}   — B's incoming blocks (read by B so that
///                                 contexts like the feed can hide A even
///                                 though B doesn't know about the block)
///
/// Writing both docs atomically is the caller's responsibility.
class UserBlock {
  const UserBlock({
    required this.uid,
    required this.createdAt,
  });

  /// The other party's UID (interpretation depends on which subcollection
  /// it was read from).
  final String uid;
  final DateTime createdAt;

  factory UserBlock.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserBlock(
      uid: doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
