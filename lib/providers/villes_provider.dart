import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ville_service.dart';
import '../models/ville_model.dart';

final villesProvider = FutureProvider<List<VilleModel>>((ref) async {
  final service = ref.watch(villeServiceProvider);
  return await service.getVilles();
});

final villeSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredVillesProvider = Provider<AsyncValue<List<VilleModel>>>((ref) {
  final query = ref.watch(villeSearchQueryProvider).toLowerCase().trim();
  final villesAsync = ref.watch(villesProvider);
  return villesAsync.whenData((villes) {
    if (query.isEmpty) return villes;
    return villes
        .where((v) =>
            v.nom.toLowerCase().contains(query) ||
            v.region.toLowerCase().contains(query) ||
            v.description.toLowerCase().contains(query))
        .toList();
  });
});
