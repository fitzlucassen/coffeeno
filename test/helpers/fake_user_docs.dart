import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// Seeds a minimal user document on [firestore] at `users/{uid}`.
/// Fields missing from [overrides] default to safe values.
Future<void> seedUser(
  FakeFirebaseFirestore firestore, {
  required String uid,
  Map<String, dynamic> overrides = const {},
}) async {
  final base = <String, dynamic>{
    'email': '$uid@example.com',
    'displayName': uid,
    'username': uid,
    'usernameLower': uid.toLowerCase(),
    'displayNameLower': uid.toLowerCase(),
    'followersCount': 0,
    'followingCount': 0,
    'tastingsCount': 0,
    'roles': ['user'],
    'premium': false,
    'premiumUntil': null,
    'roasterPro': false,
    'roasterProUntil': null,
    'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
  };
  base.addAll(overrides);
  await firestore.collection('users').doc(uid).set(base);
}
