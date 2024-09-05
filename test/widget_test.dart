// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cow_monitor/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CowMonitor());

    // Verify that the HomeScreen is displayed.
    expect(find.text('Farm Watch'), findsOneWidget); // Check for the app title in the AppBar
    expect(find.byType(Drawer), findsOneWidget); // Check for the presence of the Drawer
    expect(find.text('Home Screen'), findsOneWidget); // Verify some text in Home Screen
    
  });
}
