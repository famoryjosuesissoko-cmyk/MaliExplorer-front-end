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
    final response = await _apiService.get(ApiConstants.presidents);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => PresidentModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les chefs d\'État.');
    }
  }

  Future<PresidentModel> getPresidentById(int id) async {
    final response = await _apiService.get('${ApiConstants.presidents}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return PresidentModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer le président #$id.');
    }
  }
}
