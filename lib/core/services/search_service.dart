import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ethnie_model.dart';
import '../../models/plat_model.dart';
import '../../models/region_model.dart';
import '../../models/religion_model.dart';
import '../../models/president_model.dart';
import '../../models/ville_model.dart';
import '../../models/search_result_item.dart';
import '../../providers/ethnies_provider.dart';
import '../../providers/presidents_provider.dart';
import '../../router/app_router.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(apiServiceProvider), ref);
});

class SearchService {
  final ApiService _apiService;
  final Ref? _ref;

  SearchService(this._apiService, [this._ref]);

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

    // Solution de repli dynamique locale garantie
    return _localSearch(cleanQuery);
  }

  /// Normalisation diacritique insensible aux accents et à la casse
  static String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<SearchResultItem> _localSearch(String query) {
    final q = normalizeText(query);
    final List<SearchResultItem> results = [];

    // 1. Plats & Gastronomie
    final isSakaOrSaga = q.contains('saka') || q.contains('saga');
    for (final plat in PlatModel.defaultPlats) {
      final nomNorm = normalizeText(plat.nom);
      final descNorm = normalizeText(plat.description);
      final matchesName = nomNorm.contains(q) || descNorm.contains(q);
      final matchesSpecial = isSakaOrSaga && (nomNorm.contains('saka') || nomNorm.contains('saga'));
      final matchesRegion = plat.regions.any((r) => normalizeText(r).contains(q));
      final matchesEthnie = plat.ethnies.any((e) => normalizeText(e).contains(q));

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

    // 2. Chefs d'État & Présidents
    final dynamicPres = _ref?.read(presidentsProvider).valueOrNull;
    final List<PresidentModel> presidentsList = (dynamicPres != null && dynamicPres.isNotEmpty)
        ? dynamicPres
        : PresidentModel.chronologicalPresidents;

    for (final pres in presidentsList) {
      final nomNorm = normalizeText(pres.nom);
      final prenomNorm = normalizeText(pres.prenom);
      final fullNorm = normalizeText(pres.fullName);
      final bioNorm = normalizeText(pres.biographie);
      final mandatNorm = normalizeText(pres.periodeMandat);

      if (nomNorm.contains(q) ||
          prenomNorm.contains(q) ||
          fullNorm.contains(q) ||
          bioNorm.contains(q) ||
          mandatNorm.contains(q)) {
        results.add(SearchResultItem(
          id: 'president-${pres.id}',
          titre: pres.fullName,
          sousTitre: pres.periodeMandat,
          categorie: 'Chefs d\'État',
          description: pres.biographie,
          imageUrl: pres.displayPhoto,
          route: AppRouter.presidentDetail,
          payload: pres,
        ));
      }
    }

    // 3. Villes & Lieux Historiques
    for (final ville in VilleModel.defaultVilles) {
      final nomNorm = normalizeText(ville.nom);
      final regNorm = normalizeText(ville.region);
      final descNorm = normalizeText(ville.description);

      if (nomNorm.contains(q) || regNorm.contains(q) || descNorm.contains(q)) {
        results.add(SearchResultItem(
          id: 'ville-${ville.id}',
          titre: ville.nom,
          sousTitre: ville.region.isNotEmpty ? 'Région : ${ville.region}' : 'Ville du Mali',
          categorie: 'Villes & Patrimoine',
          description: ville.description,
          imageUrl: ville.displayPhoto,
          route: AppRouter.cityDetail,
          payload: ville,
        ));
      }
    }

    // 4. Ethnies & Traditions
    final dynamicEthnies = _ref?.read(ethniesProvider).valueOrNull;
    final List<EthnieModel> ethniesList = (dynamicEthnies != null && dynamicEthnies.isNotEmpty)
        ? dynamicEthnies
        : EthnieModel.defaultEthnies;

    for (final ethnie in ethniesList) {
      final nomNorm = normalizeText(ethnie.nom);
      final regNorm = normalizeText(ethnie.region);
      final langueNorm = normalizeText(ethnie.langue);
      final descNorm = normalizeText(ethnie.description);

      if (nomNorm.contains(q) || regNorm.contains(q) || langueNorm.contains(q) || descNorm.contains(q)) {
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

    // 5. Régions
    for (final reg in RegionData.regions) {
      final nomNorm = normalizeText(reg.nom);
      final chefNorm = normalizeText(reg.chefLieu);
      final descNorm = normalizeText(reg.description);

      if (nomNorm.contains(q) || chefNorm.contains(q) || descNorm.contains(q)) {
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

    // 6. Religions & Spiritualités
    for (final rel in ReligionModel.defaultReligions) {
      final nomNorm = normalizeText(rel.nom);
      final catNorm = rel.categorie != null ? normalizeText(rel.categorie!) : '';
      final descNorm = normalizeText(rel.description);

      if (nomNorm.contains(q) || catNorm.contains(q) || descNorm.contains(q)) {
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
