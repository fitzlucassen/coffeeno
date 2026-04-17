import 'package:flutter/material.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo / Brand ──
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.terracottaLight.withValues(alpha: 0.15)
                      : AppColors.terracottaMuted.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.coffee_rounded,
                  size: 48,
                  color: isDark
                      ? AppColors.terracottaLight
                      : AppColors.terracotta,
                ),
              ),
              const SizedBox(height: 24),

              // ── App Name ──
              Text(
                l10n.appTitle,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // ── Subtitle ──
              Text(
                l10n.welcomeSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(flex: 3),

              // ── Sign In Button ──
              AppButton(
                label: l10n.signIn,
                onPressed: () => context.push(AppRoutes.signIn),
              ),
              const SizedBox(height: 12),

              // ── Sign Up Button ──
              AppButton(
                label: l10n.signUp,
                variant: AppButtonVariant.secondary,
                onPressed: () => context.push(AppRoutes.signUp),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
