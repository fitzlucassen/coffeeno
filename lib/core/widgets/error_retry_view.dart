import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// Centered error state with an icon, message and optional retry button.
///
/// Replaces the near-identical error scaffolds that were duplicated across the
/// map, origin-detail and stats screens.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({super.key, this.message, this.onRetry});

  /// Overrides the default localized "something went wrong" message.
  final String? message;

  /// When non-null, a retry button is shown that invokes this callback.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
          const SizedBox(height: 12),
          Text(message ?? l10n.error, style: textTheme.titleMedium),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}
