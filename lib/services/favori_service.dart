import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/favori_model.dart';

/// Service gérant les favoris de l'utilisateur connecté auprès du backend Spring Boot.
class FavoriService {
  final ApiService _apiService;

  FavoriService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<FavoriModel>> getMesFavoris() async {
    final response = await _apiService.get(ApiConstants.favoris);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => FavoriModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> toggleLieuFavori(int lieuId, bool currentlyFavori) async {
    if (currentlyFavori) {
      final response = await _apiService.delete('${ApiConstants.favoris}/lieux/$lieuId');
      return !(response.statusCode >= 200 && response.statusCode < 300);
    } else {
      final response = await _apiService.post('${ApiConstants.favoris}/lieux/$lieuId');
      return response.statusCode >= 200 && response.statusCode < 300;
    }
  }

  Future<bool> toggleArticleFavori(int articleId, bool currentlyFavori) async {
    if (currentlyFavori) {
      final response = await _apiService.delete('${ApiConstants.favoris}/articles/$articleId');
      return !(response.statusCode >= 200 && response.statusCode < 300);
    } else {
      final response = await _apiService.post('${ApiConstants.favoris}/articles/$articleId');
      return response.statusCode >= 200 && response.statusCode < 300;
    }
  }

  Future<bool> supprimerFavori(int id) async {
    try {
      final response = await _apiService.delete('${ApiConstants.favoris}/$id');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isLieuFavori(int lieuId) async {
    try {
      final response = await _apiService.get('${ApiConstants.favoris}/lieux/$lieuId/exists');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return data['isFavori'] as bool? ?? false;
      }
    } catch (_) {}
    return false;
  }
}
