import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/home_slide_service.dart';
import '../core/services/religion_service.dart';
import '../core/services/search_service.dart';
import '../core/services/ville_service.dart';
import '../models/home_slide_model.dart';
import '../models/religion_model.dart';
import '../models/search_result_item.dart';
import '../models/ville_model.dart';

/// Provider pour les diapositives du Hero du Home
final homeSlidesProvider = FutureProvider<List<HomeSlideModel>>((ref) async {
  final service = ref.watch(homeSlideServiceProvider);
  return await service.getActiveSlides();
});

/// Provider pour les villes vedettes du carrousel continu du Home
final homeVillesProvider = FutureProvider<List<VilleModel>>((ref) async {
  final service = ref.watch(villeServiceProvider);
  return await service.getHomeVilles();
});

/// Provider pour la liste des religions au Mali
final religionsProvider = FutureProvider<List<ReligionModel>>((ref) async {
  final service = ref.watch(religionServiceProvider);
  return await service.getReligions();
});

/// Provider de recherche globale dynamique avec debounce
final homeSearchQueryProvider = StateProvider<String>((ref) => '');

final globalSearchResultsProvider = FutureProvider<List<SearchResultItem>>((ref) async {
  final query = ref.watch(homeSearchQueryProvider).trim();
  if (query.length < 2) return [];
  final searchService = ref.watch(searchServiceProvider);
  return await searchService.search(query);
});

