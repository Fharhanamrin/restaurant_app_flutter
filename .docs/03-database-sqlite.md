# Database SQLite (Favorit)

## Teori

### Apa itu SQLite?

SQLite adalah database relasional yang berjalan **secara lokal di device** tanpa membutuhkan server. Data disimpan sebagai file di filesystem device.

Pada Flutter, package `sqflite` menyediakan API untuk menggunakan SQLite.

### Kapan Pakai SQLite?

| SQLite cocok untuk | SQLite tidak cocok untuk |
|--------------------|--------------------------|
| Data terstruktur (tabel, relasi) | Data key-value sederhana (pakai SharedPreferences) |
| Query kompleks (WHERE, JOIN) | Data yang harus sinkron dengan server real-time |
| Menyimpan banyak record | File besar (pakai filesystem) |

Pada project ini, SQLite digunakan untuk **menyimpan daftar restoran favorit**.

## Singleton Pattern

`DatabaseHelper` menggunakan **Singleton Pattern** — hanya ada **satu instance** di seluruh aplikasi:

```dart
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();  // Private constructor

  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  Future<Database> get database async => _database ??= await _initDb();
}
```

Mengapa singleton?
- Database connection mahal untuk dibuat
- Hanya butuh satu koneksi ke file database
- Menghindari conflict saat multiple akses

### Operator `??=`

```dart
_instance ??= DatabaseHelper._();
```

Artinya: jika `_instance` null, buat instance baru dan assign. Jika sudah ada, gunakan yang lama.

## Skema Database

```sql
CREATE TABLE favorites (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  pictureId TEXT NOT NULL,
  city TEXT NOT NULL,
  rating REAL NOT NULL
)
```

Kolom `id` menggunakan `TEXT` (bukan `INTEGER`) karena ID restoran dari API berbentuk string.

## Operasi CRUD

### Create (Insert)

```dart
Future<void> insertFavorite(Restaurant restaurant) async {
  final db = await database;
  await db.insert(
    'favorites',
    restaurant.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
```

`ConflictAlgorithm.replace` — jika ID sudah ada, data lama akan diganti.

### Read (Query)

```dart
Future<List<Restaurant>> getFavorites() async {
  final db = await database;
  final maps = await db.query('favorites');
  return maps.map((map) => Restaurant.fromMap(map)).toList();
}

Future<bool> isFavorite(String id) async {
  final db = await database;
  final result = await db.query('favorites', where: 'id = ?', whereArgs: [id]);
  return result.isNotEmpty;
}
```

`whereArgs` menggunakan **parameterized query** untuk mencegah SQL injection.

### Delete

```dart
Future<void> removeFavorite(String id) async {
  final db = await database;
  await db.delete('favorites', where: 'id = ?', whereArgs: [id]);
}
```

## Model toMap / fromMap

Untuk menyimpan dan membaca data dari SQLite, model `Restaurant` perlu method konversi:

```dart
class Restaurant {
  // ...

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'pictureId': pictureId,
    'city': city,
    'rating': rating,
  };

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    pictureId: map['pictureId'] as String,
    city: map['city'] as String,
    rating: (map['rating'] as num).toDouble(),
  );
}
```

Perbedaan dengan `fromJson`:
- `fromJson` untuk parsing data dari API (network)
- `fromMap` untuk parsing data dari SQLite (local database)
- Strukturnya sama, tapi dipisah untuk kejelasan asal data

## Repository Pattern untuk Favorit

```dart
// Interface
abstract interface class FavoriteRepository {
  Future<List<Restaurant>> getAll();
  Future<void> add(Restaurant restaurant);
  Future<void> remove(String id);
  Future<bool> isFavorite(String id);
}

// Implementasi
class FavoriteRepositoryImpl implements FavoriteRepository {
  final DatabaseHelper _dbHelper;

  FavoriteRepositoryImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<Restaurant>> getAll() => _dbHelper.getFavorites();
  // ...
}
```

## FavoriteProvider

Provider mengelola state dan menyediakan method untuk UI:

```dart
class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _repository;
  FavoriteState _state = FavoriteInitial();
  final Map<String, bool> _favoriteStatus = {};

  bool isFavorite(String id) => _favoriteStatus[id] ?? false;

  Future<void> toggleFavorite(Restaurant restaurant) async {
    final current = _favoriteStatus[restaurant.id] ?? false;
    if (current) {
      await _repository.remove(restaurant.id);
      _favoriteStatus[restaurant.id] = false;
    } else {
      await _repository.add(restaurant);
      _favoriteStatus[restaurant.id] = true;
    }
    notifyListeners();
    await loadFavorites();  // Refresh list
  }
}
```

`_favoriteStatus` Map digunakan untuk cek status favorit **tanpa query database** setiap kali, meningkatkan performa di halaman detail.

## Cara Mengkonversi RestaurantDetail ke Restaurant

Di halaman detail, data yang ada adalah `RestaurantDetail` (dari API), tapi SQLite menyimpan `Restaurant`. Konversi dilakukan saat toggle:

```dart
final r = Restaurant(
  id: restaurant.id,
  name: restaurant.name,
  description: restaurant.description,
  pictureId: restaurant.pictureId,
  city: restaurant.city,
  rating: restaurant.rating,
);
context.read<FavoriteProvider>().toggleFavorite(r);
```
