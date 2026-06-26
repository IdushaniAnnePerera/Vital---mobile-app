import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vital/theme/app_theme.dart';
import 'package:vital/widgets/common.dart';

void main() {
  testWidgets('EmptyState renders icon and message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: EmptyState(
            icon: Icons.directions_walk,
            message: 'No data yet.',
          ),
        ),
      ),
    );
    expect(find.text('No data yet.'), findsOneWidget);
  });
}
