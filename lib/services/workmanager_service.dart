import 'dart:convert';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import '../core/constants/app_constants.dart';

const String dailyReminderTaskName = 'dailyReminderTask';
const String dailyReminderTaskTag = 'dailyReminder';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == dailyReminderTaskName) {
      await fetchAndShowNotification();
    }
    return true;
  });
}

Future<void> fetchAndShowNotification() async {
  try {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/list'),
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final restaurants = body['restaurants'] as List;
      if (restaurants.isNotEmpty) {
        final random = Random();
        final restaurant =
            restaurants[random.nextInt(restaurants.length)] as Map<String, dynamic>;

        const androidDetails = AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Pengingat makan siang harian',
          importance: Importance.high,
          priority: Priority.high,
        );
        const details = NotificationDetails(android: androidDetails);

        final plugin = FlutterLocalNotificationsPlugin();
        const androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const settings = InitializationSettings(android: androidSettings);
        await plugin.initialize(settings: settings);

        await plugin.show(
          id: 0,
          title: 'Rekomendasi Restoran',
          body:
              '${restaurant['name']} di ${restaurant['city']} - Rating: ${restaurant['rating']}',
          notificationDetails: details,
        );
      }
    }
  } catch (_) {}
}

Duration initialDelayTo11AM() {
  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day, 11);
  if (now.isAfter(scheduled)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled.difference(now);
}
