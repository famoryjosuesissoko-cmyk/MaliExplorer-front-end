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
    try {
      final response = await _apiService.get(ApiConstants.ethnies);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonList.isNotEmpty) {
          return jsonList
              .map((j) => EthnieModel.fromJson(j as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback automatique offline
    }
    return EthnieModel.defaultEthnies;
  }

  Future<EthnieModel> getEthnieById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.ethnies}/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return EthnieModel.fromJson(data);
      }
    } catch (_) {
      // Fallback automatique offline
    }
    return EthnieModel.defaultEthnies.firstWhere(
      (e) => e.id == id,
      orElse: () => EthnieModel.defaultEthnies.first,
    );
  }
}
