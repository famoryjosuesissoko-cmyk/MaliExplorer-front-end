import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/lieu_historique_model.dart';

/// Service pour récupérer les lieux historiques et les panoramas 360°.
class LieuHistoriqueService {
  final ApiService _apiService;

  LieuHistoriqueService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<LieuHistoriqueModel>> getAllLieux() async {
    final response = await _apiService.get(ApiConstants.lieuxHistoriques);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => LieuHistoriqueModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les lieux historiques');
  }

  Future<LieuHistoriqueModel> getLieuById(int id) async {
    final response = await _apiService.get('${ApiConstants.lieuxHistoriques}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return LieuHistoriqueModel.fromJson(data);
    }
    throw Exception('Lieu historique introuvable');
  }

  Future<List<LieuHistoriqueModel>> getLieuxWith360() async {
    final response = await _apiService.get('${ApiConstants.lieuxHistoriques}/360');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => LieuHistoriqueModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<LieuHistoriqueModel>> getMarqueursCarte() async {
    final response = await _apiService.get(ApiConstants.carteMarqueurs);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => LieuHistoriqueModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
