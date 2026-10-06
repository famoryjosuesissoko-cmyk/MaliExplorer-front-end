import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ville_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final villeServiceProvider = Provider<VilleService>((ref) {
  return VilleService(ref.watch(apiServiceProvider));
});

class VilleService {
  final ApiService _apiService;

  VilleService(this._apiService);

  Future<List<VilleModel>> getVilles() async {
    final response = await _apiService.get(ApiConstants.villes);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => VilleModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les villes.');
    }
  }

  Future<VilleModel> getVilleById(int id) async {
    final response = await _apiService.get('${ApiConstants.villes}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return VilleModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer la ville #$id.');
    }
  }
}
