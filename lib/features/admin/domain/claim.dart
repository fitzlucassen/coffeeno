import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/domain/user_role.dart';

/// The kind of entity a user is claiming ownership of.
enum ClaimEntityType {
  roaster,
  farm;

  String get wireName => switch (this) {
        ClaimEntityType.roaster => 'roaster',
        ClaimEntityType.farm => 'farm',
      };

  /// The Firestore collection storing this entity type.
  String get collection => switch (this) {
        ClaimEntityType.roaster => 'roasters',
        ClaimEntityType.farm => 'farms',
      };

  /// The role granted to the claimer when a claim of this type is approved.
  UserRole get grantedRole => switch (this) {
        ClaimEntityType.roaster => UserRole.roaster,
        ClaimEntityType.farm => UserRole.farmer,
      };

  static ClaimEntityType? fromWire(String? value) {
    for (final t in ClaimEntityType.values) {
      if (t.wireName == value) return t;
    }
    return null;
  }
}

enum ClaimStatus {
  pending,
  approved,
  rejected;

  String get wireName => name;

  static ClaimStatus fromWire(String? value) {
    for (final s in ClaimStatus.values) {
      if (s.wireName == value) return s;
    }
    return ClaimStatus.pending;
  }
}

class Claim {
  const Claim({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.status = ClaimStatus.pending,
    this.message,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final ClaimEntityType entityType;
  final String entityId;
  final String entityName;
  final ClaimStatus status;
  final String? message;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory Claim.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Claim(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      entityType: ClaimEntityType.fromWire(data['entityType'] as String?) ??
          ClaimEntityType.roaster,
      entityId: data['entityId'] as String? ?? '',
      entityName: data['entityName'] as String? ?? '',
      status: ClaimStatus.fromWire(data['status'] as String?),
      message: data['message'] as String?,
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: (data['reviewedAt'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'entityType': entityType.wireName,
      'entityId': entityId,
      'entityName': entityName,
      'status': status.wireName,
      'message': message,
      'reviewedBy': reviewedBy,
      'reviewedAt':
          reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Claim copyWith({
    String? id,
    String? userId,
    ClaimEntityType? entityType,
    String? entityId,
    String? entityName,
    ClaimStatus? status,
    String? message,
    String? reviewedBy,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return Claim(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityName: entityName ?? this.entityName,
      status: status ?? this.status,
      message: message ?? this.message,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
