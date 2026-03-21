# Tema & Material 3

## Teori

### Material 3 (Material You)

Material 3 adalah sistem desain terbaru dari Google. Perbedaan dengan Material 2:

| Aspek | Material 2 | Material 3 |
|-------|-----------|-----------|
| Warna | Palet warna manual | `ColorScheme.fromSeed()` — auto generate |
| Komponen | Flat design | Rounded, lebih ekspresif |
| Dark mode | Manual define warna | Otomatis dari seed color |
| Flutter flag | Default | `useMaterial3: true` |

### ColorScheme.fromSeed

```dart
ColorScheme.fromSeed(
  seedColor: Colors.purple,
  brightness: Brightness.light,
)
```

Dari **satu warna seed**, Flutter auto-generate seluruh palet warna (primary, secondary, tertiary, surface, background, error, dll.) yang harmonis dan accessible.

## Implementasi di Project

### AppTheme

File: `lib/core/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData light(
    Color seedColor,
    TextTheme Function([TextTheme?]) fontTextTheme,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      textTheme: fontTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }

  static ThemeData dark(Color seedColor, TextTheme Function([TextTheme?]) fontTextTheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: fontTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}
```

### Penerapan di MaterialApp

```dart
MaterialApp(
  theme: AppTheme.light(seedColor, fontTextTheme),      // Tema terang
  darkTheme: AppTheme.dark(seedColor, fontTextTheme),    // Tema gelap
  themeMode: themeProvider.themeMode,                     // System / Light / Dark
)
```

`themeMode` menentukan tema mana yang aktif:
- `ThemeMode.system` — ikut pengaturan OS
- `ThemeMode.light` — selalu terang
- `ThemeMode.dark` — selalu gelap

## ThemeProvider

Mengelola 3 aspek tema:

### 1. Mode (Light/Dark)

```dart
ThemeMode _themeMode;

Future<void> toggle() async {
  _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  await _prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
  notifyListeners();
}
```

Persisten via SharedPreferences → tema tetap sama setelah app ditutup dan dibuka.

### 2. Seed Color

```dart
static const List<AppColor> availableColors = [
  AppColor('Ungu', Color(0xFF6750A4)),
  AppColor('Biru', Color(0xFF1565C0)),
  // ... 10 pilihan
];

void setColor(Color color) {
  _seedColor = color;
  notifyListeners();
}
```

User memilih warna di `ColorPickerScreen` → seluruh UI berubah warna seketika.

### 3. Font

```dart
static final List<AppFont> availableFonts = [
  AppFont('Poppins', GoogleFonts.poppinsTextTheme),
  AppFont('Roboto', GoogleFonts.robotoTextTheme),
  // ... 8 pilihan
];

void setFont(AppFont font) {
  _selectedFont = font;
  notifyListeners();
}
```

Google Fonts di-load secara dinamis via package `google_fonts`.

## Cara Akses Warna Tema di Widget

```dart
// Warna background
Theme.of(context).colorScheme.surface

// Warna teks utama
Theme.of(context).colorScheme.onSurface

// Warna primary
Theme.of(context).colorScheme.primary

// Warna AppBar
Theme.of(context).colorScheme.inversePrimary

// Text style
Theme.of(context).textTheme.titleMedium
Theme.of(context).textTheme.bodySmall
```

### Properti ColorScheme yang Sering Dipakai

| Properti | Kegunaan |
|----------|----------|
| `primary` | Warna utama (tombol, icon aktif) |
| `onPrimary` | Teks di atas primary |
| `primaryContainer` | Background elemen terkait primary |
| `surface` | Background kartu, dialog |
| `onSurface` | Teks di atas surface |
| `onSurfaceVariant` | Teks sekunder |
| `inversePrimary` | AppBar background |
| `outlineVariant` | Garis batas, divider |
| `error` | Warna error |

## Tips Agar Tema Terlihat Jelas

1. **Jangan hardcode warna** — selalu gunakan `Theme.of(context).colorScheme.xxx`
2. **Gunakan `surfaceContainerHighest`** untuk placeholder/shimmer
3. **Test di kedua mode** — pastikan teks terbaca di light dan dark
4. **Icon warna** — gunakan `Theme.of(context).colorScheme.primary` atau `onSurfaceVariant`
