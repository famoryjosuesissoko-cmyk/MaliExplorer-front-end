import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/plat_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final platServiceProvider = Provider<PlatService>((ref) {
  return PlatService(ref.watch(apiServiceProvider));
});

class PlatService {
  final ApiService _apiService;

  PlatService(this._apiService);

  Future<List<PlatModel>> getPlats() async {
    final response = await _apiService.get(ApiConstants.plats);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => PlatModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les plats.');
    }
  }

  Future<PlatModel> getPlatById(int id) async {
    final response = await _apiService.get('${ApiConstants.plats}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return PlatModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer le plat #$id.');
    }
  }
}
