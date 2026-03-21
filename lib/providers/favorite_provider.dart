import 'package:flutter/foundation.dart';

import '../data/models/restaurant.dart';
import '../data/repositories/favorite_repository.dart';
import 'states/favorite_state.dart';

export 'states/favorite_state.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _repository;

  FavoriteProvider(this._repository) {
    loadFavorites();
  }

  FavoriteState _state = FavoriteInitial();
  FavoriteState get state => _state;

  final Map<String, bool> _favoriteStatus = {};

  bool isFavorite(String id) => _favoriteStatus[id] ?? false;

  Future<void> loadFavorites() async {
    try {
      final restaurants = await _repository.getAll();
      _favoriteStatus.clear();
      for (final r in restaurants) {
        _favoriteStatus[r.id] = true;
      }
      _state = FavoriteLoaded(restaurants);
    } catch (e) {
      _state = FavoriteError(e.toString());
    }
    notifyListeners();
  }

  Future<void> checkFavorite(String id) async {
    _favoriteStatus[id] = await _repository.isFavorite(id);
    notifyListeners();
  }

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
    await loadFavorites();
  }
}
