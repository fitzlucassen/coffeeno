import 'package:coffeeno/features/tasting/presentation/widgets/brew_timer.dart';
import 'package:coffeeno/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('starts at 0:00 and shows the target', (tester) async {
    await tester.pumpWidget(_host(const BrewTimer(targetSeconds: 180)));

    expect(find.text('0:00'), findsOneWidget);
    expect(find.text('/ 3:00'), findsOneWidget);
  });

  testWidgets('counts up after start and reaches the target', (tester) async {
    await tester.pumpWidget(_host(const BrewTimer(targetSeconds: 2)));

    // Tap start.
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    // Advance two simulated seconds.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:01'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('0:02'), findsOneWidget);
    // Target reached message localized to English by default.
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(l10n.brewGuideTargetReached), findsOneWidget);

    // Reset returns to zero and cancels.
    await tester.tap(find.byIcon(Icons.replay));
    await tester.pump();
    expect(find.text('0:00'), findsOneWidget);

    // Pumping more time should not advance after reset.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:00'), findsOneWidget);
  });

  testWidgets('hides target UI when no target', (tester) async {
    await tester.pumpWidget(_host(const BrewTimer(targetSeconds: 0)));

    expect(find.text('0:00'), findsOneWidget);
    expect(find.textContaining('/'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });
}
