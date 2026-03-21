import '../models/restaurant.dart';

abstract interface class FavoriteRepository {
  Future<List<Restaurant>> getAll();
  Future<void> add(Restaurant restaurant);
  Future<void> remove(String id);
  Future<bool> isFavorite(String id);
}
