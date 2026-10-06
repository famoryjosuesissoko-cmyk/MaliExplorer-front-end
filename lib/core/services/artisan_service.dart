import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/artisan_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final artisanServiceProvider = Provider<ArtisanService>((ref) {
  return ArtisanService(ref.watch(apiServiceProvider));
});

class ArtisanService {
  final ApiService _apiService;

  ArtisanService(this._apiService);

  Future<List<ArtisanModel>> getArtisans() async {
    final response = await _apiService.get(ApiConstants.artisans);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => ArtisanModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les artisans.');
    }
  }

  Future<ArtisanModel> getArtisanById(int id) async {
    final response = await _apiService.get('${ApiConstants.artisans}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return ArtisanModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer l\'artisan #$id.');
    }
  }
}
