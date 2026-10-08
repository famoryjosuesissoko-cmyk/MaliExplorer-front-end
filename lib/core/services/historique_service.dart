import 'dart:convert';
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
      }
    } catch (_) {
      // Retourner une liste vide en cas d'erreur réseau pour afficher l'état empty
    }
    return [];
  }
}

