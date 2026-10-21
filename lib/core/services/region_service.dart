import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/region_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final regionServiceProvider = Provider<RegionService>((ref) {
  return RegionService(ref.watch(apiServiceProvider));
});

class RegionService {
  final ApiService _apiService;

  RegionService(this._apiService);

  Future<List<RegionModel>> getRegions() async {
    try {
      final response = await _apiService.get(ApiConstants.regions);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        final apiRegions = jsonList
            .map((j) => RegionModel.fromJson(j as Map<String, dynamic>))
            .toList();
        if (apiRegions.isNotEmpty) {
          // Dédupliquer par id canonique en priorisant les régions avec description et coordonnées complètes
          final Map<String, RegionModel> byId = {};
          for (final r in apiRegions) {
            final existing = byId[r.id];
            if (existing == null ||
                (existing.description.isEmpty && r.description.isNotEmpty)) {
              byId[r.id] = r;
            }
          }
          for (final def in RegionData.regions) {
            byId.putIfAbsent(def.id, () => def);
          }
          return byId.values.toList();
        }
      }
    } catch (_) {
      // Repli transparent vers les données locales enrichies
    }
    return RegionData.regions;
  }
}

