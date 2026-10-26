import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_controller.dart';
import '../../models/historique_point_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final historiqueServiceProvider = Provider<HistoriqueService>((ref) {
  return HistoriqueService(ref.watch(apiServiceProvider));
});

final historiqueIsOfflineProvider = StateProvider<bool>((ref) => false);

final userHistoriqueProvider = FutureProvider.autoDispose<List<HistoriquePointModel>>((ref) async {
  // Dépendre de l'identité de l'utilisateur connecté pour éviter tout cache inter-comptes
  ref.watch(authControllerProvider.select((s) => s.user?['idUsers'] ?? s.user?['email']));
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
      final items = jsonList
          .map((item) => HistoriquePointModel.fromJson(item as Map<String, dynamic>))
          .toList();
      final seenRefs = <String>{};
      final uniqueItems = <HistoriquePointModel>[];
      for (final item in items) {
        final ref = item.referenceActivite?.trim() ?? '';
        if (ref.isNotEmpty && !seenRefs.add(ref)) {
          continue;
        }
        uniqueItems.add(item);
      }
      return uniqueItems;
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
