import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              )
            : Text(label);

    final effectiveOnPressed = isLoading
        ? null
        : onPressed != null
            ? () {
                HapticFeedback.lightImpact();
                onPressed!();
              }
            : null;

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

enum AppButtonVariant { primary, secondary, text }
