import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffeeno/features/admin/domain/claim.dart';
import 'package:coffeeno/features/auth/domain/user_role.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClaimEntityType', () {
    test('exposes the correct Firestore collection for each type', () {
      expect(ClaimEntityType.roaster.collection, 'roasters');
      expect(ClaimEntityType.farm.collection, 'farms');
    });

    test('grants the matching UserRole on approval', () {
      expect(ClaimEntityType.roaster.grantedRole, UserRole.roaster);
      expect(ClaimEntityType.farm.grantedRole, UserRole.farmer);
    });

    test('fromWire round-trips for every value', () {
      for (final t in ClaimEntityType.values) {
        expect(ClaimEntityType.fromWire(t.wireName), t);
      }
    });

    test('fromWire returns null for unknown input', () {
      expect(ClaimEntityType.fromWire('shop'), isNull);
      expect(ClaimEntityType.fromWire(null), isNull);
    });
  });

  group('ClaimStatus', () {
    test('defaults to pending when wire value is unrecognized', () {
      expect(ClaimStatus.fromWire('ghost'), ClaimStatus.pending);
      expect(ClaimStatus.fromWire(null), ClaimStatus.pending);
    });

    test('fromWire parses every known value', () {
      for (final s in ClaimStatus.values) {
        expect(ClaimStatus.fromWire(s.wireName), s);
      }
    });
  });

  group('Claim serialization', () {
    late FakeFirebaseFirestore firestore;

    setUp(() => firestore = FakeFirebaseFirestore());

    test('round-trips through Firestore', () async {
      final claim = Claim(
        id: 'c1',
        userId: 'u1',
        entityType: ClaimEntityType.farm,
        entityId: 'f1',
        entityName: 'Finca',
        status: ClaimStatus.approved,
        message: 'pls',
        reviewedBy: 'admin1',
        reviewedAt: DateTime(2026, 2, 10),
        createdAt: DateTime(2026, 2, 1),
      );

      final ref =
          await firestore.collection('claims').add(claim.toFirestore());
      final doc = await ref.get();
      final round = Claim.fromFirestore(doc);

      expect(round.entityType, ClaimEntityType.farm);
      expect(round.status, ClaimStatus.approved);
      expect(round.entityName, 'Finca');
      expect(round.reviewedBy, 'admin1');
      expect(round.reviewedAt, claim.reviewedAt);
      expect(round.createdAt, claim.createdAt);
    });

    test('tolerates a claim doc written without optional fields', () async {
      final ref = await firestore.collection('claims').add({
        'userId': 'u1',
        'entityType': 'roaster',
        'entityId': 'r1',
        'entityName': 'Roastery',
        'createdAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
      });
      final doc = await ref.get();
      final claim = Claim.fromFirestore(doc);

      expect(claim.entityType, ClaimEntityType.roaster);
      expect(claim.status, ClaimStatus.pending);
      expect(claim.message, isNull);
    });
  });
}
