import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../subscription/presentation/widgets/premium_gate.dart';
import '../providers/scan_quota_provider.dart';
import '../providers/scanner_provider.dart';

/// Screen that lets the user capture a photo of a coffee bag and runs the
/// OCR + AI extraction pipeline.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final _picker = ImagePicker();
  bool _hasLaunched = false;

  @override
  void initState() {
    super.initState();
    // Reset any previous scan state when entering the screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanStateProvider.notifier).reset();
    });
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      maxWidth: 2048,
    );

    if (pickedFile == null) return; // User cancelled.

    await ref.read(scanStateProvider.notifier).processImage(pickedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scanState = ref.watch(scanStateProvider);

    final isPremium = ref.watch(isPremiumProvider);

    // Listen for state changes and navigate on success. For free-tier users
    // this is also where we burn one scan from the monthly quota — we only
    // count scans the pipeline actually completed, so a camera cancel or OCR
    // failure doesn't cost the user a credit.
    ref.listen<ScanState>(scanStateProvider, (prev, next) {
      if (next.status == ScanStatus.done && next.result != null) {
        if (!isPremium) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            ref
                .read(scanQuotaRepositoryProvider)
                .recordScan(uid)
                .then((_) => ref.invalidate(remainingFreeScansProvider));
          }
        }
        context.push(AppRoutes.scanReview, extra: next.result);
      }
    });

    // Free users are allowed in as long as they have quota left. Watching
    // the future here keeps the gate reactive to quota resets.
    if (!isPremium) {
      final remainingAsync = ref.watch(remainingFreeScansProvider);
      final outOfQuota = remainingAsync.maybeWhen(
        data: (remaining) => remaining <= 0,
        orElse: () => false,
      );
      if (outOfQuota) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            title: Text(l10n.scanCoffee),
          ),
          body: const PremiumGate(child: SizedBox.shrink()),
        );
      }
    }

    // Auto-launch camera once when the screen first builds.
    if (!_hasLaunched && scanState.status == ScanStatus.idle) {
      _hasLaunched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureImage());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.scanCoffee),
      ),
      body: _buildBody(context, scanState, l10n, colors),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ScanState scanState,
    AppLocalizations l10n,
    ColorScheme colors,
  ) {
    switch (scanState.status) {
      case ScanStatus.idle:
      case ScanStatus.capturing:
        return _buildIdleView(context, l10n, colors);

      case ScanStatus.processingOcr:
        return _buildLoadingView(
          context,
          l10n.scanning,
          colors,
        );

      case ScanStatus.extractingWithAi:
        return _buildLoadingView(
          context,
          l10n.extractingInfo,
          colors,
        );

      case ScanStatus.done:
        // Brief flash before navigation occurs.
        return _buildLoadingView(context, l10n.extractingInfo, colors);

      case ScanStatus.error:
        return _buildErrorView(context, scanState, l10n, colors);
    }
  }

  Widget _buildIdleView(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 56,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.scanCoffee,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.scanHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!ref.watch(isPremiumProvider)) ...[
              const SizedBox(height: 16),
              _QuotaBadge(
                remainingAsync: ref.watch(remainingFreeScansProvider),
              ),
            ],
            const SizedBox(height: 40),
            AppButton(
              label: l10n.scanCoffee,
              icon: Icons.camera_alt_rounded,
              onPressed: _captureImage,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.cancel,
              variant: AppButtonVariant.text,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(
    BuildContext context,
    String message,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    ScanState scanState,
    AppLocalizations l10n,
    ColorScheme colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.error,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              scanState.errorMessage ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: l10n.retry,
              icon: Icons.refresh_rounded,
              onPressed: _captureImage,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.cancel,
              variant: AppButtonVariant.text,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaBadge extends StatelessWidget {
  const _QuotaBadge({required this.remainingAsync});

  final AsyncValue<int> remainingAsync;

  @override
  Widget build(BuildContext context) {
    final remaining = remainingAsync.maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );
    if (remaining == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isOut = remaining <= 0;
    final fg = isOut ? colors.error : colors.primary;
    final bg = (isOut ? colors.error : colors.primary).withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOut ? Icons.lock_outline_rounded : Icons.bolt_rounded,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).freeScansLeft(remaining),
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
