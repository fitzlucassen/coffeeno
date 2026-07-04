import 'package:coffeeno/features/gamification/domain/gamification.dart';
import 'package:coffeeno/features/gamification/presentation/widgets/expert_badge.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('shows the tier title and points for a mid-tier user', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const ExpertBadge(points: 150)));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    // 150 pts -> Home Brewer.
    expect(find.text(l10n.levelHomeBrewer), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('top-tier user shows no progress bar', (tester) async {
    await tester.pumpWidget(_host(const ExpertBadge(points: 2000)));
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(l10n.levelMasterTaster), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('expertTierTitle maps every tier without throwing', (
    tester,
  ) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            l10n = AppLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    for (final tier in ExpertTier.values) {
      expect(expertTierTitle(l10n, tier), isNotEmpty);
    }
  });
}
