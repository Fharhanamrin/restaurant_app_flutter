import 'package:flutter/foundation.dart';

import '../data/models/restaurant.dart';
import '../data/repositories/restaurant_repository.dart';

sealed class RestaurantListState {}

class RestaurantListInitial extends RestaurantListState {}

class RestaurantListLoading extends RestaurantListState {}

class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;
  RestaurantListLoaded(this.restaurants);
}

class RestaurantListError extends RestaurantListState {
  final String message;
  RestaurantListError(this.message);
}

class RestaurantListProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantListProvider(this._repository) {
    fetchList();
  }

  RestaurantListState _state = RestaurantListInitial();
  RestaurantListState get state => _state;

  Future<void> fetchList() async {
    _state = RestaurantListLoading();
    notifyListeners();
    try {
      final restaurants = await _repository.getList();
      _state = RestaurantListLoaded(restaurants);
    } catch (e) {
      _state = RestaurantListError(e.toString().replaceFirst('Exception: ', ''));
    }
    notifyListeners();
  }
}
