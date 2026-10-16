import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guide_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final guideServiceProvider = Provider<GuideService>((ref) {
  return GuideService(ref.watch(apiServiceProvider));
});

class GuideService {
  final ApiService _apiService;

  GuideService(this._apiService);

  Future<List<GuideModel>> getGuides() async {
    final response = await _apiService.get(ApiConstants.guides);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => GuideModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur de chargement des guides (Code ${response.statusCode})');
    }
  }

  Future<GuideModel?> getGuideById(int id) async {
    final response = await _apiService.get('${ApiConstants.guides}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return GuideModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erreur lors de la récupération du guide #$id (Code ${response.statusCode})');
    }
  }
}
