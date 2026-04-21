import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

/// Suggested brew parameters returned by Gemini.
class BrewSuggestion {
  const BrewSuggestion({
    required this.brewMethod,
    required this.grindSize,
    required this.doseGrams,
    required this.waterMl,
    required this.waterTempC,
    required this.brewTimeSec,
    this.tips,
  });

  final String brewMethod;
  final String grindSize;
  final double doseGrams;
  final double waterMl;
  final int waterTempC;
  final int brewTimeSec;
  final String? tips;

  factory BrewSuggestion.fromJson(Map<String, dynamic> json) {
    return BrewSuggestion(
      brewMethod: json['brew_method'] as String,
      grindSize: json['grind_size'] as String,
      doseGrams: (json['dose_grams'] as num).toDouble(),
      waterMl: (json['water_ml'] as num).toDouble(),
      waterTempC: (json['water_temp_c'] as num).toInt(),
      brewTimeSec: (json['brew_time_sec'] as num).toInt(),
      tips: json['tips'] as String?,
    );
  }
}

/// Service that asks Gemini to suggest optimal brew parameters for a given
/// coffee based on its characteristics.
class BrewSuggestionService {
  BrewSuggestionService()
      : _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  final String _apiKey;

  static const _systemPrompt = '''
You are a specialty coffee brewing expert. Given information about a coffee (name, origin, variety, processing method, roast level), suggest optimal brew parameters. Return ONLY valid JSON with these fields:
{
  "brew_method": "one of: V60, Espresso, AeroPress, French Press, Chemex, Moka Pot, Cold Brew, Siphon, Turkish Coffee, Pour Over (Other), Other",
  "grind_size": "one of: Extra Fine, Fine, Medium-Fine, Medium, Medium-Coarse, Coarse, Extra Coarse",
  "dose_grams": number,
  "water_ml": number,
  "water_temp_c": integer,
  "brew_time_sec": integer,
  "tips": "string with one or two short sentences of brewing tips specific to this coffee, or null"
}
Choose the brew method and parameters that best highlight the coffee's characteristics. For example, light-roast washed Ethiopian coffees shine with pour-over methods, while dark-roast Brazilian naturals may suit French Press or espresso. Do not include any text outside the JSON object.''';

  /// Suggests brew parameters based on the provided coffee characteristics.
  Future<BrewSuggestion> suggest({
    required String name,
    String? originCountry,
    String? originRegion,
    String? variety,
    String? processingMethod,
    String? roastLevel,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is not set. '
        'Pass it at build time with --dart-define=GEMINI_API_KEY=<key>',
      );
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.3,
        responseMimeType: 'application/json',
      ),
    );

    final description = StringBuffer()
      ..writeln('Coffee name: $name');
    if (originCountry != null && originCountry.isNotEmpty) {
      description.writeln('Origin country: $originCountry');
    }
    if (originRegion != null && originRegion.isNotEmpty) {
      description.writeln('Origin region: $originRegion');
    }
    if (variety != null && variety.isNotEmpty) {
      description.writeln('Variety: $variety');
    }
    if (processingMethod != null && processingMethod.isNotEmpty) {
      description.writeln('Processing method: $processingMethod');
    }
    if (roastLevel != null && roastLevel.isNotEmpty) {
      description.writeln('Roast level: $roastLevel');
    }

    final response = await model.generateContent([
      Content.text(description.toString()),
    ]);

    final text = response.text;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty response');
    }

    final json = jsonDecode(text) as Map<String, dynamic>;
    return BrewSuggestion.fromJson(json);
  }
}
