import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Tasting {
  const Tasting({
    required this.id,
    required this.userId,
    this.authorName,
    this.authorAvatar,
    required this.coffeeId,
    required this.coffeeName,
    this.coffeePhotoUrl,
    required this.roasterName,
    required this.brewMethod,
    required this.grindSize,
    required this.doseGrams,
    required this.waterMl,
    required this.ratio,
    required this.brewTimeSec,
    this.waterTempC,
    required this.aroma,
    required this.flavor,
    required this.acidity,
    required this.body,
    required this.sweetness,
    required this.aftertaste,
    required this.overallRating,
    this.flavorNotes = const [],
    this.notes,
    required this.tastingDate,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? authorName;
  final String? authorAvatar;
  final String coffeeId;
  final String coffeeName;
  final String? coffeePhotoUrl;
  final String roasterName;
  final String brewMethod;
  final String grindSize;
  final double doseGrams;
  final double waterMl;
  final String ratio;
  final int brewTimeSec;
  final int? waterTempC;
  final int aroma;
  final int flavor;
  final int acidity;
  final int body;
  final int sweetness;
  final int aftertaste;
  final double overallRating;
  final List<String> flavorNotes;
  final String? notes;
  final DateTime tastingDate;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  factory Tasting.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Tasting(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      authorName: data['authorName'] as String?,
      authorAvatar: data['authorAvatar'] as String?,
      coffeeId: data['coffeeId'] as String? ?? '',
      coffeeName: data['coffeeName'] as String? ?? '',
      coffeePhotoUrl: data['coffeePhotoUrl'] as String?,
      roasterName: data['roasterName'] as String? ?? '',
      brewMethod: data['brewMethod'] as String? ?? '',
      grindSize: data['grindSize'] as String? ?? '',
      doseGrams: (data['doseGrams'] as num?)?.toDouble() ?? 0.0,
      waterMl: (data['waterMl'] as num?)?.toDouble() ?? 0.0,
      ratio: data['ratio'] as String? ?? '',
      brewTimeSec: data['brewTimeSec'] as int? ?? 0,
      waterTempC: data['waterTempC'] as int?,
      aroma: data['aroma'] as int? ?? 3,
      flavor: data['flavor'] as int? ?? 3,
      acidity: data['acidity'] as int? ?? 3,
      body: data['body'] as int? ?? 3,
      sweetness: data['sweetness'] as int? ?? 3,
      aftertaste: data['aftertaste'] as int? ?? 3,
      overallRating: (data['overallRating'] as num?)?.toDouble() ?? 0.0,
      flavorNotes: (data['flavorNotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: data['notes'] as String?,
      tastingDate:
          (data['tastingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'coffeeId': coffeeId,
      'coffeeName': coffeeName,
      'coffeePhotoUrl': coffeePhotoUrl,
      'roasterName': roasterName,
      'brewMethod': brewMethod,
      'grindSize': grindSize,
      'doseGrams': doseGrams,
      'waterMl': waterMl,
      'ratio': ratio,
      'brewTimeSec': brewTimeSec,
      'waterTempC': waterTempC,
      'aroma': aroma,
      'flavor': flavor,
      'acidity': acidity,
      'body': body,
      'sweetness': sweetness,
      'aftertaste': aftertaste,
      'overallRating': overallRating,
      'flavorNotes': flavorNotes,
      'notes': notes,
      'tastingDate': Timestamp.fromDate(tastingDate),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Tasting copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? coffeeId,
    String? coffeeName,
    String? coffeePhotoUrl,
    String? roasterName,
    String? brewMethod,
    String? grindSize,
    double? doseGrams,
    double? waterMl,
    String? ratio,
    int? brewTimeSec,
    int? waterTempC,
    int? aroma,
    int? flavor,
    int? acidity,
    int? body,
    int? sweetness,
    int? aftertaste,
    double? overallRating,
    List<String>? flavorNotes,
    String? notes,
    DateTime? tastingDate,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return Tasting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      coffeeId: coffeeId ?? this.coffeeId,
      coffeeName: coffeeName ?? this.coffeeName,
      coffeePhotoUrl: coffeePhotoUrl ?? this.coffeePhotoUrl,
      roasterName: roasterName ?? this.roasterName,
      brewMethod: brewMethod ?? this.brewMethod,
      grindSize: grindSize ?? this.grindSize,
      doseGrams: doseGrams ?? this.doseGrams,
      waterMl: waterMl ?? this.waterMl,
      ratio: ratio ?? this.ratio,
      brewTimeSec: brewTimeSec ?? this.brewTimeSec,
      waterTempC: waterTempC ?? this.waterTempC,
      aroma: aroma ?? this.aroma,
      flavor: flavor ?? this.flavor,
      acidity: acidity ?? this.acidity,
      body: body ?? this.body,
      sweetness: sweetness ?? this.sweetness,
      aftertaste: aftertaste ?? this.aftertaste,
      overallRating: overallRating ?? this.overallRating,
      flavorNotes: flavorNotes ?? this.flavorNotes,
      notes: notes ?? this.notes,
      tastingDate: tastingDate ?? this.tastingDate,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tasting &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          coffeeId == other.coffeeId &&
          coffeeName == other.coffeeName &&
          roasterName == other.roasterName &&
          brewMethod == other.brewMethod &&
          grindSize == other.grindSize &&
          doseGrams == other.doseGrams &&
          waterMl == other.waterMl &&
          ratio == other.ratio &&
          brewTimeSec == other.brewTimeSec &&
          waterTempC == other.waterTempC &&
          aroma == other.aroma &&
          flavor == other.flavor &&
          acidity == other.acidity &&
          body == other.body &&
          sweetness == other.sweetness &&
          aftertaste == other.aftertaste &&
          overallRating == other.overallRating &&
          listEquals(flavorNotes, other.flavorNotes) &&
          notes == other.notes &&
          tastingDate == other.tastingDate &&
          likesCount == other.likesCount &&
          commentsCount == other.commentsCount &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll([
        id, userId, coffeeId, coffeeName, roasterName,
        brewMethod, grindSize, doseGrams, waterMl, ratio,
        brewTimeSec, waterTempC, aroma, flavor, acidity,
        body, sweetness, aftertaste, overallRating, ...flavorNotes, notes,
        tastingDate, likesCount, commentsCount, createdAt,
      ]);

  @override
  String toString() =>
      'Tasting(id: $id, coffeeName: $coffeeName, overallRating: $overallRating)';
}
