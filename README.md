# Restaurant App Flutter

Aplikasi restoran yang menampilkan daftar restoran, detail, pencarian, dan fitur ulasan menggunakan REST API dari 
[Dicoding Restaurant API](https://restaurant-api.dicoding.dev).

## Tech Stack

- **Flutter** (Dart SDK ^3.11.1)
- **Provider** - State management (`context.watch` / `context.read` + `Builder`)
- **HTTP** - REST API client
- **Google Fonts** - Custom font picker
- **Material 3** - Theming & UI components

## Fitur

- Daftar restoran dengan gambar, rating, dan kota
- Detail restoran (deskripsi, menu makanan & minuman, kategori)
- Pencarian restoran
- Tulis & kirim ulasan
- Dark mode / Light mode toggle
- Pilih warna tema (10 pilihan warna)
- Pilih font (8 pilihan Google Fonts)
- Hero animation untuk transisi gambar

## Struktur Project

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MultiProvider & MaterialApp setup
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # Base URL & image endpoints
│   └── theme/
│       └── app_theme.dart             # Light & dark ThemeData factory
├── data/
│   ├── models/
│   │   ├── restaurant.dart            # Model list restoran
│   │   ├── restaurant_detail.dart     # Model detail restoran
│   │   ├── menu_item.dart             # Model item menu
│   │   └── customer_review.dart       # Model ulasan
│   └── repositories/
│       ├── restaurant_repository.dart      # Abstract interface
│       └── restaurant_repository_impl.dart # Implementasi HTTP client
├── providers/
│   ├── restaurant_list_provider.dart  # State management list restoran
│   ├── restaurant_detail_provider.dart # State management detail & review
│   ├── search_provider.dart           # State management pencarian
│   └── theme_provider.dart            # State management tema, warna, font
└── ui/
    ├── screens/
    │   ├── restaurant_list/
    │   │   └── restaurant_list_screen.dart   # Halaman utama daftar restoran
    │   ├── restaurant_detail/
    │   │   └── restaurant_detail_screen.dart # Halaman detail restoran
    │   ├── search/
    │   │   └── search_screen.dart            # Halaman pencarian
    │   ├── color_picker/
    │   │   └── color_picker_screen.dart      # Halaman pilih warna tema
    │   └── font_picker/
    │       └── font_picker_screen.dart       # Halaman pilih font
    └── widgets/
        ├── restaurant_card.dart       # Card restoran (reusable)
        ├── error_view.dart            # Widget error dengan tombol retry
        └── loading_indicator.dart     # Loading spinner
```

## Arsitektur

```
UI (StatelessWidget + Builder)
  ↕ context.watch / context.read
Provider (ChangeNotifier + sealed class State)
  ↕
Repository (abstract interface)
  ↕
HTTP Client (REST API)
```

- **Sealed class** untuk state management (`Loading`, `Loaded`, `Error`, `Initial`)
- **`context.watch<T>()`** di dalam `Builder` untuk scoped rebuild
- **`context.read<T>()`** di callback untuk one-time access tanpa subscribe
- **Repository pattern** dengan abstract interface untuk dependency injection

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

## API

Base URL: `https://restaurant-api.dicoding.dev`

| Endpoint | Method | Keterangan |
|---|---|---|
| `/list` | GET | Daftar semua restoran |
| `/detail/{id}` | GET | Detail restoran berdasarkan ID |
| `/search?q={query}` | GET | Pencarian restoran |
| `/review` | POST | Kirim ulasan baru |
# restaurant_app_flutter
