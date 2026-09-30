import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/evenement_model.dart';

/// Service pour récupérer et rechercher les événements culturels et festivals au Mali.
class EvenementService {
  final ApiService _apiService;

  EvenementService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<EvenementModel>> getAllEvenements() async {
    try {
      final response = await _apiService.get(ApiConstants.evenements);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        return list.map((item) => EvenementModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<EvenementModel?> getEvenementById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.evenements}/$id');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return EvenementModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }
}
