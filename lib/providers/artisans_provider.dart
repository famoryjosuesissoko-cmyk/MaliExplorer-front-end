import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/artisan_service.dart';
import '../models/artisan_model.dart';

final artisansProvider = FutureProvider<List<ArtisanModel>>((ref) async {
  final service = ref.watch(artisanServiceProvider);
  return await service.getArtisans();
});

final artisanSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredArtisansProvider = Provider<AsyncValue<List<ArtisanModel>>>((ref) {
  final query = ref.watch(artisanSearchQueryProvider).toLowerCase().trim();
  final artisansAsync = ref.watch(artisansProvider);
  return artisansAsync.whenData((artisans) {
    if (query.isEmpty) return artisans;
    return artisans
        .where((a) =>
            a.fullName.toLowerCase().contains(query) ||
            a.typeArtisanat.toLowerCase().contains(query) ||
            a.adresse.toLowerCase().contains(query))
        .toList();
  });
});
