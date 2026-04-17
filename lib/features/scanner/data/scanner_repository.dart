import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Repository that wraps Google ML Kit text recognition to perform OCR on
/// coffee bag images.
class ScannerRepository {
  ScannerRepository() : _textRecognizer = TextRecognizer();

  final TextRecognizer _textRecognizer;

  /// Processes the image at [imagePath] and returns the recognized text.
  ///
  /// Throws an [Exception] if the image cannot be processed or no text is
  /// found.
  Future<String> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Releases the underlying ML Kit resources. Call this when the repository
  /// is no longer needed.
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
