import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A coffee's freshness relative to its roast date. The UI maps each stage to
/// a localized label and color; keeping this a typed enum (rather than raw
/// English strings) avoids stringly-typed switches at the call sites.
enum FreshnessStage { resting, peak, useSoon, pastPeak }

/// Normalizes text for case- and diacritic-insensitive matching.
String normalizeText(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâãäå]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[ñ]'), 'n')
      .replaceAll(RegExp(r'[ç]'), 'c');
}

/// Builds the canonical identity key for a coffee from its roaster, name and
/// origin country. Two coffees with the same key are considered "the same
/// coffee" (a re-bought bag), regardless of roast date / lot. Stored on each
/// coffee doc as `canonicalKey` so the library can detect re-buys with a single
/// indexed equality query.
String coffeeCanonicalKey({
  required String roaster,
  required String name,
  required String originCountry,
}) {
  return '${normalizeText(roaster)}|${normalizeText(name)}|'
      '${normalizeText(originCountry)}';
}

class Coffee {
  const Coffee({
    required this.id,
    required this.uid,
    required this.roaster,
    required this.name,
    required this.originCountry,
    this.originRegion,
    this.farmName,
    this.farmerName,
    this.altitude,
    this.variety,
    this.processingMethod,
    this.roastDate,
    this.roastLevel,
    this.flavorNotes = const [],
    this.photoUrl,
    this.avgRating = 0.0,
    this.ratingsCount = 0,
    this.roasterUrl,
    this.roasterDescription,
    this.farmUrl,
    this.farmDescription,
    this.roasterId,
    this.farmId,
    this.price,
    this.lot,
    this.harvestYear,
    this.freshnessNotified = false,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String roaster;
  final String name;
  final String originCountry;
  final String? originRegion;
  final String? farmName;
  final String? farmerName;
  final String? altitude;
  final String? variety;
  final String? processingMethod;
  final DateTime? roastDate;
  final String? roastLevel;
  final List<String> flavorNotes;
  final String? photoUrl;
  final double avgRating;
  final int ratingsCount;
  final String? roasterUrl;
  final String? roasterDescription;
  final String? farmUrl;
  final String? farmDescription;
  final String? roasterId;
  final String? farmId;
  final double? price;
  final String? lot;
  final int? harvestYear;
  final bool freshnessNotified;
  final DateTime createdAt;

  int? get daysSinceRoast {
    if (roastDate == null) return null;
    return DateTime.now().difference(roastDate!).inDays;
  }

  /// The end of the peak-freshness window, in days from roast, varying by
  /// roast level. Single source of truth shared by [freshnessStage] and the
  /// freshness notification scheduler.
  /// This coffee's canonical identity key (roaster + name + origin, normalized).
  /// See [coffeeCanonicalKey].
  String get canonicalKey => coffeeCanonicalKey(
    roaster: roaster,
    name: name,
    originCountry: originCountry,
  );

  int get peakEndDays {
    final level = roastLevel?.toLowerCase() ?? '';
    if (level.contains('light')) return 21;
    if (level.contains('dark')) return 14;
    return 18;
  }

  /// The coffee's current freshness stage, or null when no roast date is known.
  ///
  /// Derived from [peakEndDays] so the in-app label and the notification timing
  /// agree: ~first quarter is resting, up to peakEnd is peak, a short grace
  /// window past that is "use soon", then past peak.
  FreshnessStage? get freshnessStage {
    final days = daysSinceRoast;
    if (days == null) return null;
    if (days < peakEndDays ~/ 4) return FreshnessStage.resting;
    if (days <= peakEndDays) return FreshnessStage.peak;
    if (days <= peakEndDays + 14) return FreshnessStage.useSoon;
    return FreshnessStage.pastPeak;
  }

  factory Coffee.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Coffee(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      roaster: data['roaster'] as String? ?? '',
      name: data['name'] as String? ?? '',
      originCountry: data['originCountry'] as String? ?? '',
      originRegion: data['originRegion'] as String?,
      farmName: data['farmName'] as String?,
      farmerName: data['farmerName'] as String?,
      altitude: data['altitude'] as String?,
      variety: data['variety'] as String?,
      processingMethod: data['processingMethod'] as String?,
      roastDate: (data['roastDate'] as Timestamp?)?.toDate(),
      roastLevel: data['roastLevel'] as String?,
      flavorNotes:
          (data['flavorNotes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photoUrl: data['photoUrl'] as String?,
      avgRating: (data['avgRating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: data['ratingsCount'] as int? ?? 0,
      roasterUrl: data['roasterUrl'] as String?,
      roasterDescription: data['roasterDescription'] as String?,
      farmUrl: data['farmUrl'] as String?,
      farmDescription: data['farmDescription'] as String?,
      roasterId: data['roasterId'] as String?,
      farmId: data['farmId'] as String?,
      price: (data['price'] as num?)?.toDouble(),
      lot: data['lot'] as String?,
      harvestYear: data['harvestYear'] as int?,
      freshnessNotified: data['freshnessNotified'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'roaster': roaster,
      'roasterNormalized': normalizeText(roaster),
      'name': name,
      'nameNormalized': normalizeText(name),
      'canonicalKey': canonicalKey,
      'originCountry': originCountry,
      'originRegion': originRegion,
      'farmName': farmName,
      'farmerName': farmerName,
      'altitude': altitude,
      'variety': variety,
      'processingMethod': processingMethod,
      'roastDate': roastDate != null ? Timestamp.fromDate(roastDate!) : null,
      'roastLevel': roastLevel,
      'flavorNotes': flavorNotes,
      'photoUrl': photoUrl,
      'avgRating': avgRating,
      'ratingsCount': ratingsCount,
      'roasterUrl': roasterUrl,
      'roasterDescription': roasterDescription,
      'farmUrl': farmUrl,
      'farmDescription': farmDescription,
      'roasterId': roasterId,
      'farmId': farmId,
      'price': price,
      'lot': lot,
      'harvestYear': harvestYear,
      'freshnessNotified': freshnessNotified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Coffee copyWith({
    String? id,
    String? uid,
    String? roaster,
    String? name,
    String? originCountry,
    String? originRegion,
    String? farmName,
    String? farmerName,
    String? altitude,
    String? variety,
    String? processingMethod,
    DateTime? roastDate,
    String? roastLevel,
    List<String>? flavorNotes,
    String? photoUrl,
    double? avgRating,
    int? ratingsCount,
    String? roasterUrl,
    String? roasterDescription,
    String? farmUrl,
    String? farmDescription,
    String? roasterId,
    String? farmId,
    double? price,
    String? lot,
    int? harvestYear,
    bool? freshnessNotified,
    DateTime? createdAt,
  }) {
    return Coffee(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      roaster: roaster ?? this.roaster,
      name: name ?? this.name,
      originCountry: originCountry ?? this.originCountry,
      originRegion: originRegion ?? this.originRegion,
      farmName: farmName ?? this.farmName,
      farmerName: farmerName ?? this.farmerName,
      altitude: altitude ?? this.altitude,
      variety: variety ?? this.variety,
      processingMethod: processingMethod ?? this.processingMethod,
      roastDate: roastDate ?? this.roastDate,
      roastLevel: roastLevel ?? this.roastLevel,
      flavorNotes: flavorNotes ?? this.flavorNotes,
      photoUrl: photoUrl ?? this.photoUrl,
      avgRating: avgRating ?? this.avgRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      roasterUrl: roasterUrl ?? this.roasterUrl,
      roasterDescription: roasterDescription ?? this.roasterDescription,
      farmUrl: farmUrl ?? this.farmUrl,
      farmDescription: farmDescription ?? this.farmDescription,
      roasterId: roasterId ?? this.roasterId,
      farmId: farmId ?? this.farmId,
      price: price ?? this.price,
      lot: lot ?? this.lot,
      harvestYear: harvestYear ?? this.harvestYear,
      freshnessNotified: freshnessNotified ?? this.freshnessNotified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coffee &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          uid == other.uid &&
          roaster == other.roaster &&
          name == other.name &&
          originCountry == other.originCountry &&
          originRegion == other.originRegion &&
          farmName == other.farmName &&
          farmerName == other.farmerName &&
          altitude == other.altitude &&
          variety == other.variety &&
          processingMethod == other.processingMethod &&
          roastDate == other.roastDate &&
          roastLevel == other.roastLevel &&
          listEquals(flavorNotes, other.flavorNotes) &&
          photoUrl == other.photoUrl &&
          avgRating == other.avgRating &&
          ratingsCount == other.ratingsCount &&
          roasterUrl == other.roasterUrl &&
          roasterDescription == other.roasterDescription &&
          farmUrl == other.farmUrl &&
          farmDescription == other.farmDescription &&
          roasterId == other.roasterId &&
          farmId == other.farmId &&
          price == other.price &&
          lot == other.lot &&
          harvestYear == other.harvestYear &&
          freshnessNotified == other.freshnessNotified &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    uid,
    roaster,
    name,
    originCountry,
    originRegion,
    farmName,
    farmerName,
    altitude,
    variety,
    processingMethod,
    roastDate,
    roastLevel,
    Object.hashAll(flavorNotes),
    photoUrl,
    avgRating,
    ratingsCount,
    roasterUrl,
    roasterDescription,
    farmUrl,
    farmDescription,
    roasterId,
    farmId,
    price,
    lot,
    harvestYear,
    freshnessNotified,
    createdAt,
  ]);

  @override
  String toString() => 'Coffee(id: $id, name: $name, roaster: $roaster)';
}
