import 'package:cloud_firestore/cloud_firestore.dart';

class Claim {
  const Claim({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.entityName,
    this.status = 'pending',
    this.message,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String entityType; // 'roaster' | 'farm'
  final String entityId;
  final String entityName;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? message;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  factory Claim.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Claim(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      entityType: data['entityType'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      entityName: data['entityName'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
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
      'entityType': entityType,
      'entityId': entityId,
      'entityName': entityName,
      'status': status,
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
    String? entityType,
    String? entityId,
    String? entityName,
    String? status,
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
