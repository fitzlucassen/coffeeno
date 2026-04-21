import 'package:cloud_firestore/cloud_firestore.dart';

class Roaster {
  const Roaster({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.photoUrl,
    this.country,
    this.city,
    this.keyPeople,
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
  final String? city;
  final String? keyPeople;
  final String? claimedBy;
  final String? claimStatus;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Roaster.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Roaster(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      url: data['url'] as String?,
      photoUrl: data['photoUrl'] as String?,
      country: data['country'] as String?,
      city: data['city'] as String?,
      keyPeople: data['keyPeople'] as String?,
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
      'city': city,
      'keyPeople': keyPeople,
      'claimedBy': claimedBy,
      'claimStatus': claimStatus,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Roaster copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? photoUrl,
    String? country,
    String? city,
    String? keyPeople,
    String? claimedBy,
    String? claimStatus,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Roaster(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      photoUrl: photoUrl ?? this.photoUrl,
      country: country ?? this.country,
      city: city ?? this.city,
      keyPeople: keyPeople ?? this.keyPeople,
      claimedBy: claimedBy ?? this.claimedBy,
      claimStatus: claimStatus ?? this.claimStatus,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
