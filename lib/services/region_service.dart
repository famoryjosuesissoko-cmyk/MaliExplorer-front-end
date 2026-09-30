import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/region_model.dart';

/// Service pour récupérer les régions administratives et culturelles du Mali.
class RegionService {
  final ApiService _apiService;

  RegionService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<RegionModel>> getAllRegions() async {
    final response = await _apiService.get(ApiConstants.regions);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => RegionModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les régions');
  }

  Future<RegionModel> getRegionById(int id) async {
    final response = await _apiService.get('${ApiConstants.regions}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return RegionModel.fromJson(data);
    }
    throw Exception('Région introuvable');
  }
}
