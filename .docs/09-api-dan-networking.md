# API & Networking

## REST API

Base URL: `https://restaurant-api.dicoding.dev`

### Endpoint

| Endpoint | Method | Keterangan | Response |
|----------|--------|------------|----------|
| `/list` | GET | Daftar semua restoran | `{ restaurants: [...] }` |
| `/detail/{id}` | GET | Detail restoran | `{ restaurant: {...} }` |
| `/search?q={query}` | GET | Pencarian | `{ restaurants: [...] }` |
| `/review` | POST | Kirim ulasan | `{ customerReviews: [...] }` |

### Image URL

| Size | URL Pattern |
|------|-------------|
| Small (100px) | `https://restaurant-api.dicoding.dev/images/small/{pictureId}` |
| Medium (350px) | `https://restaurant-api.dicoding.dev/images/medium/{pictureId}` |
| Large (original) | `https://restaurant-api.dicoding.dev/images/large/{pictureId}` |

## HTTP Package

Package `http` digunakan untuk request:

```dart
import 'package:http/http.dart' as http;

// GET
final response = await _client.get(Uri.parse('$baseUrl/list'));

// POST
final response = await _client.post(
  Uri.parse('$baseUrl/review'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'id': id, 'name': name, 'review': review}),
);
```

### Mengapa `http.Client` dan bukan `http.get` langsung?

```dart
class RestaurantRepositoryImpl implements RestaurantRepository {
  final http.Client _client;

  RestaurantRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();
}
```

Keuntungan inject `http.Client`:
- Bisa di-mock saat testing
- Bisa di-reuse (connection pooling)
- Bisa diganti dengan implementasi custom

## Error Handling

### AppException

```dart
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;  // Tanpa prefix "Exception:"
}
```

`toString()` langsung return `message` agar pesan error yang ditampilkan ke user bersih, tanpa prefix teknis.

### ErrorMessages

```dart
class ErrorMessages {
  static String serverError(int code) =>
      'Server error ($code). Coba beberapa saat lagi.';
  static const String parseError =
      'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.';
  static const String noInternet =
      'Tidak ada koneksi internet. Periksa jaringan kamu.';
  static const String cannotConnect =
      'Tidak dapat terhubung ke server.';
}
```

Semua pesan error dipusatkan di satu tempat agar:
- Konsisten di seluruh app
- Mudah diubah / diterjemahkan
- Mudah dipahami user (bukan pesan teknis)

### Penanganan di Repository

```dart
Future<List<Restaurant>> getList() async {
  try {
    final response = await _client.get(Uri.parse('$baseUrl/list'));
    final body = _parseJson(response);  // Cek status code + parse JSON
    if (body['error'] == true) throw AppException(body['message'] as String);
    return (body['restaurants'] as List)
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();
  } on SocketException {
    throw AppException(ErrorMessages.noInternet);
  } on HttpException {
    throw AppException(ErrorMessages.cannotConnect);
  }
}
```

Jenis error yang ditangani:

| Exception | Penyebab | Pesan ke User |
|-----------|----------|---------------|
| `SocketException` | Tidak ada internet | "Tidak ada koneksi internet..." |
| `HttpException` | Server tidak bisa dihubungi | "Tidak dapat terhubung ke server." |
| Status code != 2xx | Server error | "Server error (500)..." |
| `FormatException` | Response bukan JSON valid | "Tidak dapat terhubung..." |
| API `error: true` | API mengembalikan error | Pesan dari API |

### Penanganan di Provider

```dart
Future<void> fetchList() async {
  _state = RestaurantListLoading();
  notifyListeners();
  try {
    final restaurants = await _repository.getList();
    _state = RestaurantListLoaded(restaurants);
  } catch (e) {
    _state = RestaurantListError(e.toString());
  } finally {
    notifyListeners();  // Selalu dipanggil
  }
}
```

`finally` block memastikan `notifyListeners()` dipanggil baik sukses maupun gagal.

### Tampilan Error di UI

```dart
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  // Menampilkan icon, pesan error, dan tombol "Coba Lagi"
}
```

`ErrorView` widget reusable yang menampilkan:
1. Icon error
2. Pesan yang mudah dipahami
3. Tombol retry (opsional) yang memanggil `fetchList()` / `fetchDetail()` ulang

## Model Data

### Restaurant (dari /list dan /search)

```dart
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final double rating;
}
```

### RestaurantDetail (dari /detail/{id})

```dart
class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;       // Tambahan dari detail
  final String pictureId;
  final List<String> categories;  // Tambahan
  final List<MenuItem> foods;     // Tambahan
  final List<MenuItem> drinks;    // Tambahan
  final double rating;
  final List<CustomerReview> customerReviews;  // Tambahan
}
```

Detail memiliki lebih banyak field karena endpoint `/detail` mengembalikan data yang lebih lengkap.
