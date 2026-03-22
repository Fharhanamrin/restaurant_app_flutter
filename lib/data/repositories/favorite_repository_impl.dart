import '../local/database_helper.dart';
import '../models/restaurant.dart';
import 'favorite_repository.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final DatabaseHelper _dbHelper;

  FavoriteRepositoryImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();

  @override
  Future<List<Restaurant>> getAll() => _dbHelper.getFavorites();

  @override
  Future<void> add(Restaurant restaurant) =>
      _dbHelper.insertFavorite(restaurant);

  @override
  Future<void> remove(String id) => _dbHelper.removeFavorite(id);

  @override
  Future<bool> isFavorite(String id) => _dbHelper.isFavorite(id);
}
