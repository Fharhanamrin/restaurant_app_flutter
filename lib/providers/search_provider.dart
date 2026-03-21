import 'package:flutter/foundation.dart';

import '../data/repositories/restaurant_repository.dart';
import 'states/search_state.dart';

export 'states/search_state.dart';

class SearchProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  SearchProvider(this._repository);

  SearchState _state = SearchInitial();
  SearchState get state => _state;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _state = SearchInitial();
      notifyListeners();
      return;
    }
    _state = SearchLoading();
    notifyListeners();
    try {
      final restaurants = await _repository.search(query.trim());
      _state = SearchLoaded(restaurants, query.trim());
    } catch (e) {
      _state = SearchError(e.toString());
    } finally {
      notifyListeners();
    }
  }

  void clearResults() {
    _state = SearchInitial();
    notifyListeners();
  }
}
