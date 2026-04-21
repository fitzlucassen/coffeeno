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
  final DateTime createdAt;

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
        createdAt,
      );

  @override
  String toString() => 'AppUser(uid: $uid, email: $email, username: $username)';
}
