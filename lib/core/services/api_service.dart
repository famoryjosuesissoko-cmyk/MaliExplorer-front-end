import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Client HTTP pour communiquer avec le backend Spring Boot de MaliExplorer.
class ApiService {
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Définit le token Firebase ID pour authentifier les requêtes sortantes
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Headers par défaut pour toutes les requêtes
  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// Formate l'URL avec l'endpoint et les paramètres
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final urlString = '${ApiConstants.baseUrl}/$cleanEndpoint';
    final uri = Uri.parse(urlString);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((key, value) => MapEntry(key, value.toString()));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  /// Requête GET
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    final url = _buildUri(endpoint, queryParams);
    return await _client.get(url, headers: _buildHeaders(headers)).timeout(ApiConstants.timeout);
  }

  /// Requête POST
  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
    return await _client
        .post(url, headers: _buildHeaders(headers), body: encodedBody)
        .timeout(ApiConstants.timeout);
  }

  /// Requête PUT
  Future<http.Response> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
    return await _client
        .put(url, headers: _buildHeaders(headers), body: encodedBody)
        .timeout(ApiConstants.timeout);
  }

  /// Requête DELETE
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    return await _client.delete(url, headers: _buildHeaders(headers)).timeout(ApiConstants.timeout);
  }
}
