import 'package:coffeeno/features/admin/data/claim_repository.dart';
import 'package:coffeeno/features/admin/domain/claim.dart';
import 'package:coffeeno/features/auth/domain/app_user.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_user_docs.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ClaimRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = ClaimRepository(firestore: firestore);
  });

  Future<String> seedClaim({
    required String userId,
    required ClaimEntityType type,
    required String entityId,
  }) async {
    final claim = Claim(
      id: '',
      userId: userId,
      entityType: type,
      entityId: entityId,
      entityName: 'Entity',
      createdAt: DateTime(2026, 2, 1),
    );
    // Also seed the target entity with an empty document so approve's update
    // succeeds.
    await firestore.collection(type.collection).doc(entityId).set({
      'name': 'Entity',
    });
    return repo.submitClaim(claim);
  }

  test('submitClaim stores a pending claim', () async {
    final id = await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );

    final doc = await firestore.collection('claims').doc(id).get();
    expect(doc.data()!['status'], 'pending');
    expect(doc.data()!['entityType'], 'roaster');
  });

  test('approveClaim adds the roaster role without clobbering existing roles',
      () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'roles': ['user'],
    });

    final claimId = await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );
    await repo.approveClaim(claimId, 'admin1');

    final userDoc = await firestore.collection('users').doc('alice').get();
    final roles = (userDoc.data()!['roles'] as List).cast<String>();
    expect(roles, containsAll(<String>['user', 'roaster']));

    final claimDoc = await firestore.collection('claims').doc(claimId).get();
    expect(claimDoc.data()!['status'], 'approved');
    expect(claimDoc.data()!['reviewedBy'], 'admin1');
  });

  test(
      'approving a second claim for a different entity type keeps both roles '
      '— the reported bug #2 regression test', () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'roles': ['user'],
    });

    final roasterClaim = await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );
    await repo.approveClaim(roasterClaim, 'admin1');

    final farmClaim = await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.farm,
      entityId: 'f1',
    );
    await repo.approveClaim(farmClaim, 'admin1');

    final userDoc = await firestore.collection('users').doc('alice').get();
    final roles = (userDoc.data()!['roles'] as List).cast<String>();
    expect(
      roles,
      containsAll(<String>['user', 'roaster', 'farmer']),
      reason: 'approving a farm claim must not overwrite the roaster role',
    );

    // Confirm the parsed AppUser reflects both roles.
    final user = AppUser.fromFirestore(userDoc);
    expect(user.isRoaster, isTrue);
    expect(user.isFarmer, isTrue);
  });

  test('rejectClaim marks the claim rejected without touching the user',
      () async {
    await seedUser(firestore, uid: 'alice', overrides: {
      'roles': ['user'],
    });

    final claimId = await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );
    await repo.rejectClaim(claimId, 'admin1');

    final userDoc = await firestore.collection('users').doc('alice').get();
    final roles = (userDoc.data()!['roles'] as List).cast<String>();
    expect(roles, ['user']);

    final claimDoc = await firestore.collection('claims').doc(claimId).get();
    expect(claimDoc.data()!['status'], 'rejected');
  });

  test('approveClaim is a no-op when the claim does not exist', () async {
    await expectLater(
      repo.approveClaim('missing', 'admin1'),
      completes,
    );
  });

  test('getPendingClaims streams only pending claims', () async {
    await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );
    final approvedId = await seedClaim(
      userId: 'bob',
      type: ClaimEntityType.farm,
      entityId: 'f1',
    );
    await seedUser(firestore, uid: 'bob');
    await repo.approveClaim(approvedId, 'admin1');

    final claims = await repo.getPendingClaims().first;
    expect(claims.length, 1);
    expect(claims.first.userId, 'alice');
  });

  test('getUserClaims returns only that user\'s claims', () async {
    await seedClaim(
      userId: 'alice',
      type: ClaimEntityType.roaster,
      entityId: 'r1',
    );
    await seedClaim(
      userId: 'bob',
      type: ClaimEntityType.farm,
      entityId: 'f1',
    );

    final aliceClaims = await repo.getUserClaims('alice').first;
    expect(aliceClaims.length, 1);
    expect(aliceClaims.first.userId, 'alice');
  });
}
