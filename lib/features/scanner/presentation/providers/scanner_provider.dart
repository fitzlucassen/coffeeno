import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/gemini_service.dart';
import '../../data/scanner_repository.dart';
import '../../domain/scan_result.dart';

// ── Repository & service providers ──────────────────────────────────────────

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final repo = ScannerRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

// ── Scan flow state ─────────────────────────────────────────────────────────

enum ScanStatus {
  idle,
  capturing,
  processingOcr,
  extractingWithAi,
  done,
  error,
}

class ScanState {
  const ScanState({
    this.status = ScanStatus.idle,
    this.result,
    this.errorMessage,
  });

  final ScanStatus status;
  final ScanResult? result;
  final String? errorMessage;

  ScanState copyWith({
    ScanStatus? status,
    ScanResult? result,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ScanStateNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<void> processImage(String imagePath) async {
    try {
      state = const ScanState(status: ScanStatus.processingOcr);

      final repository = ref.read(scannerRepositoryProvider);
      final ocrText = await repository.processImage(imagePath);

      if (ocrText.trim().isEmpty) {
        state = const ScanState(
          status: ScanStatus.error,
          errorMessage:
              'No text found in the image. Try again with a clearer photo.',
        );
        return;
      }

      state = state.copyWith(status: ScanStatus.extractingWithAi);

      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      final geminiService = ref.read(geminiServiceProvider);
      final result = await geminiService.extractCoffeeData(
        ocrText: ocrText,
        imageBytes: imageBytes,
      );

      state = ScanState(status: ScanStatus.done, result: result);
    } catch (e) {
      state = ScanState(status: ScanStatus.error, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const ScanState();
  }
}

final scanStateProvider = NotifierProvider<ScanStateNotifier, ScanState>(
  ScanStateNotifier.new,
);
