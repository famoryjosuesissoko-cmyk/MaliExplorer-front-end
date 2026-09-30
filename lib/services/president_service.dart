import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/president_model.dart';

/// Service pour récupérer les présidents et figures historiques de la République du Mali.
class PresidentService {
  final ApiService _apiService;

  PresidentService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<PresidentModel>> getAllPresidents() async {
    final response = await _apiService.get(ApiConstants.presidents);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => PresidentModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger la liste des présidents');
  }

  Future<PresidentModel> getPresidentById(int id) async {
    final response = await _apiService.get('${ApiConstants.presidents}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return PresidentModel.fromJson(data);
    }
    throw Exception('Président introuvable');
  }
}
