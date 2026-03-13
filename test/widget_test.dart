import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/main.dart';

void main() {
  testWidgets('FastGoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FastGoApp());
    await tester.pump();

    // Verify that the app builds and renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
