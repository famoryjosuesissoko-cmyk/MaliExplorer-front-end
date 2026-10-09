import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/president_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final presidentServiceProvider = Provider<PresidentService>((ref) {
  return PresidentService(ref.watch(apiServiceProvider));
});

class PresidentService {
  final ApiService _apiService;

  PresidentService(this._apiService);

  Future<List<PresidentModel>> getPresidents() async {
    try {
      final response = await _apiService.get(ApiConstants.presidents);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonList.isNotEmpty) {
          final apiPresidents = jsonList
              .map((j) => PresidentModel.fromJson(j as Map<String, dynamic>))
              .toList();
          // Si l'API a les 9 présidents complets, on la retourne
          if (apiPresidents.length >= PresidentModel.chronologicalPresidents.length) {
            return apiPresidents;
          }
        }
      }
    } catch (_) {
      // Fallback offline automatique
    }
    return PresidentModel.chronologicalPresidents;
  }

  Future<PresidentModel> getPresidentById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.presidents}/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return PresidentModel.fromJson(data);
      }
    } catch (_) {
      // Fallback
    }
    return PresidentModel.chronologicalPresidents.firstWhere(
      (p) => p.id == id,
      orElse: () => PresidentModel.chronologicalPresidents.first,
    );
  }
}
