import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end user navigation flow (Home -> Search -> Settings)', (tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Verify we are on the Home Screen (Search Icon should exist)
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Tap search icon
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    // Verify we are on Search Screen
    expect(find.text('Search City'), findsOneWidget);
    
    // Type a city
    await tester.enterText(find.byType(TextField), 'Tokyo');
    await tester.pumpAndSettle();

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    // Verify back on home
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Tap Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Verify Settings Screen
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Theme'), findsOneWidget);

    // Tap back
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();
  });
}
