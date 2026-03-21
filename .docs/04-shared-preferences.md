# SharedPreferences (Tema & Pengingat)

## Teori

### Apa itu SharedPreferences?

SharedPreferences adalah penyimpanan **key-value** yang sederhana dan persisten. Data disimpan di disk device dan tetap ada meskipun aplikasi ditutup.

| SharedPreferences cocok untuk | SharedPreferences tidak cocok untuk |
|-------------------------------|-------------------------------------|
| Boolean (on/off toggle) | Data terstruktur banyak record |
| String kecil (username, token) | File besar |
| Integer/double (settings) | Data relasional |
| Pengaturan preferensi user | Data sensitif (password) |

### Perbandingan dengan SQLite

| Aspek | SharedPreferences | SQLite |
|-------|-------------------|--------|
| Tipe data | Key-value (String, int, bool, double, List\<String\>) | Tabel relasional |
| Query | Hanya get/set by key | SQL (SELECT, WHERE, JOIN) |
| Kapasitas | Kecil (beberapa KB) | Besar (GB) |
| Kecepatan | Sangat cepat | Cepat |
| Use case | Settings, toggle, flag | Daftar data, record |

## Penggunaan di Project

### 1. Tema (Dark Mode)

`ThemeProvider` menyimpan preferensi dark mode:

```dart
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _themeKey = 'is_dark_mode';

  ThemeProvider(this._prefs) {
    // Baca saat konstruksi
    final isDark = _prefs.getBool(_themeKey);
    if (isDark == null) {
      _themeMode = ThemeMode.system;  // Belum pernah set → ikut system
    } else {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    // Simpan ke disk
    await _prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}
```

Alur:
1. App launch → `main()` memuat `SharedPreferences.getInstance()`
2. `SharedPreferences` diteruskan ke `ThemeProvider` via constructor
3. Constructor membaca `is_dark_mode` → set `_themeMode`
4. User toggle → simpan ke SharedPreferences + notifyListeners
5. App ditutup, dibuka lagi → baca ulang dari SharedPreferences

### 2. Daily Reminder

`ReminderProvider` menyimpan preferensi pengingat harian:

```dart
class ReminderProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _key = 'daily_reminder_enabled';

  bool get isEnabled => _prefs.getBool(_key) ?? false;

  Future<void> toggle() async {
    final newValue = !isEnabled;
    await _prefs.setBool(_key, newValue);

    if (newValue) {
      // Daftarkan periodic task Workmanager
      await Workmanager().registerPeriodicTask(...);
    } else {
      // Batalkan task
      await Workmanager().cancelByTag(dailyReminderTaskTag);
    }
    notifyListeners();
  }
}
```

## Inisialisasi

SharedPreferences di-load **sebelum** `runApp` di `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Wajib sebelum async
  final prefs = await SharedPreferences.getInstance();
  // ...
  runApp(App(prefs: prefs));
}
```

`WidgetsFlutterBinding.ensureInitialized()` **wajib** dipanggil jika ada kode async sebelum `runApp()`. Tanpa ini, akses ke native platform akan gagal.

## Tips

- **Jangan simpan data besar** di SharedPreferences — gunakan SQLite atau file
- **Key harus unik** dan sebaiknya disimpan sebagai `static const` di provider
- SharedPreferences bersifat **asinkron** (`Future`) saat pertama kali diload, tapi **sinkron** setelahnya untuk `getBool`, `getString`, dll.
- `setBool`, `setString` dll. mengembalikan `Future<bool>` — `await` untuk memastikan data tersimpan sebelum melanjutkan
