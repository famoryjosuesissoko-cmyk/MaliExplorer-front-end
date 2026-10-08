import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/progression_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final badgeProgressionServiceProvider = Provider<BadgeProgressionService>((ref) {
  return BadgeProgressionService(ref.watch(apiServiceProvider));
});

final userProgressionProvider = FutureProvider.autoDispose<ProgressionModel?>((ref) async {
  final service = ref.watch(badgeProgressionServiceProvider);
  return await service.getMaProgression();
});

class BadgeProgressionService {
  final ApiService _apiService;

  BadgeProgressionService(this._apiService);

  Future<ProgressionModel?> getMaProgression() async {
    try {
      final response = await _apiService.get('${ApiConstants.badges}/me');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return ProgressionModel.fromJson(data);
      }
    } catch (_) {
      // Retourner null en mode hors-ligne
    }
    return null;
  }
}

