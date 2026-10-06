import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/favori_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final favoriServiceProvider = Provider<FavoriService>((ref) {
  return FavoriService(ref.watch(apiServiceProvider));
});

class FavoriService {
  final ApiService _apiService;

  FavoriService(this._apiService);

  Future<List<FavoriModel>> getFavoris() async {
    // Si l'utilisateur n'est pas connecté ou sans token, on retourne une liste vide sans crasher
    if (_apiService.authToken == null || _apiService.authToken!.isEmpty) {
      return [];
    }
    final response = await _apiService.get(ApiConstants.favoris);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => FavoriModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      return [];
    }
  }

  Future<bool> ajouterLieuFavori(int lieuId) async {
    final response = await _apiService.post('${ApiConstants.favoris}/lieux/$lieuId');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> supprimerLieuFavori(int lieuId) async {
    final response = await _apiService.delete('${ApiConstants.favoris}/lieux/$lieuId');
    return response.statusCode == 200;
  }

  Future<bool> ajouterArticleFavori(int articleId) async {
    final response = await _apiService.post('${ApiConstants.favoris}/articles/$articleId');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> supprimerArticleFavori(int articleId) async {
    final response = await _apiService.delete('${ApiConstants.favoris}/articles/$articleId');
    return response.statusCode == 200;
  }

  Future<bool> estLieuFavori(int lieuId) async {
    try {
      final response = await _apiService.get('${ApiConstants.favoris}/lieux/$lieuId/exists');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['isFavori'] == true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> estArticleFavori(int articleId) async {
    try {
      final response = await _apiService.get('${ApiConstants.favoris}/articles/$articleId/exists');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['isFavori'] == true;
      }
    } catch (_) {}
    return false;
  }
}
