import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/ville_model.dart';

/// Service pour récupérer les villes et communes du Mali.
class VilleService {
  final ApiService _apiService;

  VilleService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<VilleModel>> getAllVilles() async {
    final response = await _apiService.get(ApiConstants.villes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => VilleModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les villes');
  }

  Future<VilleModel> getVilleById(int id) async {
    final response = await _apiService.get('${ApiConstants.villes}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return VilleModel.fromJson(data);
    }
    throw Exception('Ville introuvable');
  }

  Future<List<VilleModel>> getVillesByRegion(int regionId) async {
    final response = await _apiService.get('${ApiConstants.villes}/region/$regionId');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => VilleModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
