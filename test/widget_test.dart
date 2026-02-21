// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:readium/main.dart';

void main() {
  testWidgets('App loads with home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our home screen loads with the expected elements
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Enter Medium Article URL'), findsOneWidget);

    // Verify history button is present
    expect(find.byIcon(Icons.history), findsOneWidget);
  });
}
