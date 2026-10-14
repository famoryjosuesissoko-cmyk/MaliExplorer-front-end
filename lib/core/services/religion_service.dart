import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/religion_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final religionServiceProvider = Provider<ReligionService>((ref) {
  return ReligionService(ref.watch(apiServiceProvider));
});

class ReligionService {
  final ApiService _apiService;

  ReligionService(this._apiService);

  Future<List<ReligionModel>> getReligions() async {
    try {
      final response = await _apiService.get(ApiConstants.religions);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonList.isNotEmpty) {
          return jsonList
              .map((j) => ReligionModel.fromJson(j as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[ReligionService] Erreur récupération religions: $e');
    }
    return ReligionModel.defaultReligions;
  }

  Future<ReligionModel> getReligionById(int id) async {
    try {
      final response = await _apiService.get('${ApiConstants.religions}/$id');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return ReligionModel.fromJson(data);
      }
    } catch (_) {}
    return ReligionModel.defaultReligions.firstWhere(
      (r) => r.id == id,
      orElse: () => ReligionModel.defaultReligions.first,
    );
  }
}

