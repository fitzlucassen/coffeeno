import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/follow.dart';

/// Represents a user returned from search results.
class UserSearchResult {
  const UserSearchResult({
    required this.uid,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.tastingsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  final String uid;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final int tastingsCount;
  final int followersCount;
  final int followingCount;

  factory UserSearchResult.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserSearchResult(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      username: data['username'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      tastingsCount: (data['tastingsCount'] as num?)?.toInt() ?? 0,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class SocialRepository {
  SocialRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// Follows [targetId] from [userId].
  ///
  /// Writes to both users/{uid}/following/{targetId} and
  /// users/{targetId}/followers/{uid}, and updates count fields on both
  /// user documents.
  Future<void> followUser({
    required String userId,
    required String targetId,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // Write to current user's following subcollection.
    batch.set(
      _users.doc(userId).collection('following').doc(targetId),
      {'followedAt': now},
    );

    // Write to target user's followers subcollection.
    batch.set(
      _users.doc(targetId).collection('followers').doc(userId),
      {'followedAt': now},
    );

    // Increment counts on both user documents.
    batch.update(_users.doc(userId), {
      'followingCount': FieldValue.increment(1),
    });
    batch.update(_users.doc(targetId), {
      'followersCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Unfollows [targetId] from [userId].
  Future<void> unfollowUser({
    required String userId,
    required String targetId,
  }) async {
    final batch = _firestore.batch();

    batch.delete(_users.doc(userId).collection('following').doc(targetId));
    batch.delete(_users.doc(targetId).collection('followers').doc(userId));

    batch.update(_users.doc(userId), {
      'followingCount': FieldValue.increment(-1),
    });
    batch.update(_users.doc(targetId), {
      'followersCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// Streams the followers of [userId].
  Stream<List<Follow>> getFollowers(String userId) {
    return _users
        .doc(userId)
        .collection('followers')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Follow.fromFirestore(doc)).toList(),
        );
  }

  /// Streams the users that [userId] is following.
  Stream<List<Follow>> getFollowing(String userId) {
    return _users
        .doc(userId)
        .collection('following')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Follow.fromFirestore(doc)).toList(),
        );
  }

  /// Checks whether [userId] is following [targetId].
  Future<bool> isFollowing({
    required String userId,
    required String targetId,
  }) async {
    final doc = await _users
        .doc(userId)
        .collection('following')
        .doc(targetId)
        .get();
    return doc.exists;
  }

  /// Searches users by username or display name prefix.
  Future<List<UserSearchResult>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final upperBound = '${lowerQuery.substring(0, lowerQuery.length - 1)}'
        '${String.fromCharCode(lowerQuery.codeUnitAt(lowerQuery.length - 1) + 1)}';

    // Search by usernameLower field first.
    final usernameResults = await _users
        .where('usernameLower', isGreaterThanOrEqualTo: lowerQuery)
        .where('usernameLower', isLessThan: upperBound)
        .limit(20)
        .get();

    // Also search by displayNameLower.
    final displayNameResults = await _users
        .where('displayNameLower', isGreaterThanOrEqualTo: lowerQuery)
        .where('displayNameLower', isLessThan: upperBound)
        .limit(20)
        .get();

    // Merge results, deduplicating by uid.
    final map = <String, UserSearchResult>{};
    for (final doc in usernameResults.docs) {
      map[doc.id] = UserSearchResult.fromFirestore(doc);
    }
    for (final doc in displayNameResults.docs) {
      map.putIfAbsent(doc.id, () => UserSearchResult.fromFirestore(doc));
    }

    return map.values.toList();
  }

  /// Fetches a single user profile by uid.
  Future<UserSearchResult?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserSearchResult.fromFirestore(doc);
  }

  /// Streams a user profile for real-time updates.
  Stream<UserSearchResult?> getUserProfileStream(String userId) {
    return _users.doc(userId).snapshots().map(
          (doc) => doc.exists ? UserSearchResult.fromFirestore(doc) : null,
        );
  }

  /// Fetches user tastings ordered by creation date.
  Stream<List<Map<String, dynamic>>> getUserTastings(String userId) {
    return _firestore
        .collection('tastings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }
}
