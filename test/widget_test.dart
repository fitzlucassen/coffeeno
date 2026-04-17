import 'package:flutter_test/flutter_test.dart';

import 'package:coffeeno/app.dart';

void main() {
  testWidgets('CoffenoApp smoke test', (WidgetTester tester) async {
    // Verify that the app widget can be created.
    expect(const CoffenoApp(), isA<CoffenoApp>());
  });
}
