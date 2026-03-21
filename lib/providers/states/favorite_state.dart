import '../../data/models/restaurant.dart';

sealed class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<Restaurant> restaurants;

  FavoriteLoaded(this.restaurants);
}

class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError(this.message);
}
