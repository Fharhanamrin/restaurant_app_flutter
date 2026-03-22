import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:restaurant_app_flutter/app.dart';
import 'package:restaurant_app_flutter/services/workmanager_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'App launch -> tampil daftar -> tap card -> navigasi ke detail -> '
    'isi ulasan -> kirim -> favorite -> back -> tab favorit -> '
    'detail favorit -> un-favorite -> tab pengaturan -> '
    'ubah tema -> toggle pengingat -> warna tema -> ganti font -> home',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await Workmanager().initialize(callbackDispatcher);

      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.endsWith('/list')) {
          return http.Response(
            jsonEncode({
              'error': false,
              'count': 1,
              'restaurants': [
                {
                  'id': 'rqdv5juczeskfw1e867',
                  'name': 'Melting Pot',
                  'description': 'Lorem ipsum dolor sit amet.',
                  'pictureId': '14',
                  'city': 'Medan',
                  'rating': 4.2,
                },
              ],
            }),
            200,
          );
        }

        if (path.contains('/detail/')) {
          return http.Response(
            jsonEncode({
              'error': false,
              'restaurant': {
                'id': 'rqdv5juczeskfw1e867',
                'name': 'Melting Pot',
                'description': 'Lorem ipsum dolor sit amet.',
                'city': 'Medan',
                'address': 'Jln. Kemasan No. 50',
                'pictureId': '14',
                'rating': 4.2,
                'categories': [
                  {'name': 'Jawa'},
                ],
                'menus': {
                  'foods': [
                    {'name': 'Nasi Goreng'},
                  ],
                  'drinks': [
                    {'name': 'Es Teh'},
                  ],
                },
                'customerReviews': [
                  {
                    'name': 'Ahmad',
                    'review': 'Enak!',
                    'date': '13 November 2019',
                  },
                ],
              },
            }),
            200,
          );
        }

        if (path.endsWith('/review')) {
          return http.Response(
            jsonEncode({
              'error': false,
              'customerReviews': [
                {
                  'name': 'fharhan ganteng',
                  'review': 'untuk fharhan, fharhan ganteng dan kaya',
                  'date': '22 Maret 2026',
                },
              ],
            }),
            201,
          );
        }

        return http.Response('Not Found', 404);
      });

      await tester.pumpWidget(App(prefs: prefs, httpClient: mockClient));

      // ── 1. App launch: tampil daftar ──────────────────────────────────────
      expect(find.text('Restoran'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── 2. Tap card pertama → navigasi ke detail ──────────────────────────
      final cards = find.byType(Card);
      expect(cards, findsWidgets);
      await tester.tap(cards.first);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(CustomScrollView), findsOneWidget);

      // ── 3. Scroll ke form ulasan ──────────────────────────────────────────
      await tester.scrollUntilVisible(
        find.text('Kirim Ulasan'),
        300.0,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 20,
      );
      await tester.pumpAndSettle();

      // Isi nama
      final nameField = find.byType(TextFormField).first;
      await tester.tap(nameField);
      await tester.pumpAndSettle();
      await tester.enterText(nameField, 'fharhan ganteng');
      await tester.pumpAndSettle();

      // Isi ulasan
      final reviewField = find.byType(TextFormField).last;
      await tester.tap(reviewField);
      await tester.pumpAndSettle();
      await tester.enterText(
        reviewField,
        'untuk fharhan, fharhan ganteng dan kaya',
      );
      await tester.pumpAndSettle();

      // Kirim ulasan
      await tester.scrollUntilVisible(
        find.text('Kirim Ulasan'),
        100.0,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 5,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── 4. Scroll up → tap favorite (love) ───────────────────────────────
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, 600),
      );
      await tester.pumpAndSettle();

      final favBorderBtn = find.byIcon(Icons.favorite_border);
      if (favBorderBtn.evaluate().isNotEmpty) {
        await tester.tap(favBorderBtn);
        await tester.pumpAndSettle();
      }

      // ── 5. Back ke home ───────────────────────────────────────────────────
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── 6. Tab Favorit → lihat list card ─────────────────────────────────
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ── 7. Tap card favorit pertama → detail ──────────────────────────────
      // Tap InkWell di dalam Card agar hit test tepat sasaran
      final favCardInkWells = find.descendant(
        of: find.byType(Card),
        matching: find.byType(InkWell),
      );
      if (favCardInkWells.evaluate().isNotEmpty) {
        await tester.tap(favCardInkWells.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        if (find.byType(CustomScrollView).evaluate().isNotEmpty) {
          // ── 8. Un-favorite ───────────────────────────────────────────────
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, 600),
          );
          await tester.pumpAndSettle();

          final favFilledBtn = find.byIcon(Icons.favorite);
          if (favFilledBtn.evaluate().isNotEmpty) {
            await tester.tap(favFilledBtn);
            await tester.pumpAndSettle();
          }

          // ── 9. Back ke tab favorit ───────────────────────────────────────
          await tester.pageBack();
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // ── 10. Tab Pengaturan ────────────────────────────────────────────────
      await tester.tap(find.text('Pengaturan'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Pengaturan'), findsWidgets);

      // ── 11. Toggle dark mode ──────────────────────────────────────────────
      await tester.tap(find.text('Mode Gelap'));
      await tester.pumpAndSettle();

      // ── 12. Toggle pengingat harian ───────────────────────────────────────
      await tester.tap(find.text('Pengingat Harian'));
      await tester.pumpAndSettle();

      // ── 13. Warna tema → pilih Biru → back ───────────────────────────────
      await tester.tap(find.text('Warna Tema'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Pilih Warna Tema'), findsOneWidget);

      await tester.tap(find.text('Biru'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Pengaturan'), findsWidgets);

      // ── 14. Ganti font → pilih Inter → back ──────────────────────────────
      await tester.tap(find.text('Ganti Font'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Pilih Font'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Inter'),
        200.0,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 20,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inter'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Pengaturan'), findsWidgets);

      // ── 15. Back ke Home ──────────────────────────────────────────────────
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Restoran'), findsOneWidget);
    },
  );
}
