import 'package:flutter/foundation.dart';

import '../data/repositories/restaurant_repository.dart';
import 'states/restaurant_detail_state.dart';

export 'states/restaurant_detail_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantDetailProvider(this._repository);

  RestaurantDetailState _state = RestaurantDetailInitial();
  RestaurantDetailState get state => _state;

  bool _isSubmittingReview = false;
  bool get isSubmittingReview => _isSubmittingReview;

  bool _isDescriptionExpanded = false;
  bool get isDescriptionExpanded => _isDescriptionExpanded;

  void toggleDescription() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  Future<void> fetchDetail(String id) async {
    _state = RestaurantDetailLoading();
    notifyListeners();
    try {
      final restaurant = await _repository.getDetail(id);
      _state = RestaurantDetailLoaded(restaurant);
    } catch (e) {
      _state = RestaurantDetailError(e.toString());
    } finally {
      notifyListeners();
    }
  }

  /// Returns null on success, error message string on failure.
  Future<String?> submitReview({
    required String id,
    required String name,
    required String review,
  }) async {
    _isSubmittingReview = true;
    notifyListeners();
    String? result;
    try {
      final reviews = await _repository.addReview(
        id: id,
        name: name,
        review: review,
      );

      final current = _state;
      if (current is RestaurantDetailLoaded) {
        _state = RestaurantDetailLoaded(
          current.restaurant.copyWith(customerReviews: reviews),
        );
      }
      result = null;
    } catch (e) {
      result = e.toString();
    } finally {
      _isSubmittingReview = false;
      notifyListeners();
    }
    return result;
  }
}
