import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HttpClient {
  final http.Client _client = http.Client();

  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = _getStoredToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  String? _getStoredToken() {
    // TODO: Implementar obtención de token desde secure storage
    return null;
  }

  Future<T> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final response = await _client
          .get(uri, headers: _getHeaders(additionalHeaders: headers))
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> delete<T>(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client
          .delete(uri, headers: _getHeaders(additionalHeaders: headers))
          .timeout(ApiConfig.timeout);

      return _handleResponse<T>(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final url = '${ApiConfig.baseUrl}$endpoint';
    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  T _handleResponse<T>(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {} as T;
      }

      try {
        final dynamic decoded = jsonDecode(response.body);
        return decoded as T;
      } catch (e) {
        // Si la respuesta no es JSON, intentar manejarla como texto plano
        print('⚠️ Respuesta no-JSON del servidor: ${response.body}');

        // Si esperamos un Map y recibimos texto plano, crear un objeto básico
        if (T == Map<String, dynamic>) {
          return {'message': response.body.trim(), 'success': true} as T;
        }

        // Si no podemos manejar el tipo, relanzar el error
        throw ApiException(
          message: 'Respuesta inválida del servidor: ${e.toString()}',
          statusCode: response.statusCode,
          response: response.body,
        );
      }
    } else {
      throw ApiException(
        message: _extractErrorMessage(response),
        statusCode: response.statusCode,
        response: response.body,
      );
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Error desconocido';
    } catch (_) {
      return 'Error en la comunicación con el servidor';
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException(message: error.toString(), statusCode: 0);
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? response;

  ApiException({
    required this.message,
    required this.statusCode,
    this.response,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

final httpClient = HttpClient();
