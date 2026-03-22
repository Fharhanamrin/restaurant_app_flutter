# Restaurant App Flutter

Aplikasi restoran yang menampilkan daftar restoran, detail, pencarian, fitur ulasan, favorit, pengaturan tema, dan notifikasi harian menggunakan REST API dari [Dicoding Restaurant API](https://restaurant-api.dicoding.dev).

## Tech Stack

| Kategori | Library | Versi |
|---|---|---|
| Framework | Flutter (Dart SDK) | ^3.11.1 |
| State Management | [provider](https://pub.dev/packages/provider) | ^6.1.2 |
| HTTP Client | [http](https://pub.dev/packages/http) | ^1.2.1 |
| Database | [sqflite](https://pub.dev/packages/sqflite) | ^2.4.2 |
| Key-Value Storage | [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.5.3 |
| Notifikasi | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) | ^21.0.0 |
| Background Task | [workmanager](https://pub.dev/packages/workmanager) | ^0.9.0+3 |
| Timezone | [timezone](https://pub.dev/packages/timezone) | ^0.11.0 |
| Font | [google_fonts](https://pub.dev/packages/google_fonts) | ^6.2.1 |
| Testing | [mockito](https://pub.dev/packages/mockito) | ^5.4.6 |
| UI | Material 3 | built-in |

## Fitur

- Daftar restoran dengan gambar, rating, dan kota
- Detail restoran (deskripsi, menu makanan & minuman, kategori)
- Deskripsi panjang dengan tombol "Lihat selengkapnya / Sembunyikan"
- Pencarian restoran
- Tulis & kirim ulasan
- Favorit restoran (simpan/hapus ke database SQLite)
- Dark mode / Light mode toggle (persisten via SharedPreferences)
- Pilih warna tema (10 pilihan warna)
- Pilih font (8 pilihan Google Fonts)
- Daily reminder notifikasi pukul 11.00 (restoran acak dari API)
- Bottom Navigation Bar (Home, Favorit, Pengaturan)
- Hero animation untuk transisi gambar (dengan prefix unik per tab)

## Struktur Project

```
lib/
├── main.dart                              # Entry point + init SharedPrefs, Workmanager, Notifications
├── app.dart                               # MultiProvider & MaterialApp setup
├── core/
│   ├── constants/
│   │   ├── app_constants.dart             # Base URL & image endpoints
│   │   └── error_messages.dart            # Pesan error terpusat
│   ├── exceptions/
│   │   └── app_exception.dart             # Custom exception class
│   ├── models/
│   │   ├── app_color.dart                 # Model preset warna tema
│   │   └── app_font.dart                  # Model preset font
│   └── theme/
│       └── app_theme.dart                 # Light & dark ThemeData factory
├── data/
│   ├── local/
│   │   └── database_helper.dart           # SQLite singleton (DatabaseHelper)
│   ├── models/
│   │   ├── restaurant.dart                # Model list restoran + toMap/fromMap
│   │   ├── restaurant_detail.dart         # Model detail restoran
│   │   ├── menu_item.dart                 # Model item menu
│   │   └── customer_review.dart           # Model ulasan
│   └── repositories/
│       ├── restaurant_repository.dart     # Abstract interface (API)
│       ├── restaurant_repository_impl.dart # Implementasi HTTP client
│       ├── favorite_repository.dart       # Abstract interface (SQLite)
│       └── favorite_repository_impl.dart  # Implementasi SQLite
├── providers/
│   ├── states/
│   │   ├── restaurant_list_state.dart     # Sealed state: list restoran
│   │   ├── restaurant_detail_state.dart   # Sealed state: detail restoran
│   │   ├── search_state.dart              # Sealed state: pencarian
│   │   └── favorite_state.dart            # Sealed state: favorit
│   ├── restaurant_list_provider.dart      # State management list restoran
│   ├── restaurant_detail_provider.dart    # State management detail & review
│   ├── search_provider.dart               # State management pencarian
│   ├── theme_provider.dart                # State management tema (SharedPreferences)
│   ├── favorite_provider.dart             # State management favorit (SQLite)
│   └── reminder_provider.dart             # State management daily reminder
├── services/
│   ├── notification_service.dart          # FlutterLocalNotificationsPlugin init & show
│   └── workmanager_service.dart           # Workmanager callback dispatcher + fetch random restoran
└── ui/
    ├── screens/
    │   ├── main/
    │   │   └── main_screen.dart           # BottomNavigationBar + IndexedStack shell
    │   ├── restaurant_list/
    │   │   └── restaurant_list_screen.dart # Halaman daftar restoran (tab Home)
    │   ├── restaurant_detail/
    │   │   └── restaurant_detail_screen.dart # Halaman detail + tombol favorit
    │   ├── search/
    │   │   └── search_screen.dart         # Halaman pencarian
    │   ├── favorite/
    │   │   └── favorite_screen.dart       # Halaman daftar favorit (tab Favorit)
    │   ├── settings/
    │   │   └── settings_screen.dart       # Halaman pengaturan (tab Settings)
    │   ├── color_picker/
    │   │   └── color_picker_screen.dart   # Halaman pilih warna tema
    │   └── font_picker/
    │       └── font_picker_screen.dart    # Halaman pilih font
    └── widgets/
        ├── restaurant_card.dart           # Card restoran (reusable, heroTagPrefix)
        ├── error_view.dart                # Widget error dengan tombol retry
        └── loading_indicator.dart         # Loading spinner

test/
├── match_test.dart                        # 1 unit test (Result equality)
├── providers/
│   ├── restaurant_list_provider_test.dart # 3 unit tests (initial, success, error)
│   └── restaurant_list_provider_test.mocks.dart
└── widgets/
    └── restaurant_card_test.dart          # 2 widget tests (render, onTap)

integration_test/
├── app_test.dart                          # 1 integration test (launch -> list -> detail)
└── notification_test.dart                 # 2 integration tests (notifikasi hardcoded & API)
```

## Arsitektur

```
UI (StatelessWidget + Builder)
  ↕ context.watch / context.read
Provider (ChangeNotifier + sealed class State)
  ↕
Repository (abstract interface)
  ↕
HTTP Client / SQLite / SharedPreferences
```

- **Sealed class** untuk state management (`Loading`, `Loaded`, `Error`, `Initial`)
- **`context.watch<T>()`** di dalam `Builder` untuk scoped rebuild
- **`context.read<T>()`** di callback untuk one-time access tanpa subscribe
- **Repository pattern** dengan abstract interface untuk dependency injection
- **DatabaseHelper singleton** untuk akses SQLite
- **SharedPreferences** diinject melalui `main.dart` ke provider
- **Workmanager** dengan top-level `callbackDispatcher` untuk background task
- **Hero animation** menggunakan `heroTagPrefix` unik per tab (`home_`, `fav_`, `search_`) untuk menghindari konflik di `IndexedStack`
- **`AppException`** sebagai custom exception
- **`ErrorMessages`** untuk memusatkan semua string error

## Getting Started

```bash
flutter pub get
flutter run
```

### Konfigurasi Android

- `minSdk`: 26
- Core library desugaring enabled
- Permissions: `INTERNET`, `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`

## Testing

Total: **9 test cases** (4 unit + 2 widget + 3 integration)

```bash
# Unit + Widget tests (6 test cases)
flutter test

# Integration test - app flow
flutter test integration_test/app_test.dart

# Integration test - notifikasi (harus di device/emulator)
flutter test integration_test/notification_test.dart

# Semua integration tests
flutter test integration_test/
```

| Jenis | File | Jumlah | Deskripsi |
|---|---|---|---|
| Unit | `test/match_test.dart` | 1 | Result equality |
| Unit | `test/providers/restaurant_list_provider_test.dart` | 3 | State awal, fetch sukses, fetch gagal |
| Widget | `test/widgets/restaurant_card_test.dart` | 2 | Render data, onTap callback |
| Integration | `integration_test/app_test.dart` | 1 | Launch → list → tap card → detail |
| Integration | `integration_test/notification_test.dart` | 2 | Notifikasi hardcoded & dari API |

## Dokumentasi Lengkap

Dokumentasi teori dan penjelasan detail tersedia di folder `.docs/`:

| # | Dokumen | Isi |
|---|---------|-----|
| 01 | [Arsitektur](.docs/01-arsitektur.md) | 3-layer architecture, dependency injection, alur data |
| 02 | [State Management](.docs/02-state-management.md) | Provider, sealed class, context.watch vs read |
| 03 | [Database SQLite](.docs/03-database-sqlite.md) | Singleton pattern, CRUD, favorit |
| 04 | [SharedPreferences](.docs/04-shared-preferences.md) | Persistensi tema dan pengingat |
| 05 | [Notifikasi & Background](.docs/05-notifikasi-dan-background-task.md) | flutter_local_notifications, Workmanager |
| 06 | [Testing](.docs/06-testing.md) | Unit, widget, integration test |
| 07 | [Tema & Material 3](.docs/07-tema-dan-material3.md) | ColorScheme, dark mode, font |
| 08 | [Navigasi](.docs/08-navigasi.md) | Bottom nav, IndexedStack, Hero animation |
| 09 | [API & Networking](.docs/09-api-dan-networking.md) | REST API, error handling, models |

## Export ZIP (tanpa docs & cache)

```bash
cd /opt/homebrew/var/www/learn-dart/2026/learning-path-flutter/flutter-fundamental
zip -r restaurant_app.zip restaurant_app_flutter/ \
  -x "restaurant_app_flutter/.docs/*" \
  -x "restaurant_app_flutter/.dart_tool/*" \
  -x "restaurant_app_flutter/build/*" \
  -x "restaurant_app_flutter/.flutter-plugins*" \
  -x "restaurant_app_flutter/android/.gradle/*"
```

## API

Base URL: `https://restaurant-api.dicoding.dev`

| Endpoint | Method | Keterangan |
|---|---|---|
| `/list` | GET | Daftar semua restoran |
| `/detail/{id}` | GET | Detail restoran berdasarkan ID |
| `/search?q={query}` | GET | Pencarian restoran |
| `/review` | POST | Kirim ulasan baru |
