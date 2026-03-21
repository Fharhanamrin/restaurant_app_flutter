import 'package:flutter/foundation.dart';

import '../data/repositories/restaurant_repository.dart';
import 'states/restaurant_list_state.dart';

export 'states/restaurant_list_state.dart';

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
      _state = RestaurantListError(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
