import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/ethnie_service.dart';
import '../models/ethnie_model.dart';

final ethniesProvider = FutureProvider<List<EthnieModel>>((ref) async {
  final service = ref.watch(ethnieServiceProvider);
  return await service.getEthnies();
});

final ethnieSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredEthniesProvider = Provider<AsyncValue<List<EthnieModel>>>((ref) {
  final query = ref.watch(ethnieSearchQueryProvider).toLowerCase().trim();
  final ethniesAsync = ref.watch(ethniesProvider);
  return ethniesAsync.whenData((ethnies) {
    if (query.isEmpty) return ethnies;
    return ethnies
        .where((e) =>
            e.nom.toLowerCase().contains(query) ||
            e.description.toLowerCase().contains(query) ||
            e.region.toLowerCase().contains(query))
        .toList();
  });
});
