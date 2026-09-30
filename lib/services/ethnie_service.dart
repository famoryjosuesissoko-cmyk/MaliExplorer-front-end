import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/ethnie_model.dart';

/// Service pour récupérer les ethnies et traditions culturelles du Mali.
class EthnieService {
  final ApiService _apiService;

  EthnieService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<EthnieModel>> getAllEthnies() async {
    final response = await _apiService.get(ApiConstants.ethnies);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => EthnieModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les ethnies');
  }

  Future<EthnieModel> getEthnieById(int id) async {
    final response = await _apiService.get('${ApiConstants.ethnies}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return EthnieModel.fromJson(data);
    }
    throw Exception('Ethnie introuvable');
  }
}
