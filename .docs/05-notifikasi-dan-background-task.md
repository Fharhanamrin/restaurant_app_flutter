# Notifikasi & Background Task

## Teori

### flutter_local_notifications

Plugin untuk menampilkan **notifikasi lokal** (tanpa server push). Mendukung Android, iOS, macOS, Linux, dan Windows.

Fitur yang digunakan:
- Menampilkan notifikasi sederhana (`show`)
- Konfigurasi channel Android (importance, priority)

### Workmanager

Plugin untuk menjalankan **kode Dart di background**, bahkan saat app ditutup. Menggunakan Android WorkManager dan iOS Background Tasks.

Fitur yang digunakan:
- `registerPeriodicTask` — task yang berjalan berulang setiap interval tertentu
- `cancelByTag` — membatalkan task berdasarkan tag

## Arsitektur Notifikasi

```
User mengaktifkan reminder di Settings
        │
        ▼
ReminderProvider.toggle()
        │
        ├── SharedPreferences.setBool('daily_reminder_enabled', true)
        │
        └── Workmanager.registerPeriodicTask(
                frequency: 24 jam,
                initialDelay: sampai 11:00 AM berikutnya
            )
        │
        ▼ (background, app bisa tertutup)
callbackDispatcher()
        │
        ├── HTTP GET /list → daftar restoran
        ├── Random pick 1 restoran
        └── FlutterLocalNotificationsPlugin.show(
                title: 'Rekomendasi Restoran',
                body: 'Nama di Kota - Rating: X.X'
            )
```

## NotificationService

File: `lib/services/notification_service.dart`

```dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _plugin.initialize(settings: settings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',       // Channel ID
      'Daily Reminder',       // Channel Name
      channelDescription: 'Pengingat makan siang harian',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
```

### Konsep Penting

- **Channel** (Android 8.0+): notifikasi harus terkait channel. Channel mendefinisikan perilaku (suara, getar, importance)
- **Importance**: seberapa "mengganggu" notifikasi (HIGH = muncul di atas layar)
- **Priority**: urutan tampil di notification shade
- `@mipmap/ic_launcher`: ikon yang ditampilkan di notifikasi, menggunakan launcher icon app

## Workmanager Service

File: `lib/services/workmanager_service.dart`

### callbackDispatcher

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == dailyReminderTaskName) {
      await _fetchAndShowNotification();
    }
    return true;
  });
}
```

- `@pragma('vm:entry-point')` — **wajib**, memberitahu compiler agar fungsi ini tidak dihapus saat tree-shaking
- Fungsi harus **top-level** (bukan method class), karena berjalan di isolate terpisah
- Return `true` = task berhasil, `false` = task gagal (akan diretry)

### Fetch dan Tampilkan Notifikasi

```dart
Future<void> _fetchAndShowNotification() async {
  try {
    final response = await http.get(Uri.parse('${AppConstants.baseUrl}/list'));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final restaurants = body['restaurants'] as List;
      if (restaurants.isNotEmpty) {
        final random = Random();
        final restaurant = restaurants[random.nextInt(restaurants.length)];

        // Harus init ulang plugin karena berjalan di isolate terpisah
        final plugin = FlutterLocalNotificationsPlugin();
        await plugin.initialize(settings: ...);
        await plugin.show(
          id: 0,
          title: 'Rekomendasi Restoran',
          body: '${restaurant['name']} di ${restaurant['city']}',
          notificationDetails: details,
        );
      }
    }
  } catch (_) {}
}
```

**Penting**: Di background isolate, `FlutterLocalNotificationsPlugin` harus **di-initialize ulang** karena isolate tidak berbagi memori dengan main isolate.

### Perhitungan Initial Delay

```dart
Duration initialDelayTo11AM() {
  final now = DateTime.now();
  var scheduled = DateTime(now.year, now.month, now.day, 11); // 11:00 AM hari ini
  if (now.isAfter(scheduled)) {
    scheduled = scheduled.add(const Duration(days: 1)); // Besok 11:00 AM
  }
  return scheduled.difference(now);
}
```

Contoh:
- Sekarang 09:00 → delay = 2 jam → notifikasi pertama pukul 11:00 hari ini
- Sekarang 14:00 → delay = 21 jam → notifikasi pertama pukul 11:00 besok

## Konfigurasi Android

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

- `POST_NOTIFICATIONS` — izin menampilkan notifikasi (Android 13+)
- `RECEIVE_BOOT_COMPLETED` — agar notifikasi terjadwal ulang setelah device restart
- `INTERNET` — akses jaringan untuk fetch data restoran

### build.gradle.kts

```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true  // Wajib untuk flutter_local_notifications
}

defaultConfig {
    minSdk = 26  // Minimum Android 8.0
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

**Desugaring** memungkinkan penggunaan API Java baru (java.time) pada Android lama.

## Batasan

- **Android**: Workmanager minimum interval 15 menit. Frekuensi 24 jam tidak dijamin tepat karena OS mengoptimasi baterai
- **iOS**: Background task tidak dijamin berjalan; iOS menentukan berdasarkan pola penggunaan app
- **Beberapa device** (Xiaomi, Huawei) punya pembatasan background task tambahan — user perlu whitelist app secara manual
