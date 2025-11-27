// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0 using the visible label.
    expect(find.textContaining('Button tapped: 0'), findsOneWidget);
    expect(find.textContaining('Button tapped: 1'), findsNothing);

    // Tap the 'Increment' button and trigger a frame.
    await tester.tap(find.text('Increment'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.textContaining('Button tapped: 0'), findsNothing);
    expect(find.textContaining('Button tapped: 1'), findsOneWidget);
  });
}
