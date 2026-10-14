import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/historique_point_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final historiqueServiceProvider = Provider<HistoriqueService>((ref) {
  return HistoriqueService(ref.watch(apiServiceProvider));
});

final userHistoriqueProvider = FutureProvider.autoDispose<List<HistoriquePointModel>>((ref) async {
  final service = ref.watch(historiqueServiceProvider);
  return await service.getMonHistorique();
});

class HistoriqueService {
  final ApiService _apiService;

  HistoriqueService(this._apiService);

  Future<List<HistoriquePointModel>> getMonHistorique() async {
    try {
      final response = await _apiService.get('${ApiConstants.badges}/me/history');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonList
            .map((item) => HistoriquePointModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Code HTTP ${response.statusCode} (${response.reasonPhrase ?? ''})');
      }
    } catch (e) {
      debugPrint('[HistoriqueService] Échec récupération historique: $e');
      rethrow;
    }
  }

  Future<bool> supprimerItem(int idHistorique) async {
    try {
      final response = await _apiService.delete('${ApiConstants.badges}/me/history/$idHistorique');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[HistoriqueService] Échec suppression item $idHistorique: $e');
      return false;
    }
  }

  Future<bool> viderToutHistorique() async {
    try {
      final response = await _apiService.delete('${ApiConstants.badges}/me/history');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[HistoriqueService] Échec suppression historique complet: $e');
      return false;
    }
  }
}


