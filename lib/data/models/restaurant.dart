class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final double rating;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    pictureId: json['pictureId'] as String,
    city: json['city'] as String,
    rating: (json['rating'] as num).toDouble(),
  );

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    pictureId: map['pictureId'] as String,
    city: map['city'] as String,
    rating: (map['rating'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'pictureId': pictureId,
    'city': city,
    'rating': rating,
  };
}
