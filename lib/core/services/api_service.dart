import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../constants/api_constants.dart';

/// Provider Riverpod global pour ApiService (Singleton partagé)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Client HTTP pour communiquer avec le backend Spring Boot de MaliExplorer.
class ApiService {
  final http.Client _client;
  static String? _sharedAuthToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  String _activeBaseUrl = ApiConstants.baseUrl;

  /// Récupère le token d'authentification actuel (partagé entre toutes les instances)
  String? get authToken => _sharedAuthToken;

  /// Définit le token Firebase ID pour authentifier les requêtes sortantes
  void setAuthToken(String? token) {
    _sharedAuthToken = token;
  }

  /// Garantit qu'un token Firebase frais est disponible avant chaque requête authentifiée
  Future<void> _ensureAuthToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _sharedAuthToken != null && _sharedAuthToken!.isNotEmpty) {
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken(forceRefresh);
        if (token != null && token.isNotEmpty) {
          _sharedAuthToken = token;
        }
      }
    } catch (_) {}
  }

  /// Headers par défaut pour toutes les requêtes
  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_sharedAuthToken != null && _sharedAuthToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_sharedAuthToken';
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

  /// Exécute une requête avec tentative de secours automatique sur les URLs candidates et rafraîchissement du token en cas de 401
  Future<http.Response> _executeWithFallback(
    Future<http.Response> Function(String baseUrl) requestFn,
  ) async {
    try {
      var res = await requestFn(_activeBaseUrl);
      if (res.statusCode == 401 && FirebaseAuth.instance.currentUser != null) {
        await _ensureAuthToken(forceRefresh: true);
        res = await requestFn(_activeBaseUrl);
      } else if (res.statusCode == 403 && (res.body.contains('Compte Bloqué') || res.body.contains('bloqué'))) {
        // Le compte actuellement connecté a été bloqué par l'administration : purger le token
        _sharedAuthToken = null;
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        // Retenter la requête sans token (visiteur anonyme) si c'était une consultation publique
        res = await requestFn(_activeBaseUrl);
      }
      ApiConstants.setActiveBaseUrl(_activeBaseUrl);
      return res;
    } catch (primaryError) {
      for (final candidate in ApiConstants.candidateUrls) {
        if (candidate != _activeBaseUrl) {
          try {
            var res = await requestFn(candidate).timeout(ApiConstants.probeTimeout);
            if (res.statusCode == 401 && FirebaseAuth.instance.currentUser != null) {
              await _ensureAuthToken(forceRefresh: true);
              res = await requestFn(candidate).timeout(ApiConstants.probeTimeout);
            } else if (res.statusCode == 403 && (res.body.contains('Compte Bloqué') || res.body.contains('bloqué'))) {
              _sharedAuthToken = null;
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}
              res = await requestFn(candidate).timeout(ApiConstants.probeTimeout);
            }
            _activeBaseUrl = candidate; // Sauvegarde de l'URL fonctionnelle
            ApiConstants.setActiveBaseUrl(candidate);
            return res;
          } catch (_) {
            continue;
          }
        }
      }
      rethrow;
    }
  }

  /// Requête GET
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    await _ensureAuthToken();
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, queryParams, baseUrl);
      return await _client.get(url, headers: _buildHeaders(headers)).timeout(ApiConstants.quickTimeout);
    });
  }

  /// Requête POST
  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    await _ensureAuthToken();
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
    await _ensureAuthToken();
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, null, baseUrl);
      final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
      return await _client
          .put(url, headers: _buildHeaders(headers), body: encodedBody)
          .timeout(ApiConstants.timeout);
    });
  }

  /// Requête DELETE
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    await _ensureAuthToken();
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, null, baseUrl);
      return await _client.delete(url, headers: _buildHeaders(headers)).timeout(ApiConstants.timeout);
    });
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
    await _ensureAuthToken();
    return _executeWithFallback((baseUrl) async {
      final url = _buildUri(endpoint, null, baseUrl);
      final request = http.MultipartRequest('POST', url);

      if (_sharedAuthToken != null && _sharedAuthToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $_sharedAuthToken';
      }
      if (headers != null) {
        request.headers.addAll(headers);
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final cleanExt = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'jpg';
      final mediaType = cleanExt == 'png'
          ? MediaType('image', 'png')
          : cleanExt == 'webp'
              ? MediaType('image', 'webp')
              : cleanExt == 'gif'
                  ? MediaType('image', 'gif')
                  : cleanExt == 'svg'
                      ? MediaType('image', 'svg+xml')
                      : cleanExt == 'pdf'
                          ? MediaType('application', 'pdf')
                          : cleanExt == 'mp4'
                              ? MediaType('video', 'mp4')
                              : MediaType('image', 'jpeg');

      final multipartFile = http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: filename,
        contentType: mediaType,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      return await http.Response.fromStream(streamedResponse);
    });
  }
}
