import 'package:cloud_firestore/cloud_firestore.dart';

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
  final DateTime createdAt;

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
      flavorNotes: (data['flavorNotes'] as List<dynamic>?)
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
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'roaster': roaster,
      'name': name,
      'originCountry': originCountry,
      'originRegion': originRegion,
      'farmName': farmName,
      'farmerName': farmerName,
      'altitude': altitude,
      'variety': variety,
      'processingMethod': processingMethod,
      'roastDate':
          roastDate != null ? Timestamp.fromDate(roastDate!) : null,
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
          photoUrl == other.photoUrl &&
          avgRating == other.avgRating &&
          ratingsCount == other.ratingsCount &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
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
        photoUrl,
        avgRating,
        ratingsCount,
        createdAt,
      );

  @override
  String toString() => 'Coffee(id: $id, name: $name, roaster: $roaster)';
}
