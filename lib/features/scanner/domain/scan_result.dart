import 'dart:convert';

/// Model representing structured data extracted from a coffee bag scan.
class ScanResult {
  const ScanResult({
    this.roaster,
    this.name,
    this.originCountry,
    this.originRegion,
    this.farmName,
    this.farmerName,
    this.altitude,
    this.variety,
    this.processingMethod,
    this.roastDate,
    this.roastLevel,
    this.flavorNotes = const [],
    this.additionalInfo,
    required this.rawOcrText,
  });

  final String? roaster;
  final String? name;
  final String? originCountry;
  final String? originRegion;
  final String? farmName;
  final String? farmerName;
  final String? altitude;
  final String? variety;
  final String? processingMethod;
  final String? roastDate;
  final String? roastLevel;
  final List<String> flavorNotes;
  final String? additionalInfo;
  final String rawOcrText;

  /// Creates a [ScanResult] from a JSON map returned by the Gemini API.
  factory ScanResult.fromJson(Map<String, dynamic> json, {String rawOcrText = ''}) {
    return ScanResult(
      roaster: json['roaster'] as String?,
      name: json['name'] as String?,
      originCountry: json['origin_country'] as String?,
      originRegion: json['origin_region'] as String?,
      farmName: json['farm_name'] as String?,
      farmerName: json['farmer_name'] as String?,
      altitude: json['altitude'] as String?,
      variety: json['variety'] as String?,
      processingMethod: json['processing_method'] as String?,
      roastDate: json['roast_date'] as String?,
      roastLevel: json['roast_level'] as String?,
      flavorNotes: (json['flavor_notes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      additionalInfo: json['additional_info'] as String?,
      rawOcrText: rawOcrText,
    );
  }

  /// Parses a JSON string response (potentially with markdown fences) into
  /// a [ScanResult].
  factory ScanResult.fromJsonString(String jsonString, {String rawOcrText = ''}) {
    // Strip markdown code fences if present.
    var cleaned = jsonString.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```[a-z]*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```$'), '');
    }
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return ScanResult.fromJson(map, rawOcrText: rawOcrText);
  }

  Map<String, dynamic> toJson() => {
        'roaster': roaster,
        'name': name,
        'origin_country': originCountry,
        'origin_region': originRegion,
        'farm_name': farmName,
        'farmer_name': farmerName,
        'altitude': altitude,
        'variety': variety,
        'processing_method': processingMethod,
        'roast_date': roastDate,
        'roast_level': roastLevel,
        'flavor_notes': flavorNotes,
        'additional_info': additionalInfo,
      };

  ScanResult copyWith({
    String? roaster,
    String? name,
    String? originCountry,
    String? originRegion,
    String? farmName,
    String? farmerName,
    String? altitude,
    String? variety,
    String? processingMethod,
    String? roastDate,
    String? roastLevel,
    List<String>? flavorNotes,
    String? additionalInfo,
    String? rawOcrText,
  }) {
    return ScanResult(
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
      additionalInfo: additionalInfo ?? this.additionalInfo,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }

  @override
  String toString() => 'ScanResult(roaster: $roaster, name: $name, '
      'originCountry: $originCountry, flavorNotes: $flavorNotes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResult &&
          runtimeType == other.runtimeType &&
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
          additionalInfo == other.additionalInfo &&
          rawOcrText == other.rawOcrText;

  @override
  int get hashCode => Object.hash(
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
        additionalInfo,
        rawOcrText,
      );
}
