import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/info_pratique_service.dart';
import '../models/info_pratique_model.dart';

/// Fournisseur Riverpod pour charger l'intégralité des informations pratiques.
final infosPratiquesProvider = FutureProvider<List<InfoPratiqueModel>>((ref) async {
  final service = ref.watch(infoPratiqueServiceProvider);
  return await service.getInfosPratiques();
});

/// Filtre de catégorie thématique sélectionnée ('TOUS', 'VISAS', 'SANTE', 'DEVISES', 'CLIMAT', 'URGENCES').
final selectedInfoPratiqueCategoryProvider = StateProvider<String>((ref) => 'TOUS');

/// Fournisseur dérivé filtrant dynamiquement les informations pratiques selon la catégorie active.
final filteredInfosPratiquesProvider = Provider<AsyncValue<List<InfoPratiqueModel>>>((ref) {
  final selectedCat = ref.watch(selectedInfoPratiqueCategoryProvider);
  final infosAsync = ref.watch(infosPratiquesProvider);

  return infosAsync.whenData((infos) {
    if (selectedCat == 'TOUS') return infos;
    return infos.where((item) => item.categorie == selectedCat).toList();
  });
});
