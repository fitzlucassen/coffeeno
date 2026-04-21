import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class CoffeeEnrichmentResult {
  const CoffeeEnrichmentResult({
    this.roasterUrl,
    this.roasterDescription,
    this.farmUrl,
    this.farmDescription,
  });

  final String? roasterUrl;
  final String? roasterDescription;
  final String? farmUrl;
  final String? farmDescription;

  bool get isEmpty =>
      roasterUrl == null &&
      roasterDescription == null &&
      farmUrl == null &&
      farmDescription == null;
}

class CoffeeEnrichmentService {
  CoffeeEnrichmentService()
      : _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  final String _apiKey;

  static const _systemPrompt = '''
You are a specialty coffee knowledge assistant. Given a coffee roaster name and optionally a farm name, country, and region, provide factual information.

Return ONLY valid JSON:
{
  "roaster_url": "official website URL or null if unknown",
  "roaster_description": "1-2 sentence description of the roaster or null",
  "farm_url": "official website URL or null if unknown",
  "farm_description": "1-2 sentence description of the farm or null"
}

Only include URLs you are confident are correct. Only provide descriptions you are confident about.
Do not invent or hallucinate information. If unsure, use null.
Do not include any text outside the JSON object.''';

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

      return CoffeeEnrichmentResult(
        roasterUrl: json['roaster_url'] as String?,
        roasterDescription: json['roaster_description'] as String?,
        farmUrl: json['farm_url'] as String?,
        farmDescription: json['farm_description'] as String?,
      );
    } catch (_) {
      return const CoffeeEnrichmentResult();
    }
  }
}
