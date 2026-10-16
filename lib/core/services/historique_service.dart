import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/historique_point_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final historiqueServiceProvider = Provider<HistoriqueService>((ref) {
  return HistoriqueService(ref.watch(apiServiceProvider));
});

final historiqueIsOfflineProvider = StateProvider<bool>((ref) => false);

final userHistoriqueProvider = FutureProvider.autoDispose<List<HistoriquePointModel>>((ref) async {
  final service = ref.watch(historiqueServiceProvider);
  ref.read(historiqueIsOfflineProvider.notifier).state = false;
  return await service.getMonHistorique();
});

class HistoriqueService {
  final ApiService _apiService;

  HistoriqueService(this._apiService);

  Future<List<HistoriquePointModel>> getMonHistorique() async {
    final response = await _apiService.get('${ApiConstants.badges}/me/history');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList
          .map((item) => HistoriquePointModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Code HTTP ${response.statusCode} (${response.reasonPhrase ?? ''})');
    }
  }

  Future<bool> supprimerItem(int idHistorique) async {
    final response = await _apiService.delete('${ApiConstants.badges}/me/history/$idHistorique');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> viderToutHistorique() async {
    final response = await _apiService.delete('${ApiConstants.badges}/me/history');
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
