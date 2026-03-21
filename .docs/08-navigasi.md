# Navigasi

## Bottom Navigation Bar

Aplikasi menggunakan `NavigationBar` (Material 3) dengan 3 tab:

| Tab | Icon | Halaman |
|-----|------|---------|
| Home | `Icons.restaurant` | `RestaurantListScreen` |
| Favorit | `Icons.favorite` | `FavoriteScreen` |
| Pengaturan | `Icons.settings` | `SettingsScreen` |

### MainScreen

File: `lib/ui/screens/main/main_screen.dart`

```dart
class MainScreen extends StatefulWidget {
  // ...
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    RestaurantListScreen(),
    FavoriteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Favorit'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
```

### Mengapa IndexedStack?

`IndexedStack` menyimpan **semua child widget di memori** tetapi hanya menampilkan satu:

```
IndexedStack(index: 0)
├── RestaurantListScreen ← VISIBLE
├── FavoriteScreen       ← hidden but alive
└── SettingsScreen       ← hidden but alive
```

Keuntungan:
- State tiap tab **tidak hilang** saat pindah tab (scroll position, data loaded, dll.)
- Tidak perlu fetch ulang data saat kembali ke tab sebelumnya

Kerugian:
- Semua widget dibuild meskipun belum pernah dilihat
- Memori lebih besar (tapi untuk 3 tab masih wajar)

### NavigationBar vs BottomNavigationBar

| Aspek | NavigationBar (M3) | BottomNavigationBar (M2) |
|-------|-------------------|--------------------------|
| Design | Material 3, rounded | Material 2, flat |
| Item class | `NavigationDestination` | `BottomNavigationBarItem` |
| Callback | `onDestinationSelected` | `onTap` |
| Max items | 5 | 5 |

Kita menggunakan `NavigationBar` karena project ini sudah menggunakan Material 3.

## Navigasi Antar Halaman

### Push (ke halaman baru)

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
  ),
);
```

### Pop (kembali)

```dart
Navigator.pop(context);
// atau tekan tombol back di AppBar (otomatis)
```

### Pre-fetch Data Sebelum Navigate

Untuk menghindari tampilan data lama (stale data flash), data di-fetch **sebelum** navigasi:

```dart
onTap: () {
  // Trigger fetch terlebih dahulu
  context.read<RestaurantDetailProvider>().fetchDetail(restaurant.id);
  // Baru navigate
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
    ),
  );
},
```

Ini memastikan `RestaurantDetailProvider` sudah dalam state `Loading` saat halaman detail dibuild, bukan menampilkan data restoran sebelumnya.

## Hero Animation

Animasi transisi gambar antara halaman list dan detail:

**Di RestaurantCard (list):**
```dart
Hero(
  tag: 'restaurant_image_${restaurant.id}',
  child: Image.network(...),
)
```

**Di RestaurantDetailScreen (detail):**
```dart
Hero(
  tag: 'restaurant_image_${restaurant.id}',
  child: Image.network(...),
)
```

`tag` harus **sama persis** di kedua widget. Flutter akan otomatis membuat animasi transisi gambar saat navigasi.

## Struktur Navigasi

```
MainScreen (BottomNavBar)
├── Tab 0: RestaurantListScreen
│   ├── → SearchScreen
│   └── → RestaurantDetailScreen
├── Tab 1: FavoriteScreen
│   └── → RestaurantDetailScreen
└── Tab 2: SettingsScreen
    ├── → ColorPickerScreen
    └── → FontPickerScreen
```

Semua navigasi dari tab menggunakan `Navigator.push` biasa. Kembali dengan tombol back atau swipe gesture.
