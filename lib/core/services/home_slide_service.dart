import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_slide_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final homeSlideServiceProvider = Provider<HomeSlideService>((ref) {
  return HomeSlideService(ref.watch(apiServiceProvider));
});

class HomeSlideService {
  final ApiService _apiService;

  HomeSlideService(this._apiService);

  Future<List<HomeSlideModel>> getActiveSlides() async {
    try {
      final response = await _apiService.get(ApiConstants.homeSlides);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        if (jsonList.isNotEmpty) {
          return jsonList
              .map((j) => HomeSlideModel.fromJson(j as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[HomeSlideService] Erreur récupération slides: $e');
    }
    return HomeSlideModel.defaultSlides;
  }
}

