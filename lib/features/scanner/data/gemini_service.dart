import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

import '../../../core/services/gemini_model.dart';
import '../domain/scan_result.dart';

/// Service that sends OCR text (and optionally the original image) to
/// Gemini and parses the structured coffee data response.
class GeminiService {
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
Rules:
- origin_country MUST always be in English (e.g. "Ethiopia" not "Éthiopie", "Brazil" not "Brésil").
- flavor_notes should be in English.
- Do not include any text outside the JSON object.''';

  /// Extracts structured coffee bag data from [ocrText].
  ///
  /// If [imageBytes] is provided, the image is also sent alongside the text
  /// to give the model additional visual context.
  Future<ScanResult> extractCoffeeData({
    required String ocrText,
    Uint8List? imageBytes,
  }) async {
    final model = createJsonGeminiModel(
      systemPrompt: _systemPrompt,
      temperature: 0.1,
    );

    final parts = <Part>[];

    // Optionally include the image for better extraction.
    if (imageBytes != null) {
      parts.add(InlineDataPart('image/jpeg', imageBytes));
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
