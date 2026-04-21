import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tastingsCount = 0,
    this.role = 'user',
    this.premium = false,
    this.premiumUntil,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int tastingsCount;
  final String role; // 'user', 'roaster', 'farmer', 'admin'
  final bool premium;
  final DateTime? premiumUntil;
  final DateTime createdAt;

  bool get isAdmin => role == 'admin';
  bool get isRoaster => role == 'roaster';
  bool get isFarmer => role == 'farmer';
  bool get isPremiumActive =>
      premium && (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      username: data['username'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      bio: data['bio'] as String?,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      tastingsCount: data['tastingsCount'] as int? ?? 0,
      role: data['role'] as String? ?? 'user',
      premium: data['premium'] as bool? ?? false,
      premiumUntil: (data['premiumUntil'] as Timestamp?)?.toDate(),
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
      'followersCount': followersCount,
      'followingCount': followingCount,
      'tastingsCount': tastingsCount,
      'role': role,
      'premium': premium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
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
    int? followersCount,
    int? followingCount,
    int? tastingsCount,
    String? role,
    bool? premium,
    DateTime? premiumUntil,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tastingsCount: tastingsCount ?? this.tastingsCount,
      role: role ?? this.role,
      premium: premium ?? this.premium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
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
          followersCount == other.followersCount &&
          followingCount == other.followingCount &&
          tastingsCount == other.tastingsCount &&
          role == other.role &&
          premium == other.premium &&
          premiumUntil == other.premiumUntil &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        displayName,
        username,
        avatarUrl,
        bio,
        followersCount,
        followingCount,
        tastingsCount,
        role,
        premium,
        premiumUntil,
        createdAt,
      );

  @override
  String toString() => 'AppUser(uid: $uid, email: $email, username: $username)';
}
