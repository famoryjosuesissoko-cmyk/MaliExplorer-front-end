import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/plat_model.dart';

/// Service pour récupérer les plats gastronomiques traditionnels du Mali.
class PlatService {
  final ApiService _apiService;

  PlatService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<PlatModel>> getAllPlats() async {
    final response = await _apiService.get(ApiConstants.plats);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => PlatModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les plats');
  }

  Future<PlatModel> getPlatById(int id) async {
    final response = await _apiService.get('${ApiConstants.plats}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PlatModel.fromJson(data);
    }
    throw Exception('Plat introuvable');
  }
}
