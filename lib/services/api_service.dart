import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error legible para mostrar en la interfaz.
class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Cliente HTTP único para toda la aplicación.
///
/// Por defecto apunta al emulador Android (10.0.2.2 = localhost de la PC).
/// Se puede cambiar al compilar:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
class ApiService {
  ApiService({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  String? _token;
  String? get token => _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) => _request('GET', path);

  Future<dynamic> post(String path, {Object? body}) =>
      _request('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _request('PUT', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    late final http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: _headers);
        case 'POST':
          response = await _client.post(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          );
        case 'PUT':
          response = await _client.put(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          );
        case 'DELETE':
          response = await _client.delete(uri, headers: _headers);
        default:
          throw ApiException('Método HTTP no soportado: $method');
      }
    } catch (error) {
      if (error is ApiException) rethrow;
      throw ApiException(
        'No se pudo conectar con la API ($baseUrl). '
        'Verifica que XAMPP y uvicorn estén encendidos.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    var mensaje = 'Error ${response.statusCode} al procesar la petición';
    try {
      final data = jsonDecode(response.body);
      final detail = data['detail'];
      if (detail is String) mensaje = detail;
    } catch (_) {}

    if (response.statusCode == 401) {
      throw ApiException(
        'Sesión no autorizada o expirada. Inicia sesión de nuevo.',
        401,
      );
    }
    throw ApiException(mensaje, response.statusCode);
  }
}

/// Instancia compartida por los providers.
final apiService = ApiService();
