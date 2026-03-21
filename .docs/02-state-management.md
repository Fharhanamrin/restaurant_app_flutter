# State Management dengan Provider

## Teori

### Apa itu Provider?

Provider adalah library state management yang direkomendasikan oleh tim Flutter untuk sebagian besar kasus. Provider membungkus `InheritedWidget` agar lebih mudah digunakan.

Konsep utama:
- **ChangeNotifier** — class yang bisa memberitahu "listener" ketika datanya berubah
- **ChangeNotifierProvider** — menyediakan ChangeNotifier ke widget tree
- **context.watch\<T\>()** — subscribe ke perubahan, widget akan rebuild saat state berubah
- **context.read\<T\>()** — baca sekali tanpa subscribe (untuk callback/onTap)

### Mengapa Bukan Consumer?

Pada versi lama Provider, `Consumer` widget banyak digunakan:

```dart
// ❌ Cara lama (Consumer)
Consumer<ThemeProvider>(
  builder: (context, theme, child) {
    return Text(theme.isDark ? 'Dark' : 'Light');
  },
)
```

Pada project ini, kita menggunakan API modern:

```dart
// ✅ Cara baru (context.watch + Builder)
Builder(
  builder: (context) {
    final theme = context.watch<ThemeProvider>();
    return Text(theme.isDark ? 'Dark' : 'Light');
  },
)
```

Keuntungan `Builder` + `context.watch`:
- Lebih mudah dibaca
- Bisa diletakkan persis di widget yang butuh data → **hanya widget tersebut yang rebuild**
- Konsisten dengan `context.read` untuk callback

### Aturan Penting

| Situasi | Gunakan | Alasan |
|---------|---------|--------|
| Menampilkan data reaktif di UI | `context.watch<T>()` | Subscribe ke perubahan |
| Memanggil method di onTap/onPressed | `context.read<T>()` | Baca sekali, tidak subscribe |
| Scoped rebuild (hanya sebagian widget) | Bungkus `context.watch` di dalam `Builder` | Builder membuat BuildContext baru |

### Jangan Lakukan Ini

```dart
// ❌ SALAH: watch di dalam callback
onPressed: () {
  final provider = context.watch<MyProvider>(); // Error!
  provider.doSomething();
}

// ✅ BENAR: read di dalam callback
onPressed: () {
  context.read<MyProvider>().doSomething();
}
```

## Sealed Class sebagai State

Dart 3 memperkenalkan **sealed class** yang cocok untuk memodelkan state:

```dart
sealed class RestaurantListState {}

class RestaurantListInitial extends RestaurantListState {}
class RestaurantListLoading extends RestaurantListState {}
class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;
  RestaurantListLoaded(this.restaurants);
}
class RestaurantListError extends RestaurantListState {
  final String message;
  RestaurantListError(this.message);
}
```

Keuntungan sealed class:
- **Exhaustive check** — compiler memaksa kita handle semua kemungkinan state
- **Pattern matching** — bisa destrukturisasi field langsung di `switch`
- **Type safety** — tidak mungkin lupa handle suatu state

### Pattern Matching di UI

```dart
return switch (provider.state) {
  RestaurantListInitial() => const SizedBox.shrink(),
  RestaurantListLoading() => const LoadingIndicator(),
  RestaurantListError(:final message) => ErrorView(message: message),
  RestaurantListLoaded(:final restaurants) => ListView.builder(
    itemCount: restaurants.length,
    itemBuilder: (context, index) => RestaurantCard(restaurant: restaurants[index]),
  ),
};
```

`:final message` adalah **destructuring pattern** — mengekstrak field `message` langsung dari sealed class.

## Provider yang Ada di Aplikasi

| Provider | State Type | Fungsi |
|----------|-----------|--------|
| `RestaurantListProvider` | `RestaurantListState` | Mengelola daftar restoran dari API |
| `RestaurantDetailProvider` | `RestaurantDetailState` | Mengelola detail restoran + review |
| `SearchProvider` | `SearchState` | Mengelola pencarian restoran |
| `FavoriteProvider` | `FavoriteState` | Mengelola daftar favorit dari SQLite |
| `ThemeProvider` | Direct fields | Mengelola tema, warna, font |
| `ReminderProvider` | Direct fields | Mengelola pengaturan daily reminder |

## Registrasi Provider

Semua provider didaftarkan di `app.dart` menggunakan `MultiProvider`:

```dart
MultiProvider(
  providers: [
    // Repository (non-reactive, Provider biasa)
    Provider<RestaurantRepository>(create: (_) => RestaurantRepositoryImpl()),
    Provider<FavoriteRepository>(create: (_) => FavoriteRepositoryImpl()),

    // Provider dengan state (ChangeNotifierProvider)
    ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
    ChangeNotifierProvider(create: (_) => ReminderProvider(prefs)),
    ChangeNotifierProvider(
      create: (ctx) => RestaurantListProvider(ctx.read<RestaurantRepository>()),
    ),
    // ...
  ],
)
```

Urutan penting: provider yang menjadi dependency harus didaftarkan **sebelum** provider yang membutuhkannya.

## Kapan StatelessWidget vs StatefulWidget?

| Gunakan StatelessWidget jika | Gunakan StatefulWidget jika |
|------------------------------|----------------------------|
| Semua state dikelola Provider | Butuh `TextEditingController` |
| Tidak butuh lifecycle method | Butuh `dispose()` untuk resource |
| Data fetching via Provider constructor | Butuh `AnimationController` |

Pada project ini:
- **StatelessWidget**: `RestaurantListScreen`, `RestaurantDetailScreen`, `FavoriteScreen`, `SettingsScreen`
- **StatefulWidget**: `SearchScreen` (butuh `TextEditingController`), `_ReviewSection` (butuh form controllers), `MainScreen` (butuh index state untuk bottom nav)
