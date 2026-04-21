import 'package:cloud_firestore/cloud_firestore.dart';

class Farm {
  const Farm({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.photoUrl,
    this.country,
    this.region,
    this.farmerName,
    this.altitude,
    this.claimedBy,
    this.claimStatus,
    this.source = 'ai',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? url;
  final String? photoUrl;
  final String? country;
  final String? region;
  final String? farmerName;
  final String? altitude;
  final String? claimedBy;
  final String? claimStatus;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Farm.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Farm(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      url: data['url'] as String?,
      photoUrl: data['photoUrl'] as String?,
      country: data['country'] as String?,
      region: data['region'] as String?,
      farmerName: data['farmerName'] as String?,
      altitude: data['altitude'] as String?,
      claimedBy: data['claimedBy'] as String?,
      claimStatus: data['claimStatus'] as String?,
      source: data['source'] as String? ?? 'ai',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameLower': name.toLowerCase(),
      'description': description,
      'url': url,
      'photoUrl': photoUrl,
      'country': country,
      'region': region,
      'farmerName': farmerName,
      'altitude': altitude,
      'claimedBy': claimedBy,
      'claimStatus': claimStatus,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Farm copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? photoUrl,
    String? country,
    String? region,
    String? farmerName,
    String? altitude,
    String? claimedBy,
    String? claimStatus,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      photoUrl: photoUrl ?? this.photoUrl,
      country: country ?? this.country,
      region: region ?? this.region,
      farmerName: farmerName ?? this.farmerName,
      altitude: altitude ?? this.altitude,
      claimedBy: claimedBy ?? this.claimedBy,
      claimStatus: claimStatus ?? this.claimStatus,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
