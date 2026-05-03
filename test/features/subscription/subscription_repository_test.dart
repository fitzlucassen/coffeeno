import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/subscription/data/subscription_repository.dart';
import 'package:coffeeno/features/subscription/domain/subscription_status.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_user_docs.dart';

/// These tests exercise the **Firestore fallback** path of SubscriptionRepository
/// (reached when RevenueCat is not configured, which is always true in the
/// test environment). That path is what backs the production stream when a
/// build is run without --dart-define=REVENUECAT_API_KEY=…
void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late SubscriptionRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'alice'),
    );
    repo = SubscriptionRepository(firestore: firestore, auth: auth);
    SubscriptionRepository.resetForTests();
  });

  test('emits free status when user doc is missing', () async {
    final status = await repo.watchStatus().first;
    expect(status.isPremium, isFalse);
    expect(status.isRoasterPro, isFalse);
  });

  test('emits free status when user is signed out', () async {
    final signedOut = MockFirebaseAuth();
    final offlineRepo =
        SubscriptionRepository(firestore: firestore, auth: signedOut);
    final status = await offlineRepo.watchStatus().first;
    expect(status, const SubscriptionStatus());
  });

  test('reads premium flag from the user doc', () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'premium': true,
      'premiumUntil': Timestamp.fromDate(DateTime(2026, 12, 31)),
    });
    final status = await repo.watchStatus().first;

    expect(status.isPremium, isTrue);
    expect(status.tier, SubscriptionTier.premium);
    expect(status.premiumUntil, DateTime(2026, 12, 31));
  });

  test('reads roasterPro flag from the user doc', () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'roasterPro': true,
      'roasterProUntil': Timestamp.fromDate(DateTime(2026, 9, 1)),
    });
    final status = await repo.watchStatus().first;

    expect(status.isRoasterPro, isTrue);
    // Superset rule: roasterPro implies premium access.
    expect(status.isPremium, isTrue);
    expect(status.roasterProUntil, DateTime(2026, 9, 1));
  });

  test('dual-subscribed user has both flags and is premium', () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'premium': true,
      'roasterPro': true,
    });
    final status = await repo.watchStatus().first;

    expect(status.isPremium, isTrue);
    expect(status.isRoasterPro, isTrue);
  });

  test('returns free when RevenueCat uninitialized and no user doc exists',
      () async {
    // No seed call — doc is absent.
    final status = await repo.watchStatus().first;
    expect(status.isPremium, isFalse);
  });

  test('loginUser is a no-op when RevenueCat is not initialized', () async {
    await expectLater(repo.loginUser('alice'), completes);
  });

  test('logoutUser is a no-op when RevenueCat is not initialized', () async {
    await expectLater(repo.logoutUser(), completes);
  });
}
