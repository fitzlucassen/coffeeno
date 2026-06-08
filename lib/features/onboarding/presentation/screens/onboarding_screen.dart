import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:coffeeno/core/constants/app_constants.dart';
import 'package:coffeeno/core/router/app_router.dart';
import 'package:coffeeno/core/theme/app_colors.dart';
import 'package:coffeeno/core/widgets/app_button.dart';
import 'package:coffeeno/features/auth/presentation/providers/auth_provider.dart';
import 'package:coffeeno/l10n/app_localizations.dart';

import '../widgets/preference_chips.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _finishing = false;

  // Captured taste preferences (the final, interactive onboarding page).
  final Set<String> _brewMethods = {};
  final Set<String> _roastLevels = {};
  final Set<String> _flavors = {};

  // Number of informational (non-interactive) carousel pages before the
  // preferences page. The preferences page is the last index.
  static const _infoPageCount = 4;
  int get _pageCount => _infoPageCount + 1;
  bool get _isPrefsPage => _index == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  List<_OnboardingPage> _pages(AppLocalizations l10n) => [
        _OnboardingPage(
          icon: Icons.document_scanner_outlined,
          title: l10n.onboardingScanTitle,
          body: l10n.onboardingScanBody,
        ),
        _OnboardingPage(
          icon: Icons.coffee_outlined,
          title: l10n.onboardingTasteTitle,
          body: l10n.onboardingTasteBody,
        ),
        _OnboardingPage(
          icon: Icons.people_outline,
          title: l10n.onboardingDiscoverTitle,
          body: l10n.onboardingDiscoverBody,
        ),
        _OnboardingPage(
          icon: Icons.public_outlined,
          title: l10n.onboardingMapTitle,
          body: l10n.onboardingMapBody,
        ),
      ];

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        // Persist onboarding completion plus any captured preferences. Empty
        // sets are written as empty lists (the user simply skipped picking).
        await ref.read(userRepositoryProvider).updateUser(uid, {
          'hasSeenOnboarding': true,
          'preferredBrewMethods': _brewMethods.toList(),
          'preferredRoastLevels': _roastLevels.toList(),
          'favoriteFlavors': _flavors.toList(),
        });
        ref.invalidate(currentUserProvider);
      } catch (_) {
        // Non-blocking: if the write fails we still let the user in.
      }
    }

    if (mounted) context.go(AppRoutes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final infoPages = _pages(l10n);
    final isLast = _isPrefsPage;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: TextButton(
                  onPressed: _finishing ? null : _finish,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  if (i < _infoPageCount) {
                    return _OnboardingPageView(page: infoPages[i]);
                  }
                  return _PreferencesPageView(
                    l10n: l10n,
                    brewMethods: _brewMethods,
                    roastLevels: _roastLevels,
                    flavors: _flavors,
                    onToggleBrew: (v) => _toggle(_brewMethods, v),
                    onToggleRoast: (v) => _toggle(_roastLevels, v),
                    onToggleFlavor: (v) => _toggle(_flavors, v),
                  );
                },
              ),
            ),
            _Dots(count: _pageCount, index: _index, theme: theme),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: AppButton(
                label: isLast ? l10n.onboardingGetStarted : l10n.onboardingNext,
                isLoading: _finishing && isLast,
                onPressed: () {
                  if (isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.terracottaLight.withValues(alpha: 0.15)
                  : AppColors.terracottaMuted.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: isDark
                  ? AppColors.terracottaLight
                  : AppColors.terracotta,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// The interactive final onboarding page: captures brew/roast/flavor
/// preferences via multi-select chips. All selections are optional.
class _PreferencesPageView extends StatelessWidget {
  const _PreferencesPageView({
    required this.l10n,
    required this.brewMethods,
    required this.roastLevels,
    required this.flavors,
    required this.onToggleBrew,
    required this.onToggleRoast,
    required this.onToggleFlavor,
  });

  final AppLocalizations l10n;
  final Set<String> brewMethods;
  final Set<String> roastLevels;
  final Set<String> flavors;
  final ValueChanged<String> onToggleBrew;
  final ValueChanged<String> onToggleRoast;
  final ValueChanged<String> onToggleFlavor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 8),
        Text(
          l10n.onboardingPrefsTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.onboardingPrefsBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        PreferenceChips(
          label: l10n.onboardingPrefsBrewMethods,
          options: [for (final m in BrewMethod.values) m.label],
          selected: brewMethods,
          onToggle: onToggleBrew,
        ),
        const SizedBox(height: 24),
        PreferenceChips(
          label: l10n.onboardingPrefsRoastLevels,
          options: [for (final r in RoastLevel.values) r.label],
          selected: roastLevels,
          onToggle: onToggleRoast,
        ),
        const SizedBox(height: 24),
        PreferenceChips(
          label: l10n.onboardingPrefsFlavors,
          options: AppConstants.flavorFamilies,
          selected: flavors,
          onToggle: onToggleFlavor,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.theme,
  });

  final int count;
  final int index;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
