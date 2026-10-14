import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ethnie_model.dart';
import '../../models/plat_model.dart';
import '../../models/region_model.dart';
import '../../models/religion_model.dart';
import '../../models/search_result_item.dart';
import '../../router/app_router.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(apiServiceProvider));
});

class SearchService {
  final ApiService _apiService;

  SearchService(this._apiService);

  Future<List<SearchResultItem>> search(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 2) return [];

    List<SearchResultItem> remoteResults = [];

    try {
      final encoded = Uri.encodeComponent(cleanQuery);
      final response = await _apiService.get('${ApiConstants.recherche}?q=$encoded');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
        remoteResults = jsonList
            .map((j) => SearchResultItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[SearchService] Erreur API recherche: $e');
    }

    if (remoteResults.isNotEmpty) {
      return remoteResults;
    }

    // Fallback dynamique local garanti
    return _localSearch(cleanQuery);
  }

  List<SearchResultItem> _localSearch(String query) {
    final q = query.toLowerCase();
    final List<SearchResultItem> results = [];

    // 1. Plats & Gastronomie
    final isSakaOrSaga = q.contains('saka') || q.contains('saga');
    for (final plat in PlatModel.defaultPlats) {
      final nomLower = plat.nom.toLowerCase();
      final matchesName = nomLower.contains(q);
      final matchesSpecial = isSakaOrSaga && (nomLower.contains('saka') || nomLower.contains('saga'));
      final matchesRegion = plat.regions.any((r) => r.toLowerCase().contains(q));
      final matchesEthnie = plat.ethnies.any((e) => e.toLowerCase().contains(q));

      if (matchesName || matchesSpecial || matchesRegion || matchesEthnie) {
        results.add(SearchResultItem(
          id: 'plat-${plat.id}',
          titre: plat.nom,
          sousTitre: plat.regions.isNotEmpty ? 'Régions : ${plat.regions.join(", ")}' : 'Gastronomie malienne',
          categorie: 'Gastronomie',
          description: plat.description,
          imageUrl: plat.displayPhoto,
          route: AppRouter.dishDetail,
          payload: plat,
        ));
      }
    }

    // 2. Ethnies & Traditions
    for (final ethnie in EthnieModel.defaultEthnies) {
      final nomLower = ethnie.nom.toLowerCase();
      if (nomLower.contains(q) || ethnie.region.toLowerCase().contains(q) || ethnie.langue.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: 'ethnie-${ethnie.id}',
          titre: ethnie.nom,
          sousTitre: 'Peuple & traditions : ${ethnie.region}',
          categorie: 'Ethnies',
          description: ethnie.description,
          imageUrl: ethnie.displayPhoto,
          route: AppRouter.ethnicityDetail,
          payload: ethnie,
        ));
      }
    }

    // 3. Régions
    for (final reg in RegionData.regions) {
      final nomLower = reg.nom.toLowerCase();
      final chefLower = reg.chefLieu.toLowerCase();
      if (nomLower.contains(q) || chefLower.contains(q) || reg.description.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: 'region-${reg.id}',
          titre: reg.nom,
          sousTitre: 'Chef-lieu : ${reg.chefLieu}',
          categorie: 'Régions',
          description: reg.description,
          imageUrl: reg.imageCover,
          route: AppRouter.regionDetail,
          payload: reg,
        ));
      }
    }

    // 4. Religions & Spiritualités
    for (final rel in ReligionModel.defaultReligions) {
      final nomLower = rel.nom.toLowerCase();
      if (nomLower.contains(q) || (rel.categorie?.toLowerCase().contains(q) ?? false) || rel.description.toLowerCase().contains(q)) {
        results.add(SearchResultItem(
          id: 'religion-${rel.id}',
          titre: rel.nom,
          sousTitre: rel.proportionPopulation,
          categorie: 'Religions',
          description: rel.description,
          imageUrl: rel.imageUrl,
          route: AppRouter.religionDetail,
          payload: rel,
        ));
      }
    }

    return results;
  }
}
