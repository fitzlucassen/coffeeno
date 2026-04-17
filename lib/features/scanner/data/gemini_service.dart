import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../domain/scan_result.dart';

/// Service that sends OCR text (and optionally the original image) to
/// Gemini 2.0 Flash and parses the structured coffee data response.
class GeminiService {
  GeminiService()
      : _apiKey = const String.fromEnvironment('GEMINI_API_KEY');

  final String _apiKey;

  static const _systemPrompt = '''
You are a coffee bag data extractor. Given OCR text from a coffee bag, extract structured data. Return ONLY valid JSON with these fields:
{
  "roaster": "string or null",
  "name": "string or null",
  "origin_country": "string or null",
  "origin_region": "string or null",
  "farm_name": "string or null",
  "farmer_name": "string or null",
  "altitude": "string or null",
  "variety": "string or null",
  "processing_method": "string or null",
  "roast_date": "string (ISO 8601) or null",
  "roast_level": "light|medium|medium-dark|dark or null",
  "flavor_notes": ["string"] or [],
  "additional_info": "string or null"
}
Do not include any text outside the JSON object.''';

  /// Extracts structured coffee bag data from [ocrText].
  ///
  /// If [imageBytes] is provided, the image is also sent alongside the text
  /// to give the model additional visual context.
  Future<ScanResult> extractCoffeeData({
    required String ocrText,
    Uint8List? imageBytes,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GEMINI_API_KEY is not set. '
        'Pass it at build time with --dart-define=GEMINI_API_KEY=<key>',
      );
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.1,
        responseMimeType: 'application/json',
      ),
    );

    final parts = <Part>[];

    // Optionally include the image for better extraction.
    if (imageBytes != null) {
      parts.add(DataPart('image/jpeg', imageBytes));
    }

    parts.add(TextPart('OCR text from coffee bag:\n\n$ocrText'));

    final response = await model.generateContent([Content.multi(parts)]);
    final text = response.text;

    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty response');
    }

    return ScanResult.fromJsonString(text, rawOcrText: ocrText);
  }
}
