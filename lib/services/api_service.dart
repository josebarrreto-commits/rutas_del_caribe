import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() : baseUrl = 'https://api.sitram.cecar.cloud/api';

  final String baseUrl;
  String? token;
  String? rol;
  void Function()? onUnauthorized;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(Uri.parse('$baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await http
        .put(Uri.parse('$baseUrl$path'),
            headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'),
            headers: _headers, body: body == null ? null : jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  String _errorMessage(int status, String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map) {
        final message = data['message']?.toString() ?? '';
        final errors = data['errors'];
        final details =
            errors is List ? errors.map((e) => e.toString()).join('\n') : '';
        final text =
            [message, details].where((s) => s.isNotEmpty).join('\n');
        if (text.isNotEmpty) return text;
      }
    } catch (_) {}
    return 'Error HTTP $status';
  }

  dynamic _decode(http.Response response) {
    final responseBody = response.body.trim();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint(
        '[API] ${response.request?.method} ${response.request?.url} '
        '-> ${response.statusCode} $responseBody',
      );
      if (response.statusCode == 401 && token != null) {
        onUnauthorized?.call();
      }
      throw ApiException(
        response.statusCode,
        _errorMessage(response.statusCode, responseBody),
      );
    }

    if (responseBody.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(responseBody);
    } on FormatException {
      throw Exception(
        'El servidor respondió con texto y no con JSON. '
        'Código HTTP: ${response.statusCode}. '
        'Respuesta: ${responseBody.substring(
          0,
          responseBody.length > 200 ? 200 : responseBody.length,
        )}',
      );
    }
  }
}