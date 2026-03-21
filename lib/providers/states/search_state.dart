import '../../data/models/restaurant.dart';

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
