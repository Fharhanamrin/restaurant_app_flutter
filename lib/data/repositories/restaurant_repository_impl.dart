import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../models/customer_review.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import 'restaurant_repository.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final http.Client _client;

  RestaurantRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  Map<String, dynamic> _parseJson(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception(
        'Server error (${response.statusCode}). Coba beberapa saat lagi.',
      );
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet kamu.');
    }
  }

  @override
  Future<List<Restaurant>> getList() async {
    try {
      final response =
          await _client.get(Uri.parse('${AppConstants.baseUrl}/list'));
      final body = _parseJson(response);
      if (body['error'] == true) throw Exception(body['message']);
      return (body['restaurants'] as List)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan kamu.');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  @override
  Future<RestaurantDetail> getDetail(String id) async {
    try {
      final response =
          await _client.get(Uri.parse('${AppConstants.baseUrl}/detail/$id'));
      final body = _parseJson(response);
      if (body['error'] == true) throw Exception(body['message']);
      return RestaurantDetail.fromJson(
          body['restaurant'] as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan kamu.');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }

  @override
  Future<List<Restaurant>> search(String query) async {
    try {
      final uri = Uri.parse('${AppConstants.baseUrl}/search')
          .replace(queryParameters: {'q': query});
      final response = await _client.get(uri);
      final body = _parseJson(response);
      if (body['error'] == true) throw Exception(body['message']);
      return (body['restaurants'] as List)
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan kamu.');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server.');
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
      if (body['error'] == true) throw Exception(body['message']);
      return (body['customerReviews'] as List)
          .map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan kamu.');
    } on HttpException {
      throw Exception('Tidak dapat terhubung ke server.');
    }
  }
}
