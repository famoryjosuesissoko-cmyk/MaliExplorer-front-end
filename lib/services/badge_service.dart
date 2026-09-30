import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/badge_model.dart';

/// Service pour récupérer la progression et les Badges Bambara de l'utilisateur.
class BadgeService {
  final ApiService _apiService;

  BadgeService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<ProgressionModel> getProgression() async {
    final response = await _apiService.get(ApiConstants.progression);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ProgressionModel.fromJson(data);
    }
    throw Exception('Impossible de charger la progression des badges');
  }
}
