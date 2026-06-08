import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.country,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tastingsCount = 0,
    this.roles = const {UserRole.user},
    this.premium = false,
    this.premiumUntil,
    this.roasterPro = false,
    this.roasterProUntil,
    this.hasSeenOnboarding = false,
    this.preferredBrewMethods = const [],
    this.preferredRoastLevels = const [],
    this.favoriteFlavors = const [],
    this.points = 0,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final int followersCount;
  final int followingCount;
  final int tastingsCount;
  final Set<UserRole> roles;
  final bool premium;
  final DateTime? premiumUntil;
  final bool roasterPro;
  final DateTime? roasterProUntil;
  final bool hasSeenOnboarding;

  /// Taste/brew preferences captured during onboarding. Stored as the string
  /// labels of the corresponding enums (BrewMethod.label, RoastLevel.label)
  /// and free-form flavor strings, so they round-trip without coupling the
  /// auth domain to the constants enums.
  final List<String> preferredBrewMethods;
  final List<String> preferredRoastLevels;
  final List<String> favoriteFlavors;

  /// Cumulative gamification points. Maps to a cosmetic expert tier via
  /// [ExpertLevel.fromPoints].
  final int points;

  final DateTime createdAt;

  bool get isAdmin => roles.contains(UserRole.admin);
  bool get isRoaster => roles.contains(UserRole.roaster);
  bool get isFarmer => roles.contains(UserRole.farmer);

  bool get _roasterProActive =>
      roasterPro &&
      (roasterProUntil == null || roasterProUntil!.isAfter(DateTime.now()));

  bool get _premiumTierActive =>
      premium && (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));

  /// Roaster Pro is a superset of Pro: holding either entitlement grants
  /// premium features.
  bool get isPremiumActive => _premiumTierActive || _roasterProActive;

  bool get isRoasterProActive => _roasterProActive;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      country: data['country'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      tastingsCount: data['tastingsCount'] as int? ?? 0,
      roles: parseRoles(
        rolesField: data['roles'],
        legacyRoleField: data['role'],
      ),
      premium: data['premium'] as bool? ?? false,
      premiumUntil: (data['premiumUntil'] as Timestamp?)?.toDate(),
      roasterPro: data['roasterPro'] as bool? ?? false,
      roasterProUntil: (data['roasterProUntil'] as Timestamp?)?.toDate(),
      hasSeenOnboarding: data['hasSeenOnboarding'] as bool? ?? false,
      preferredBrewMethods: _stringList(data['preferredBrewMethods']),
      preferredRoastLevels: _stringList(data['preferredRoastLevels']),
      favoriteFlavors: _stringList(data['favoriteFlavors']),
      points: (data['points'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'displayNameLower': displayName.toLowerCase(),
      'username': username,
      'usernameLower': username.toLowerCase(),
      'avatarUrl': avatarUrl,
      'bio': bio,
      'country': country,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'tastingsCount': tastingsCount,
      'roles': rolesToWire(roles),
      'premium': premium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'roasterPro': roasterPro,
      'roasterProUntil': roasterProUntil != null
          ? Timestamp.fromDate(roasterProUntil!)
          : null,
      'hasSeenOnboarding': hasSeenOnboarding,
      'preferredBrewMethods': preferredBrewMethods,
      'preferredRoastLevels': preferredRoastLevels,
      'favoriteFlavors': favoriteFlavors,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? avatarUrl,
    String? bio,
    String? country,
    int? followersCount,
    int? followingCount,
    int? tastingsCount,
    Set<UserRole>? roles,
    bool? premium,
    DateTime? premiumUntil,
    bool? roasterPro,
    DateTime? roasterProUntil,
    bool? hasSeenOnboarding,
    List<String>? preferredBrewMethods,
    List<String>? preferredRoastLevels,
    List<String>? favoriteFlavors,
    int? points,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tastingsCount: tastingsCount ?? this.tastingsCount,
      roles: roles ?? this.roles,
      premium: premium ?? this.premium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      roasterPro: roasterPro ?? this.roasterPro,
      roasterProUntil: roasterProUntil ?? this.roasterProUntil,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      preferredBrewMethods: preferredBrewMethods ?? this.preferredBrewMethods,
      preferredRoastLevels: preferredRoastLevels ?? this.preferredRoastLevels,
      favoriteFlavors: favoriteFlavors ?? this.favoriteFlavors,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          username == other.username &&
          avatarUrl == other.avatarUrl &&
          bio == other.bio &&
          country == other.country &&
          followersCount == other.followersCount &&
          followingCount == other.followingCount &&
          tastingsCount == other.tastingsCount &&
          _setEquals(roles, other.roles) &&
          premium == other.premium &&
          premiumUntil == other.premiumUntil &&
          roasterPro == other.roasterPro &&
          roasterProUntil == other.roasterProUntil &&
          hasSeenOnboarding == other.hasSeenOnboarding &&
          _listEquals(preferredBrewMethods, other.preferredBrewMethods) &&
          _listEquals(preferredRoastLevels, other.preferredRoastLevels) &&
          _listEquals(favoriteFlavors, other.favoriteFlavors) &&
          points == other.points &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll([
        uid,
        email,
        displayName,
        username,
        avatarUrl,
        bio,
        country,
        followersCount,
        followingCount,
        tastingsCount,
        Object.hashAllUnordered(roles),
        premium,
        premiumUntil,
        roasterPro,
        roasterProUntil,
        hasSeenOnboarding,
        Object.hashAll(preferredBrewMethods),
        Object.hashAll(preferredRoastLevels),
        Object.hashAll(favoriteFlavors),
        points,
        createdAt,
      ]);

  @override
  String toString() => 'AppUser(uid: $uid, email: $email, username: $username)';
}

bool _setEquals<T>(Set<T> a, Set<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  return a.every(b.contains);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Reads a Firestore list field into a `List<String>`, tolerating null and
/// non-string elements.
List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}
