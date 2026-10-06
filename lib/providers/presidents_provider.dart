import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/president_service.dart';
import '../models/president_model.dart';

final presidentsProvider = FutureProvider<List<PresidentModel>>((ref) async {
  final service = ref.watch(presidentServiceProvider);
  return await service.getPresidents();
});

final presidentSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredPresidentsProvider = Provider<AsyncValue<List<PresidentModel>>>((ref) {
  final query = ref.watch(presidentSearchQueryProvider).toLowerCase().trim();
  final presidentsAsync = ref.watch(presidentsProvider);
  return presidentsAsync.whenData((presidents) {
    if (query.isEmpty) return presidents;
    return presidents
        .where((p) =>
            p.fullName.toLowerCase().contains(query) ||
            p.periodeMandat.toLowerCase().contains(query) ||
            p.biographie.toLowerCase().contains(query))
        .toList();
  });
});
