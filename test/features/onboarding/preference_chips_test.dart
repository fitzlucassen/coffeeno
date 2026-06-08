import 'package:coffeeno/features/onboarding/presentation/widgets/preference_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('renders the label and one chip per option', (tester) async {
    await tester.pumpWidget(_host(PreferenceChips(
      label: 'Brew methods',
      options: const ['V60', 'AeroPress', 'Espresso'],
      selected: const {},
      onToggle: (_) {},
    )));

    expect(find.text('Brew methods'), findsOneWidget);
    expect(find.byType(FilterChip), findsNWidgets(3));
  });

  testWidgets('reflects the selected set', (tester) async {
    await tester.pumpWidget(_host(PreferenceChips(
      label: 'Brew methods',
      options: const ['V60', 'AeroPress'],
      selected: const {'V60'},
      onToggle: (_) {},
    )));

    final v60 = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'V60'),
    );
    final aero = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'AeroPress'),
    );
    expect(v60.selected, isTrue);
    expect(aero.selected, isFalse);
  });

  testWidgets('taps report the toggled option label', (tester) async {
    final toggled = <String>[];
    await tester.pumpWidget(_host(PreferenceChips(
      label: 'Flavors',
      options: const ['Fruity', 'Sweet'],
      selected: const {},
      onToggle: toggled.add,
    )));

    await tester.tap(find.widgetWithText(FilterChip, 'Sweet'));
    await tester.pump();

    expect(toggled, ['Sweet']);
  });
}
