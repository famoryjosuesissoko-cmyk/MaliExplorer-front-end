import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/plat_service.dart';
import '../models/plat_model.dart';

final platsProvider = FutureProvider<List<PlatModel>>((ref) async {
  final service = ref.watch(platServiceProvider);
  return await service.getPlats();
});

final platSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPlatsProvider = Provider<AsyncValue<List<PlatModel>>>((ref) {
  final query = ref.watch(platSearchQueryProvider).toLowerCase().trim();
  final platsAsync = ref.watch(platsProvider);
  return platsAsync.whenData((plats) {
    if (query.isEmpty) return plats;
    return plats
        .where((p) =>
            p.nom.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query))
        .toList();
  });
});
