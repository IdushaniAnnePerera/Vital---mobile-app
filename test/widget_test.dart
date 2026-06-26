import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vital/theme/app_theme.dart';
import 'package:vital/screens/home_screen.dart';

void main() {
  testWidgets('Dashboard shows the five health domains', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
    );
    await tester.pump();

    expect(find.text('Steps'), findsWidgets);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('Medication'), findsOneWidget);
    expect(find.text('Sleep'), findsOneWidget);
  });
}
