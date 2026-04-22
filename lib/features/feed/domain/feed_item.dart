import 'package:cloud_firestore/cloud_firestore.dart';

class FeedItem {
  const FeedItem({
    required this.tastingId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.coffeeName,
    required this.roasterName,
    this.coffeePhotoUrl,
    required this.overallRating,
    this.brewMethod,
    this.notes,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  final String tastingId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String coffeeName;
  final String roasterName;
  final String? coffeePhotoUrl;
  final double overallRating;
  final String? brewMethod;
  final String? notes;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  factory FeedItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FeedItem(
      tastingId: doc.id,
      authorId: (data['authorId'] ?? data['userId'] ?? '') as String,
      authorName: (data['authorName'] ?? data['coffeeName'] ?? '') as String,
      authorAvatar: data['authorAvatar'] as String?,
      coffeeName: (data['coffeeName'] ?? '') as String,
      roasterName: (data['roasterName'] ?? '') as String,
      coffeePhotoUrl: data['coffeePhotoUrl'] as String?,
      overallRating: (data['overallRating'] as num?)?.toDouble() ?? 0,
      brewMethod: data['brewMethod'] as String?,
      notes: data['notes'] as String?,
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'coffeeName': coffeeName,
      'roasterName': roasterName,
      'coffeePhotoUrl': coffeePhotoUrl,
      'overallRating': overallRating,
      'brewMethod': brewMethod,
      'notes': notes,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FeedItem copyWith({
    int? likesCount,
    int? commentsCount,
  }) {
    return FeedItem(
      tastingId: tastingId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      coffeeName: coffeeName,
      roasterName: roasterName,
      coffeePhotoUrl: coffeePhotoUrl,
      overallRating: overallRating,
      brewMethod: brewMethod,
      notes: notes,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
    );
  }
}

class FeedComment {
  const FeedComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String text;
  final DateTime createdAt;

  factory FeedComment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FeedComment(
      id: doc.id,
      authorId: (data['authorId'] ?? '') as String,
      authorName: (data['authorName'] ?? '') as String,
      authorAvatar: data['authorAvatar'] as String?,
      text: (data['text'] ?? '') as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
