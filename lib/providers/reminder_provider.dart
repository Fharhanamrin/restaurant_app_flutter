import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../services/workmanager_service.dart';

class ReminderProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _key = 'daily_reminder_enabled';

  ReminderProvider(this._prefs);

  bool get isEnabled => _prefs.getBool(_key) ?? false;

  Future<void> toggle() async {
    final newValue = !isEnabled;
    await _prefs.setBool(_key, newValue);

    if (newValue) {
      await Workmanager().registerPeriodicTask(
        dailyReminderTaskTag,
        dailyReminderTaskName,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelayTo11AM(),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } else {
      await Workmanager().cancelByTag(dailyReminderTaskTag);
    }
    notifyListeners();
  }
}
