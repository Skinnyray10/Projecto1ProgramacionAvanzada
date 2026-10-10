import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/app_user.dart';
import '../models/car.dart';
import '../models/part.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.status});

  final String message;

  /// `null` cuando no hubo respuesta del servidor (sin internet, timeout).
  final int? status;

  bool get isNetwork => status == null;
  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult(this.token, this.user);

  final String token;
  final AppUser user;
}

class ApiClient {
  ApiClient({http.Client? client, String baseUrl = AppConfig.apiUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<AuthResult> login(String email, String password) async {
    final data = await _send('POST', '/api/auth/login',
        body: {'email': email, 'password': password});
    return _authResult(data);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final data = await _send('POST', '/api/auth/register',
        body: {'email': email, 'password': password, 'fullName': fullName});
    return _authResult(data);
  }

  Future<List<Part>> fetchParts(String token) async {
    final data = await _send('GET', '/api/parts', token: token);
    final list = (data['parts'] as List).cast<Map<String, dynamic>>();
    return list.map(Part.fromApi).toList();
  }

  Future<List<Car>> fetchCars(String token) async {
    final data = await _send('GET', '/api/cars', token: token);
    final list = (data['cars'] as List).cast<Map<String, dynamic>>();
    return list.map(Car.fromApi).toList();
  }

  AuthResult _authResult(Map<String, dynamic> data) => AuthResult(
        data['token'] as String,
        AppUser.fromJson(data['user'] as Map<String, dynamic>),
      );

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final request = http.Request(method, Uri.parse('$_baseUrl$path'))
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      final streamed =
          await _client.send(request).timeout(AppConfig.requestTimeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw const ApiException('Sin conexión con el servidor');
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } on http.ClientException {
      throw const ApiException('Sin conexión con el servidor');
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Respuesta inválida del servidor (HTTP ${response.statusCode})',
        status: response.statusCode,
      );
    }

    if (payload['ok'] != true) {
      throw ApiException(
        (payload['error'] ?? 'Error HTTP ${response.statusCode}').toString(),
        status: response.statusCode,
      );
    }
    return (payload['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
  }
}
