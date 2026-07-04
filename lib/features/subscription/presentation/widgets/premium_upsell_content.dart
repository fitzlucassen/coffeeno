import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

/// Shared "upgrade to premium" upsell block: a premium icon, the
/// [AppLocalizations.premiumRequired] title, a caller-provided [description],
/// and an upgrade button.
///
/// Used by both [PremiumGate] and the upgrade-prompt bottom sheet, which differ
/// only in cosmetic details (button width, spacing) and what tapping upgrade
/// does — captured by [onUpgrade], [fullWidthButton] and [buttonSpacing].
class PremiumUpsellContent extends StatelessWidget {
  const PremiumUpsellContent({
    super.key,
    required this.description,
    required this.onUpgrade,
    this.fullWidthButton = false,
    this.buttonSpacing = 16,
  });

  /// Body text shown under the title.
  final String description;

  /// Invoked when the upgrade button is tapped.
  final VoidCallback onUpgrade;

  /// Whether the upgrade button stretches to the full available width.
  final bool fullWidthButton;

  /// Vertical gap between the description and the upgrade button.
  final double buttonSpacing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final button = FilledButton(
      onPressed: onUpgrade,
      child: Text(l10n.upgradeToPremium),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.workspace_premium_rounded,
          size: 48,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(l10n.premiumRequired, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: buttonSpacing),
        fullWidthButton
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ],
    );
  }
}
