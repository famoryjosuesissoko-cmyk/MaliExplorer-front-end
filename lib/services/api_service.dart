import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service client pour la communication avec le backend Spring Boot de MaliExplorer.
class ApiService {
  // Détection automatique de l'URL de base selon la plateforme en développement local :
  // - Sur émulateur Android standard : 10.0.2.2 pointe vers le localhost de la machine hôte.
  // - Sur le Web, iOS ou Desktop : localhost pointe directement vers la machine.
  // - Pour un appareil physique (Android/iOS) connecté en Wi-Fi : remplacer par l'IP locale (ex: 192.168.1.X:8080/api).
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  static String baseUrl = defaultBaseUrl;

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Headers par défaut pour toutes les requêtes JSON
  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// Formate l'URL complète avec le endpoint
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final urlString = '$baseUrl/$cleanEndpoint';
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
    return await _client.get(url, headers: _buildHeaders(headers));
  }

  /// Requête POST avec sérialisation JSON automatique
  Future<http.Response> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
    return await _client.post(
      url,
      headers: _buildHeaders(headers),
      body: encodedBody,
    );
  }

  /// Requête PUT avec sérialisation JSON automatique
  Future<http.Response> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    final encodedBody = body != null ? (body is String ? body : jsonEncode(body)) : null;
    return await _client.put(
      url,
      headers: _buildHeaders(headers),
      body: encodedBody,
    );
  }

  /// Requête DELETE
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final url = _buildUri(endpoint);
    return await _client.delete(url, headers: _buildHeaders(headers));
  }
}
