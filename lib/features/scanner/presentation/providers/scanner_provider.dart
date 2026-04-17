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
    this.imagePath,
  });

  final ScanStatus status;
  final ScanResult? result;
  final String? errorMessage;
  final String? imagePath;

  ScanState copyWith({
    ScanStatus? status,
    ScanResult? result,
    String? errorMessage,
    String? imagePath,
  }) {
    return ScanState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ScanStateNotifier extends StateNotifier<ScanState> {
  ScanStateNotifier(this._repository, this._geminiService)
      : super(const ScanState());

  final ScannerRepository _repository;
  final GeminiService _geminiService;

  /// Runs the full scan pipeline: OCR then AI extraction.
  Future<void> processImage(String imagePath) async {
    try {
      state = ScanState(status: ScanStatus.processingOcr, imagePath: imagePath);

      // Step 1 — OCR
      final ocrText = await _repository.processImage(imagePath);

      if (ocrText.trim().isEmpty) {
        state = const ScanState(
          status: ScanStatus.error,
          errorMessage: 'No text found in the image. Try again with a clearer photo.',
        );
        return;
      }

      // Step 2 — AI extraction
      state = state.copyWith(status: ScanStatus.extractingWithAi);

      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      final result = await _geminiService.extractCoffeeData(
        ocrText: ocrText,
        imageBytes: imageBytes,
      );

      state = ScanState(
        status: ScanStatus.done,
        result: result,
        imagePath: imagePath,
      );
    } catch (e) {
      state = ScanState(
        status: ScanStatus.error,
        errorMessage: e.toString(),
        imagePath: imagePath,
      );
    }
  }

  /// Resets the scan state so the user can try again.
  void reset() {
    state = const ScanState();
  }
}

final scanStateProvider =
    StateNotifierProvider<ScanStateNotifier, ScanState>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  final geminiService = ref.watch(geminiServiceProvider);
  return ScanStateNotifier(repository, geminiService);
});
