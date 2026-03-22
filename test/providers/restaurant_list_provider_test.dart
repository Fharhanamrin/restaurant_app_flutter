import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_app_flutter/data/models/restaurant.dart';
import 'package:restaurant_app_flutter/data/repositories/restaurant_repository.dart';
import 'package:restaurant_app_flutter/providers/restaurant_list_provider.dart';

@GenerateMocks([RestaurantRepository])
import 'restaurant_list_provider_test.mocks.dart';

void main() {
  late MockRestaurantRepository mockRepository;

  setUp(() {
    mockRepository = MockRestaurantRepository();
  });

  final testRestaurants = [
    const Restaurant(
      id: '1',
      name: 'Restoran A',
      description: 'Deskripsi A',
      pictureId: 'pic1',
      city: 'Jakarta',
      rating: 4.5,
    ),
    const Restaurant(
      id: '2',
      name: 'Restoran B',
      description: 'Deskripsi B',
      pictureId: 'pic2',
      city: 'Bandung',
      rating: 4.0,
    ),
  ];

  test('state awal provider harus RestaurantListInitial sebelum fetchList', () {
    when(mockRepository.getList()).thenAnswer(
      (_) async => Future.delayed(const Duration(seconds: 10), () => []),
    );

    final provider = RestaurantListProvider(mockRepository);

    expect(provider.state, isA<RestaurantListLoading>());
  });

  test(
    'harus mengembalikan daftar restoran ketika pengambilan data API berhasil',
    () async {
      when(mockRepository.getList()).thenAnswer((_) async => testRestaurants);

      final provider = RestaurantListProvider(mockRepository);

      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      expect(provider.state, isA<RestaurantListLoaded>());
      final loaded = provider.state as RestaurantListLoaded;
      expect(loaded.restaurants.length, 2);
      expect(loaded.restaurants.first.name, 'Restoran A');
    },
  );

  test(
    'harus mengembalikan kesalahan ketika pengambilan data API gagal',
    () async {
      when(mockRepository.getList()).thenThrow(Exception('Network error'));

      final provider = RestaurantListProvider(mockRepository);

      await Future.delayed(Duration.zero);
      await Future.delayed(Duration.zero);

      expect(provider.state, isA<RestaurantListError>());
      final error = provider.state as RestaurantListError;
      expect(error.message, contains('Network error'));
    },
  );
}
