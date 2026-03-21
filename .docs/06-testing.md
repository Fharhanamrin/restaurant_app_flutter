# Testing

## Teori

### Jenis Testing di Flutter

Ada 3 jenis testing di Flutter:

| Jenis | Scope | Kecepatan | Dependency |
|-------|-------|-----------|------------|
| **Unit Test** | Satu class/function | Sangat cepat | Tidak perlu Flutter framework |
| **Widget Test** | Satu widget | Cepat | Butuh Flutter test framework |
| **Integration Test** | Seluruh app / flow | Lambat | Butuh device/emulator |

### Piramida Testing

```
        /\
       /  \      Integration Test (sedikit, mahal)
      /    \
     /──────\
    /        \   Widget Test (menengah)
   /          \
  /────────────\
 /              \ Unit Test (banyak, murah)
/________________\
```

Idealnya, unit test paling banyak karena paling cepat dan murah.

## Unit Test

### Lokasi: `test/providers/restaurant_list_provider_test.dart`

Unit test menguji **satu unit logic** secara terisolasi, tanpa dependency nyata.

### Mockito

Untuk mengisolasi unit yang ditest, dependency di-**mock** (diganti dengan objek palsu):

```dart
@GenerateMocks([RestaurantRepository])
import 'restaurant_list_provider_test.mocks.dart';
```

`@GenerateMocks` memberitahu Mockito untuk generate mock class. Jalankan code generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Ini akan membuat file `*.mocks.dart` yang berisi `MockRestaurantRepository`.

### Skenario Test

#### 1. State awal provider

```dart
test('state awal provider harus RestaurantListInitial sebelum fetchList', () {
  when(mockRepository.getList()).thenAnswer(
    (_) async => Future.delayed(const Duration(seconds: 10), () => []),
  );

  final provider = RestaurantListProvider(mockRepository);

  expect(provider.state, isA<RestaurantListLoading>());
});
```

Penjelasan:
- Mock repository dibuat lambat (10 detik delay) agar belum selesai saat kita cek
- Provider dibuat → constructor memanggil `fetchList()` → state langsung jadi `Loading`
- Kita cek state **sebelum** future selesai

#### 2. Fetch berhasil → state Loaded

```dart
test('harus mengembalikan daftar restoran ketika pengambilan data API berhasil', () async {
  when(mockRepository.getList()).thenAnswer((_) async => testRestaurants);

  final provider = RestaurantListProvider(mockRepository);

  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);

  expect(provider.state, isA<RestaurantListLoaded>());
  final loaded = provider.state as RestaurantListLoaded;
  expect(loaded.restaurants.length, 2);
});
```

Penjelasan:
- Mock repository langsung return data
- `await Future.delayed(Duration.zero)` dua kali → memberi waktu microtask queue selesai
- Setelah itu, state seharusnya sudah `Loaded`

#### 3. Fetch gagal → state Error

```dart
test('harus mengembalikan kesalahan ketika pengambilan data API gagal', () async {
  when(mockRepository.getList()).thenThrow(Exception('Network error'));

  final provider = RestaurantListProvider(mockRepository);

  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);

  expect(provider.state, isA<RestaurantListError>());
  final error = provider.state as RestaurantListError;
  expect(error.message, contains('Network error'));
});
```

Penjelasan:
- Mock repository throw exception
- Provider menangkap exception → set state `Error`

### Matchers yang Digunakan

| Matcher | Fungsi |
|---------|--------|
| `isA<Type>()` | Cek tipe object |
| `contains('text')` | Cek string mengandung substring |
| `findsOneWidget` | Cek widget ditemukan tepat 1 kali |
| `isTrue` / `isFalse` | Cek boolean |

## Widget Test

### Lokasi: `test/widgets/restaurant_card_test.dart`

Widget test menguji **tampilan dan interaksi** widget secara terisolasi.

```dart
testWidgets('RestaurantCard menampilkan nama, kota, dan rating restoran',
    (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RestaurantCard(
          restaurant: restaurant,
          onTap: () {},
        ),
      ),
    ),
  );

  expect(find.text('Restoran Test'), findsOneWidget);
  expect(find.text('Jakarta'), findsOneWidget);
  expect(find.text('4.5'), findsOneWidget);
});
```

Penjelasan:
- `tester.pumpWidget()` — render widget ke layar virtual
- Widget dibungkus `MaterialApp` + `Scaffold` karena butuh Material context
- `find.text()` — cari widget Text dengan isi tertentu
- `expect(finder, matcher)` — pastikan hasil sesuai ekspektasi

### Test Interaksi (onTap)

```dart
testWidgets('RestaurantCard memanggil onTap saat ditekan', (tester) async {
  var tapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RestaurantCard(
          restaurant: restaurant,
          onTap: () => tapped = true,
        ),
      ),
    ),
  );

  await tester.tap(find.byType(RestaurantCard));
  expect(tapped, isTrue);
});
```

Penjelasan:
- `tester.tap()` — simulasi tap pada widget
- Setelah tap, variabel `tapped` harus berubah jadi `true`

## Integration Test

### Lokasi: `integration_test/app_test.dart`

Integration test menguji **flow keseluruhan app** dari perspektif user.

```dart
testWidgets('App launch -> tampil daftar -> tap card -> navigasi ke detail',
    (tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(App(prefs: prefs));

  expect(find.text('Restoran'), findsOneWidget);

  await tester.pumpAndSettle(const Duration(seconds: 5));

  final cards = find.byType(Card);
  if (cards.evaluate().isNotEmpty) {
    await tester.tap(cards.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(CustomScrollView), findsOneWidget);
  }
});
```

Penjelasan:
- `SharedPreferences.setMockInitialValues({})` — wajib sebelum menggunakan SharedPreferences di test
- `pumpAndSettle()` — tunggu semua animasi dan async selesai
- Test ini mengakses **API sungguhan** — butuh internet
- Karena bergantung jaringan, ada guard `if (cards.evaluate().isNotEmpty)`

### Perbedaan pumpWidget, pump, pumpAndSettle

| Method | Fungsi |
|--------|--------|
| `pumpWidget(widget)` | Render widget pertama kali |
| `pump()` | Trigger satu frame rebuild |
| `pump(Duration)` | Advance time lalu trigger rebuild |
| `pumpAndSettle()` | Tunggu sampai tidak ada frame pending (animasi selesai) |

## Cara Menjalankan Test

```bash
# Semua unit + widget test
flutter test

# File tertentu
flutter test test/providers/restaurant_list_provider_test.dart

# Integration test (butuh device/emulator)
flutter test integration_test/app_test.dart

# Dengan verbose output
flutter test --reporter expanded
```

## Cara Generate Mock (setelah mengubah @GenerateMocks)

```bash
dart run build_runner build --delete-conflicting-outputs
```

Jalankan ini setiap kali mengubah annotation `@GenerateMocks` atau menambah method baru ke interface yang di-mock.

## Ringkasan Test di Project

| # | File | Jenis | Deskripsi |
|---|------|-------|-----------|
| 1 | `test/providers/restaurant_list_provider_test.dart` | Unit | State awal provider |
| 2 | `test/providers/restaurant_list_provider_test.dart` | Unit | Fetch berhasil → Loaded |
| 3 | `test/providers/restaurant_list_provider_test.dart` | Unit | Fetch gagal → Error |
| 4 | `test/widgets/restaurant_card_test.dart` | Widget | Card render nama, kota, rating |
| 5 | `test/widgets/restaurant_card_test.dart` | Widget | Card memanggil onTap |
| 6 | `integration_test/app_test.dart` | Integration | Launch → list → tap → detail |

Total: **6 test cases**, **3 jenis testing** (unit, widget, integration).
