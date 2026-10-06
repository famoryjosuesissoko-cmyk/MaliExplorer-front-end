import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Provider Riverpod global pour ApiService (Singleton partagé)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Client HTTP pour communiquer avec le backend Spring Boot de MaliExplorer.
class ApiService {
  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  String _activeBaseUrl = ApiConstants.baseUrl;

  /// Récupère le token d'authentification actuel
  String? get authToken => _authToken;

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
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters, String? baseUrlOverride]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final base = baseUrlOverride ?? _activeBaseUrl;
    final urlString = '$base/$cleanEndpoint';
    final uri = Uri.parse(urlString);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final stringParams = queryParameters.map((key, value) => MapEntry(key, value.toString()));
      return uri.replace(queryParameters: stringParams);
    }
    return uri;
  }

  /// Exécute une requête avec tentative de secours automatique si la connexion échoue
  Future<http.Response> _executeWithFallback(
    Future<http.Response> Function(String baseUrl) requestFn,
  ) async {
    try {
      return await requestFn(_activeBaseUrl);
    } catch (_) {
      // Si la première tentative vers 127.0.0.1 échoue (ex: câble débranché), bascule sur l'IP LAN
      if (_activeBaseUrl != ApiConstants.fallbackLanUrl) {
        _activeBaseUrl = ApiConstants.fallbackLanUrl;
        return await requestFn(_activeBaseUrl);
      }
      rethrow;
    }
  }

  /// Requête GET
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, queryParams, baseUrl);
      return await _client.get(url, headers: _buildHeaders(headers)).timeout(ApiConstants.timeout);
    });
  }

  /// Requête POST
  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, null, baseUrl);
      final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
      return await _client
          .post(url, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(ApiConstants.timeout);
    });
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

  /// Requête Multipart POST pour l'envoi de fichiers vers Spring Boot / Supabase
  Future<http.Response> uploadMultipart(
    String endpoint, {
    required String fileFieldName,
    required List<int> fileBytes,
    required String filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final url = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', url);

    if (_authToken != null && _authToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = http.MultipartFile.fromBytes(
      fileFieldName,
      fileBytes,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
    return await http.Response.fromStream(streamedResponse);
  }
}
