import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/langue_service.dart';
import '../models/langue_model.dart';

/// Fournisseur Riverpod pour charger la liste dynamique des langues nationales.
final languesProvider = FutureProvider<List<LangueModel>>((ref) async {
  final service = ref.watch(langueServiceProvider);
  return await service.getLangues();
});

/// Index de la langue actuellement sélectionnée par l'utilisateur.
final selectedLangueIndexProvider = StateProvider<int>((ref) => 0);

/// Chaîne de recherche pour filtrer le lexique de la langue active.
final langueSearchQueryProvider = StateProvider<String>((ref) => '');

/// Catégorie sémantique courante de lexique sélectionnée ('Tous', 'Salutations', etc.).
final selectedLexiqueCategoryProvider = StateProvider<String>((ref) => 'Tous');
