import '../models/customer_review.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';

abstract interface class RestaurantRepository {
  Future<List<Restaurant>> getList();
  Future<RestaurantDetail> getDetail(String id);
  Future<List<Restaurant>> search(String query);
  Future<List<CustomerReview>> addReview({
    required String id,
    required String name,
    required String review,
  });
}
