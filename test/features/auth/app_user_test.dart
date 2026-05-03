import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/auth/domain/app_user.dart';
import 'package:coffeeno/features/auth/domain/user_role.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUser serialization', () {
    late FakeFirebaseFirestore firestore;

    setUp(() => firestore = FakeFirebaseFirestore());

    test('round-trips through Firestore preserving all fields', () async {
      final createdAt = DateTime(2026, 2, 1);
      final premiumUntil = DateTime(2026, 3, 1);
      final roasterProUntil = DateTime(2026, 4, 1);

      final user = AppUser(
        uid: 'u1',
        email: 'u@example.com',
        displayName: 'U One',
        username: 'uone',
        avatarUrl: 'https://x/y.png',
        bio: 'hi',
        country: 'FR',
        followersCount: 3,
        followingCount: 2,
        tastingsCount: 7,
        roles: {UserRole.user, UserRole.roaster, UserRole.farmer},
        premium: true,
        premiumUntil: premiumUntil,
        roasterPro: true,
        roasterProUntil: roasterProUntil,
        createdAt: createdAt,
      );

      await firestore.collection('users').doc('u1').set(user.toFirestore());
      final snap = await firestore.collection('users').doc('u1').get();
      final round = AppUser.fromFirestore(snap);

      expect(round, user);
    });

    test('reads legacy role field when roles array is missing', () async {
      await firestore.collection('users').doc('legacy').set({
        'email': 'l@x',
        'displayName': 'Legacy',
        'username': 'legacy',
        'role': 'admin',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      final snap = await firestore.collection('users').doc('legacy').get();
      final user = AppUser.fromFirestore(snap);

      expect(user.roles, {UserRole.admin});
      expect(user.isAdmin, isTrue);
    });

    test('defaults roles to {user} when neither field is present', () async {
      await firestore.collection('users').doc('bare').set({
        'email': 'b@x',
        'displayName': 'Bare',
        'username': 'bare',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });
      final snap = await firestore.collection('users').doc('bare').get();
      final user = AppUser.fromFirestore(snap);

      expect(user.roles, {UserRole.user});
    });
  });

  group('AppUser permissions', () {
    AppUser base({
      Set<UserRole> roles = const {UserRole.user},
      bool premium = false,
      DateTime? premiumUntil,
      bool roasterPro = false,
      DateTime? roasterProUntil,
    }) =>
        AppUser(
          uid: 'u',
          email: 'u@x',
          displayName: 'u',
          username: 'u',
          roles: roles,
          premium: premium,
          premiumUntil: premiumUntil,
          roasterPro: roasterPro,
          roasterProUntil: roasterProUntil,
          createdAt: DateTime(2026, 1, 1),
        );

    test('multi-role flags work independently', () {
      final u = base(roles: {UserRole.roaster, UserRole.farmer, UserRole.admin});
      expect(u.isRoaster, isTrue);
      expect(u.isFarmer, isTrue);
      expect(u.isAdmin, isTrue);
    });

    test('single-role user is not admin/roaster/farmer', () {
      final u = base(roles: {UserRole.user});
      expect(u.isAdmin, isFalse);
      expect(u.isRoaster, isFalse);
      expect(u.isFarmer, isFalse);
    });

    test('roaster pro grants premium (superset rule)', () {
      final u = base(roasterPro: true);
      expect(u.isPremiumActive, isTrue);
    });

    test('premium-only user is premium but not roaster pro', () {
      final u = base(premium: true);
      expect(u.isPremiumActive, isTrue);
      expect(u.isRoasterProActive, isFalse);
    });

    test('expired premium is not active', () {
      final u = base(
        premium: true,
        premiumUntil: DateTime(2020, 1, 1),
      );
      expect(u.isPremiumActive, isFalse);
    });

    test('expired roaster pro does not grant premium', () {
      final u = base(
        roasterPro: true,
        roasterProUntil: DateTime(2020, 1, 1),
      );
      expect(u.isPremiumActive, isFalse);
      expect(u.isRoasterProActive, isFalse);
    });

    test('premium expired but roaster pro active still grants premium', () {
      final u = base(
        premium: true,
        premiumUntil: DateTime(2020, 1, 1),
        roasterPro: true,
      );
      expect(u.isPremiumActive, isTrue);
    });

    test('copyWith updates only the given fields', () {
      final u = base(roles: {UserRole.user});
      final updated = u.copyWith(roles: {UserRole.user, UserRole.roaster});
      expect(updated.roles, {UserRole.user, UserRole.roaster});
      expect(updated.uid, u.uid);
      expect(updated.email, u.email);
    });
  });
}
