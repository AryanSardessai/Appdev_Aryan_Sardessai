import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_api_fetch_app/main.dart';

void main() {
  // Simple test to ensure the main screen renders without error.
  testWidgets('Yoga Pose Gallery loads app bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YogaPoseApp());

    // Wait for the FutureBuilder to complete and the UI to update.
    // The delay should cover the time it takes for the FutureBuilder to go to the Done state.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that the title of the App Bar is present.
    expect(find.text('Yoga Poses Gallery'), findsOneWidget);

    // You can also test for the presence of the loading indicator if needed,
    // but the final state is what we verify here.
  });
}
