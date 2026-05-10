import 'package:cloud_firestore/cloud_firestore.dart';

/// A public message published by a Roaster Pro subscriber, surfaced in the
/// consumer feed to users who've recently engaged with one of the roaster's
/// coffees.
///
/// Posts expire after [defaultLifetime] so old messages don't accumulate in
/// the feed; the consumer-side query filters on [expiresAt].
class RoasterPost {
  const RoasterPost({
    required this.id,
    required this.roasterId,
    required this.authorUid,
    required this.roasterName,
    this.roasterLogoUrl,
    required this.title,
    required this.body,
    this.coffeeId,
    this.coffeeName,
    this.ctaLabel,
    this.ctaUrl,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String roasterId;

  /// The Firebase Auth UID that created the post. Used by Firestore rules to
  /// enforce update/delete ownership.
  final String authorUid;

  // Denormalized for feed rendering so the consumer doesn't need a second read.
  final String roasterName;
  final String? roasterLogoUrl;

  final String title;
  final String body;

  /// Optional: a specific coffee the post is about. When set, the feed
  /// targeting uses this exact coffee; otherwise it targets any user who has
  /// any of this roaster's coffees in their library.
  final String? coffeeId;
  final String? coffeeName;

  final String? ctaLabel;
  final String? ctaUrl;

  final DateTime createdAt;
  final DateTime expiresAt;

  static const defaultLifetime = Duration(days: 30);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory RoasterPost.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return RoasterPost(
      id: doc.id,
      roasterId: data['roasterId'] as String? ?? '',
      authorUid: data['authorUid'] as String? ?? '',
      roasterName: data['roasterName'] as String? ?? '',
      roasterLogoUrl: data['roasterLogoUrl'] as String?,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      coffeeId: data['coffeeId'] as String?,
      coffeeName: data['coffeeName'] as String?,
      ctaLabel: data['ctaLabel'] as String?,
      ctaUrl: data['ctaUrl'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(defaultLifetime),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roasterId': roasterId,
      'authorUid': authorUid,
      'roasterName': roasterName,
      'roasterLogoUrl': roasterLogoUrl,
      'title': title,
      'body': body,
      'coffeeId': coffeeId,
      'coffeeName': coffeeName,
      'ctaLabel': ctaLabel,
      'ctaUrl': ctaUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  RoasterPost copyWith({
    String? title,
    String? body,
    String? coffeeId,
    String? coffeeName,
    String? ctaLabel,
    String? ctaUrl,
    DateTime? expiresAt,
  }) {
    return RoasterPost(
      id: id,
      roasterId: roasterId,
      authorUid: authorUid,
      roasterName: roasterName,
      roasterLogoUrl: roasterLogoUrl,
      title: title ?? this.title,
      body: body ?? this.body,
      coffeeId: coffeeId ?? this.coffeeId,
      coffeeName: coffeeName ?? this.coffeeName,
      ctaLabel: ctaLabel ?? this.ctaLabel,
      ctaUrl: ctaUrl ?? this.ctaUrl,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
