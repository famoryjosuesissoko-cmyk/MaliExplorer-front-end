import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ethnie_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final ethnieServiceProvider = Provider<EthnieService>((ref) {
  return EthnieService(ref.watch(apiServiceProvider));
});

class EthnieService {
  final ApiService _apiService;

  EthnieService(this._apiService);

  Future<List<EthnieModel>> getEthnies() async {
    final response = await _apiService.get(ApiConstants.ethnies);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => EthnieModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les ethnies.');
    }
  }

  Future<EthnieModel> getEthnieById(int id) async {
    final response = await _apiService.get('${ApiConstants.ethnies}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return EthnieModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer l\'ethnie #$id.');
    }
  }
}
