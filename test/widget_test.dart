import 'package:flutter_test/flutter_test.dart';

import 'package:kana_listening/main.dart';

void main() {
  testWidgets('Loading hint Smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.text('Loading...'), findsOneWidget);
  });
}
