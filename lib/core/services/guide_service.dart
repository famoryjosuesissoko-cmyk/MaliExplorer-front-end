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
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les guides.');
    }
  }

  Future<GuideModel> getGuideById(int id) async {
    final response = await _apiService.get('${ApiConstants.guides}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return GuideModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer le guide #$id.');
    }
  }
}
