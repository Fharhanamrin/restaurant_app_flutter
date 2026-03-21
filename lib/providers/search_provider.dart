import 'package:flutter/foundation.dart';

import '../data/models/restaurant.dart';
import '../data/repositories/restaurant_repository.dart';

sealed class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Restaurant> restaurants;
  final String query;
  SearchLoaded(this.restaurants, this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

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
      _state = SearchError(e.toString().replaceFirst('Exception: ', ''));
    }
    notifyListeners();
  }

  void clearResults() {
    _state = SearchInitial();
    notifyListeners();
  }
}
