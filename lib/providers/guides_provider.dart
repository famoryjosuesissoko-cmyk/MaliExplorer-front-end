import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/guide_service.dart';
import '../models/guide_model.dart';

final guidesProvider = FutureProvider<List<GuideModel>>((ref) async {
  final service = ref.watch(guideServiceProvider);
  return await service.getGuides();
});

final guideSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredGuidesProvider = Provider<AsyncValue<List<GuideModel>>>((ref) {
  final query = ref.watch(guideSearchQueryProvider).toLowerCase().trim();
  final guidesAsync = ref.watch(guidesProvider);
  return guidesAsync.whenData((guides) {
    if (query.isEmpty) return guides;
    return guides
        .where((g) =>
            g.fullName.toLowerCase().contains(query) ||
            g.description.toLowerCase().contains(query) ||
            g.langue.toLowerCase().contains(query) ||
            g.adresse.toLowerCase().contains(query))
        .toList();
  });
});
