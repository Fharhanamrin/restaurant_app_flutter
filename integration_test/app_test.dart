import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app_flutter/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launch -> tampil daftar -> tap card -> navigasi ke detail', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(App(prefs: prefs));

    expect(find.text('Restoran'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(CustomScrollView), findsOneWidget);
    }
  });
}
