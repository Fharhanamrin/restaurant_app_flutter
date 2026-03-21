import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/constants/error_messages.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/customer_review.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import 'restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final http.Client _client;

  RestaurantRepositoryImpl({http.Client? client})
    : _client = client ?? http.Client();

  Map<String, dynamic> _parseJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException(ErrorMessages.serverError(response.statusCode));
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw AppException(ErrorMessages.parseError);
    }
  }

  @override
  Future<List<Restaurant>> getList() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/list'),
      );
      final body = _parseJson(response);
      if (body['error'] == true) throw AppException(body['message'] as String);
      return (body['restaurants'] as List)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw AppException(ErrorMessages.noInternet);
    } on HttpException {
      throw AppException(ErrorMessages.cannotConnect);
    }
  }

  @override
  Future<RestaurantDetail> getDetail(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}/detail/$id'),
      );
      final body = _parseJson(response);
      if (body['error'] == true) throw AppException(body['message'] as String);
      return RestaurantDetail.fromJson(
        body['restaurant'] as Map<String, dynamic>,
      );
    } on SocketException {
      throw AppException(ErrorMessages.noInternet);
    } on HttpException {
      throw AppException(ErrorMessages.cannotConnect);
    }
  }

  @override
  Future<List<Restaurant>> search(String query) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/search',
      ).replace(queryParameters: {'q': query});
      final response = await _client.get(uri);
      final body = _parseJson(response);
      if (body['error'] == true) throw AppException(body['message'] as String);
      return (body['restaurants'] as List)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw AppException(ErrorMessages.noInternet);
    } on HttpException {
      throw AppException(ErrorMessages.cannotConnect);
    }
  }

  @override
  Future<List<CustomerReview>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'review': review}),
      );
      final body = _parseJson(response);
      if (body['error'] == true) throw AppException(body['message'] as String);
      return (body['customerReviews'] as List)
          .map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw AppException(ErrorMessages.noInternet);
    } on HttpException {
      throw AppException(ErrorMessages.cannotConnect);
    }
  }
}
