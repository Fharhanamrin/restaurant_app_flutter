import 'package:flutter/foundation.dart';

import '../data/models/restaurant_detail.dart';
import '../data/repositories/restaurant_repository.dart';

sealed class RestaurantDetailState {}

class RestaurantDetailInitial extends RestaurantDetailState {}

class RestaurantDetailLoading extends RestaurantDetailState {}

class RestaurantDetailLoaded extends RestaurantDetailState {
  final RestaurantDetail restaurant;
  RestaurantDetailLoaded(this.restaurant);
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  RestaurantDetailError(this.message);
}

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantDetailProvider(this._repository);

  RestaurantDetailState _state = RestaurantDetailInitial();
  RestaurantDetailState get state => _state;

  bool _isSubmittingReview = false;
  bool get isSubmittingReview => _isSubmittingReview;

  Future<void> fetchDetail(String id) async {
    _state = RestaurantDetailLoading();
    notifyListeners();
    try {
      final restaurant = await _repository.getDetail(id);
      _state = RestaurantDetailLoaded(restaurant);
    } catch (e) {
      _state =
          RestaurantDetailError(e.toString().replaceFirst('Exception: ', ''));
    }
    notifyListeners();
  }

  /// Returns null on success, error message string on failure.
  Future<String?> submitReview({
    required String id,
    required String name,
    required String review,
  }) async {
    _isSubmittingReview = true;
    notifyListeners();
    try {
      final reviews =
          await _repository.addReview(id: id, name: name, review: review);
      final current = _state;
      if (current is RestaurantDetailLoaded) {
        _state = RestaurantDetailLoaded(
          current.restaurant.copyWith(customerReviews: reviews),
        );
      }
      _isSubmittingReview = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isSubmittingReview = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
