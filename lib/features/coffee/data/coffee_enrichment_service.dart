import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class CoffeeEnrichmentResult {
  const CoffeeEnrichmentResult({
    this.roasterUrl,
    this.roasterDescription,
    this.roasterCountry,
    this.roasterCity,
    this.roasterKeyPeople,
    this.farmUrl,
    this.farmDescription,
    this.farmRegion,
    this.farmFarmerName,
    this.farmAltitude,
  });

  final String? roasterUrl;
  final String? roasterDescription;
  final String? roasterCountry;
  final String? roasterCity;
  final String? roasterKeyPeople;
  final String? farmUrl;
  final String? farmDescription;
  final String? farmRegion;
  final String? farmFarmerName;
  final String? farmAltitude;

  bool get isEmpty =>
      roasterUrl == null &&
      roasterDescription == null &&
      roasterCountry == null &&
      roasterCity == null &&
      farmUrl == null &&
      farmDescription == null;
}

class CoffeeEnrichmentService {
  CoffeeEnrichmentService()
      : _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  final String _apiKey;

  bool get isAvailable => _apiKey.isNotEmpty;

  static const _systemPrompt = '''
You are a specialty coffee knowledge assistant. Given a coffee roaster name and optionally a farm name, country, and region, provide factual information.

Return ONLY valid JSON:
{
  "roaster_url": "string or null",
  "roaster_description": "string or null",
  "roaster_country": "string or null",
  "roaster_city": "string or null",
  "roaster_key_people": "string or null",
  "farm_url": "string or null",
  "farm_description": "string or null",
  "farm_region": "string or null",
  "farm_farmer_name": "string or null",
  "farm_altitude": "string or null"
}

Rules:
- For descriptions: always try to provide a 1-2 sentence description. Most specialty coffee roasters and farms have some public information. Describe what they are known for, their location, or their philosophy.
- For URLs: provide the official website URL if you know it. Use null only if you truly have no idea.
- For key_people: list notable founders or key figures, comma-separated.
- Use JSON null (not the string "null") when a value is unknown.
- Do not invent URLs, but do your best for descriptions.
- Do not include any text outside the JSON object.''';

  Future<CoffeeEnrichmentResult> lookupInfo({
    required String roaster,
    String? farmName,
    String? originCountry,
    String? originRegion,
  }) async {
    if (_apiKey.isEmpty) return const CoffeeEnrichmentResult();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(_systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

      final parts = <String>['Roaster: $roaster'];
      if (farmName != null && farmName.isNotEmpty) {
        parts.add('Farm: $farmName');
      }
      if (originCountry != null && originCountry.isNotEmpty) {
        parts.add('Country: $originCountry');
      }
      if (originRegion != null && originRegion.isNotEmpty) {
        parts.add('Region: $originRegion');
      }

      final response = await model.generateContent([
        Content.text(parts.join('\n')),
      ]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return const CoffeeEnrichmentResult();
      }

      final json = jsonDecode(text) as Map<String, dynamic>;

      String? cleanString(dynamic value) {
        if (value == null) return null;
        final s = value.toString().trim();
        if (s.isEmpty || s == 'null') return null;
        return s;
      }

      return CoffeeEnrichmentResult(
        roasterUrl: cleanString(json['roaster_url']),
        roasterDescription: cleanString(json['roaster_description']),
        roasterCountry: cleanString(json['roaster_country']),
        roasterCity: cleanString(json['roaster_city']),
        roasterKeyPeople: cleanString(json['roaster_key_people']),
        farmUrl: cleanString(json['farm_url']),
        farmDescription: cleanString(json['farm_description']),
        farmRegion: cleanString(json['farm_region']),
        farmFarmerName: cleanString(json['farm_farmer_name']),
        farmAltitude: cleanString(json['farm_altitude']),
      );
    } catch (e) {
      debugPrint('[COFFEENO] Enrichment parse error: $e');
      return const CoffeeEnrichmentResult();
    }
  }
}
