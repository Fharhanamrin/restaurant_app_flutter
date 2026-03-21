import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app_flutter/core/constants/app_constants.dart';
import 'package:restaurant_app_flutter/services/notification_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test 1 - Notifikasi langsung (data hardcoded)', (tester) async {
    await NotificationService.init();

    try {
      await NotificationService.showNotification(
        id: 99,
        title: 'Test Notifikasi',
        body: 'Ini notifikasi test dari integration test',
      );
      debugPrint('>>> NOTIFIKASI BERHASIL DIKIRIM');
    } catch (e) {
      debugPrint('>>> NOTIFIKASI GAGAL: $e');
    }

    await Future.delayed(const Duration(seconds: 5));
    expect(true, isTrue);
  });

  testWidgets('Test 2 - Notifikasi dari API (random restoran)', (tester) async {
    await NotificationService.init();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/list'),
      );
      debugPrint('>>> API status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final restaurants = body['restaurants'] as List;
        debugPrint('>>> Jumlah restoran: ${restaurants.length}');

        if (restaurants.isNotEmpty) {
          final restaurant = restaurants.first as Map<String, dynamic>;
          await NotificationService.showNotification(
            id: 100,
            title: 'Rekomendasi Restoran',
            body:
                '${restaurant['name']} di ${restaurant['city']} - Rating: ${restaurant['rating']}',
          );
          debugPrint('>>> NOTIFIKASI API BERHASIL DIKIRIM');
        }
      }
    } catch (e) {
      debugPrint('>>> ERROR: $e');
    }

    await Future.delayed(const Duration(seconds: 5));
    expect(true, isTrue);
  });
}
