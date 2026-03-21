import 'customer_review.dart';
import 'menu_item.dart';

class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final List<String> categories;
  final List<MenuItem> foods;
  final List<MenuItem> drinks;
  final double rating;
  final List<CustomerReview> customerReviews;

  const RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.categories,
    required this.foods,
    required this.drinks,
    required this.rating,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    final menus = json['menus'] as Map<String, dynamic>;
    return RestaurantDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      pictureId: json['pictureId'] as String,
      categories: (json['categories'] as List)
          .map((e) => e['name'] as String)
          .toList(),
      foods: (menus['foods'] as List)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (menus['drinks'] as List)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num).toDouble(),
      customerReviews: (json['customerReviews'] as List)
          .map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  RestaurantDetail copyWith({List<CustomerReview>? customerReviews}) =>
      RestaurantDetail(
        id: id,
        name: name,
        description: description,
        city: city,
        address: address,
        pictureId: pictureId,
        categories: categories,
        foods: foods,
        drinks: drinks,
        rating: rating,
        customerReviews: customerReviews ?? this.customerReviews,
      );
}
