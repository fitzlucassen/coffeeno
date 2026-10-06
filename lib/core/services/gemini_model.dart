import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

/// Gemini model used by every AI feature (scan extraction, enrichment, brew
/// suggestions).
const geminiModelName = 'gemini-2.5-flash';

/// Whether AI features can run. They go through Firebase, so they are
/// unavailable when the app started without it (see `main.dart`).
bool get isGeminiAvailable => Firebase.apps.isNotEmpty;

/// Builds a Gemini model that answers in JSON, routed through Firebase AI
/// Logic on the `coffeeno` project.
///
/// No Gemini API key ships in the app binary. Firebase AI attaches the App
/// Check token (activated in `main.dart`) and the signed-in user's ID token to
/// every request, and App Check enforcement on the Firebase AI Logic API
/// rejects calls that don't come from a genuine Coffeeno install. Limited-use
/// tokens are minted per request, which is what App Check replay protection
/// relies on, so a token lifted from a device is worth one call at most once
/// Firebase enforces it.
GenerativeModel createJsonGeminiModel({
  required String systemPrompt,
  required double temperature,
}) {
  return FirebaseAI.googleAI(useLimitedUseAppCheckTokens: true).generativeModel(
    model: geminiModelName,
    systemInstruction: Content.system(systemPrompt),
    generationConfig: GenerationConfig(
      temperature: temperature,
      responseMimeType: 'application/json',
    ),
  );
}
