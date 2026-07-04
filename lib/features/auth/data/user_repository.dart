import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Creates a new user document in Firestore.
  ///
  /// The document ID is set to [user.uid] so it matches the Firebase Auth UID.
  Future<void> createUser(AppUser user) async {
    await _usersRef.doc(user.uid).set(user.toFirestore());
  }

  /// Fetches a single user by their UID.
  ///
  /// Returns `null` if the document does not exist.
  Future<AppUser?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Updates the user document with the provided [data].
  ///
  /// Only the fields present in [data] are overwritten.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  /// Atomically adds [delta] gamification points to the user document.
  ///
  /// Uses `FieldValue.increment` so concurrent awards (e.g. adding a coffee and
  /// logging a tasting in quick succession) don't clobber each other. `set`
  /// with merge so it also succeeds on legacy docs that never had the field.
  Future<void> awardPoints(String uid, int delta) async {
    if (delta == 0) return;
    await _usersRef.doc(uid).set({
      'points': FieldValue.increment(delta),
    }, SetOptions(merge: true));
  }

  /// Builds the canonical profile-update map, keeping the denormalized
  /// `*Lower` search fields in sync and normalizing the username consistently.
  ///
  /// Centralized here so the profile-setup and edit-profile screens can't drift
  /// in how they lowercase/trim fields. Pass only the optional fields you want
  /// to include (`bio`/`country` are written as `null` when empty to clear).
  static Map<String, dynamic> buildProfileUpdate({
    required String displayName,
    required String username,
    String? bio,
    bool includeBio = false,
    String? country,
    bool includeCountry = false,
  }) {
    final trimmedName = displayName.trim();
    final normalizedUsername = username.trim().toLowerCase();
    final trimmedBio = bio?.trim();
    final trimmedCountry = country?.trim();
    return {
      'displayName': trimmedName,
      'displayNameLower': trimmedName.toLowerCase(),
      'username': normalizedUsername,
      'usernameLower': normalizedUsername,
      if (includeBio)
        'bio': (trimmedBio == null || trimmedBio.isEmpty) ? null : trimmedBio,
      if (includeCountry)
        'country': (trimmedCountry == null || trimmedCountry.isEmpty)
            ? null
            : trimmedCountry,
    };
  }

  /// Searches for users whose username starts with [query].
  ///
  /// Returns up to [limit] results (default 20).
  Future<List<AppUser>> searchUsersByUsername(
    String query, {
    int limit = 20,
  }) async {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    // Firestore range query: username >= query && username < query + high Unicode char
    final snapshot = await _usersRef
        .where('username', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('username', isLessThan: '$lowercaseQuery\uf8ff')
        .limit(limit)
        .get();

    return snapshot.docs.map(AppUser.fromFirestore).toList();
  }

  /// Returns a real-time stream for a single user document.
  Stream<AppUser?> watchUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromFirestore(doc);
    });
  }
}
