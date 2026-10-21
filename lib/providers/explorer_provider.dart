import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/api_service.dart';
import '../models/explorer_publication_model.dart';

/// Filtre actif dans Explorer : 'tous', 'festivals', 'patrimoine'
final explorerFilterTypeProvider = StateProvider<String>((ref) => 'tous');

/// Recherche textuelle dans Explorer
final explorerSearchQueryProvider = StateProvider<String>((ref) => '');

/// Mode démo explicitement désactivé par défaut en production
final explorerDemoModeProvider = StateProvider<bool>((ref) => false);

/// Notifier gérant la liste des publications d'Explorer
class ExplorerPublicationsNotifier
    extends StateNotifier<AsyncValue<List<ExplorerPublicationModel>>> {
  final ApiService _apiService;
  final bool isDemoMode;
  final Set<String> _viewedIds = {};

  ExplorerPublicationsNotifier(
    this._apiService, {
    this.isDemoMode = false,
  }) : super(const AsyncValue.loading()) {
    chargerPublications();
  }

  Future<void> chargerPublications() async {
    state = const AsyncValue.loading();

    // Mode démonstration explicite uniquement (ex: tests ou environnement bac à sable)
    if (isDemoMode) {
      state = AsyncValue.data(
        ExplorerPublicationModel.demoPublications
            .where((p) => p.isValide)
            .toList(),
      );
      return;
    }

    try {
      final res = await _apiService.get('/evenements');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        final List<ExplorerPublicationModel> publications = [];

        for (final item in data) {
          if (item is Map<String, dynamic>) {
            if (item['type'] == null) {
              item['type'] = 'festivalEvenement';
            }
            final pub = ExplorerPublicationModel.fromJson(item);
            // Seuls les contenus approuvés/validés sont affichés au public
            if (pub.isValide && !publications.any((p) => p.id == pub.id)) {
              publications.add(pub);
            }
          }
        }

        // Réponse API réussie : liste réelle (peut être vide [] si aucun événement)
        state = AsyncValue.data(publications);
      } else {
        throw HttpException(
          'Erreur serveur (${res.statusCode}) lors de la récupération des événements',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[ExplorerProvider] Erreur API événements : $e');
      // Aucun fallback vers les données codées en dur en production :
      // On propage l'erreur afin que l'UI affiche l'état d'erreur avec option de réessai
      state = AsyncValue.error(e, stackTrace);
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

    // Notification backend (silencieuse si échec)
    try {
      _apiService.post('/evenements/$id/vue', body: {});
    } catch (_) {}
  }

  /// Publication soumise par un promoteur :
  /// Passe au statut "EN_ATTENTE" -> NE s'affiche PAS dans Explorer tant que non validée !
  void soumettrePublication(ExplorerPublicationModel nouvelle) {
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
  final isDemo = ref.watch(explorerDemoModeProvider);
  return ExplorerPublicationsNotifier(api, isDemoMode: isDemo);
});

/// Publications filtrées par type ('tous', 'festivals') et recherche,
/// tout en propageant l'état AsyncValue (loading, error, data).
final filteredExplorerPublicationsProvider =
    Provider<AsyncValue<List<ExplorerPublicationModel>>>((ref) {
  final asyncPubs = ref.watch(explorerPublicationsProvider);
  final filter = ref.watch(explorerFilterTypeProvider);
  final search = ref.watch(explorerSearchQueryProvider).toLowerCase().trim();

  return asyncPubs.whenData((pubs) {
    return pubs.where((p) {
      // 1. Règle absolue : uniquement les contenus validés
      if (!p.isValide) return false;

      // 2. Filtre par type
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
  });
});
