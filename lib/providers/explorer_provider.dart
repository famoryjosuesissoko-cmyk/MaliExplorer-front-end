import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../models/explorer_publication_model.dart';

/// Filtre actif dans Explorer : 'tous', 'produits', 'festivals', 'patrimoine'
final explorerFilterTypeProvider = StateProvider<String>((ref) => 'tous');

/// Recherche textuelle dans Explorer
final explorerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Notifier gérant la liste des publications d'Explorer
class ExplorerPublicationsNotifier
    extends StateNotifier<AsyncValue<List<ExplorerPublicationModel>>> {
  final ApiService _apiService;
  final Set<String> _viewedIds = {};

  ExplorerPublicationsNotifier(this._apiService)
      : super(const AsyncValue.loading()) {
    chargerPublications();
  }

  Future<void> chargerPublications() async {
    try {
      final List<ExplorerPublicationModel> publications =
          List.from(ExplorerPublicationModel.initialPublications);

      // 1. Tenter de charger les événements validés depuis l'API backend
      try {
        final res = await _apiService.get('/evenements');
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          for (final item in data) {
            final pub = ExplorerPublicationModel.fromJson(item);
            if (pub.isValide && !publications.any((p) => p.id == pub.id)) {
              publications.add(pub);
            }
          }
        }
      } catch (e) {
        debugPrint('[ExplorerProvider] Fallback local événements: $e');
      }

      // 2. Tenter de charger les opportunités d'artisans validées
      try {
        final res = await _apiService.get('/opportunites?type=ARTISAN');
        if (res.statusCode == 200) {
          final List<dynamic> data = jsonDecode(res.body);
          for (final item in data) {
            final pub = ExplorerPublicationModel.fromJson(item);
            if (pub.isValide && !publications.any((p) => p.id == pub.id)) {
              publications.add(pub);
            }
          }
        }
      } catch (e) {
        debugPrint('[ExplorerProvider] Fallback local opportunités: $e');
      }

      // Règle absolue du cahier des charges : seuls les contenus VALIDÉS apparaissent
      final valides = publications.where((p) => p.isValide).toList();
      state = AsyncValue.data(valides);
    } catch (e) {
      // En cas d'erreur réseau, afficher la sélection initiale validée
      state = AsyncValue.data(
        ExplorerPublicationModel.initialPublications
            .where((p) => p.isValide)
            .toList(),
      );
    }
  }

  /// Incrémente le compteur de vues de façon idempotente (une seule fois par session)
  void incrementerView(String id) {
    if (_viewedIds.contains(id)) return;
    _viewedIds.add(id);

    state.whenData((pubs) {
      final updated = pubs.map((p) {
        if (p.id == id) {
          return p.copyWith(vues: p.vues + 1);
        }
        return p;
      }).toList();
      state = AsyncValue.data(updated);
    });

    // Optionnel : Notification backend
    try {
      _apiService.post('/evenements/$id/vue', body: {});
    } catch (_) {}
  }

  /// Publication soumise par un artisan ou un promoteur :
  /// Passe au statut "EN_ATTENTE" -> NE s'affiche PAS dans Explorer tant que non validée !
  void soumettrePublication(ExplorerPublicationModel nouvelle) {
    // Si la publication est en attente, elle n'est pas ajoutée à la vue publique
    if (!nouvelle.isValide) {
      debugPrint(
        '[ExplorerProvider] Publication ${nouvelle.titre} soumise avec statut ${nouvelle.statut} : non affichée publiquement avant modération.',
      );
      return;
    }

    state.whenData((pubs) {
      state = AsyncValue.data([nouvelle, ...pubs]);
    });
  }

  /// Validation par l'Admin : fait apparaître instantanément le contenu dans Explorer
  void approuverPublication(String id) {
    state.whenData((pubs) {
      final updated = pubs.map((p) {
        if (p.id == id) {
          return p.copyWith(statut: 'VALIDE');
        }
        return p;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }
}

final explorerPublicationsProvider = StateNotifierProvider<
    ExplorerPublicationsNotifier,
    AsyncValue<List<ExplorerPublicationModel>>>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ExplorerPublicationsNotifier(api);
});

/// Publications filtrées par type ('tous', 'produits', 'festivals') et recherche
final filteredExplorerPublicationsProvider =
    Provider<List<ExplorerPublicationModel>>((ref) {
  final asyncPubs = ref.watch(explorerPublicationsProvider);
  final filter = ref.watch(explorerFilterTypeProvider);
  final search = ref.watch(explorerSearchQueryProvider).toLowerCase();

  return asyncPubs.maybeWhen(
    data: (pubs) {
      return pubs.where((p) {
        // 1. Règle absolue : uniquement les contenus validés
        if (!p.isValide) return false;

        // 2. Filtre par type
        if (filter == 'produits' &&
            p.type != PublicationType.produitArtisan) {
          return false;
        }
        if (filter == 'festivals' &&
            p.type != PublicationType.festivalEvenement) {
          return false;
        }

        // 3. Filtre par recherche textuelle
        if (search.isNotEmpty) {
          final inTitre = p.titre.toLowerCase().contains(search);
          final inDesc = p.description.toLowerCase().contains(search);
          final inAuteur = p.auteur.toLowerCase().contains(search);
          final inLoc = p.localisation.toLowerCase().contains(search);
          final inCat = p.categorie.toLowerCase().contains(search);
          return inTitre || inDesc || inAuteur || inLoc || inCat;
        }

        return true;
      }).toList();
    },
    orElse: () => [],
  );
});
