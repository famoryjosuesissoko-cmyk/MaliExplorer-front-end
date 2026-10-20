import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/favori_service.dart';
import '../models/favori_model.dart';

final favorisNotifierProvider =
    StateNotifierProvider<FavorisNotifier, AsyncValue<List<FavoriModel>>>((ref) {
  final service = ref.watch(favoriServiceProvider);
  return FavorisNotifier(service);
});

// Alias pour la compatibilité avec le code existant
final favorisProvider = Provider<AsyncValue<List<FavoriModel>>>((ref) {
  return ref.watch(favorisNotifierProvider);
});

/// Recommandations personnalisées F23 basées sur les favoris réels de l'utilisateur
final recommandationsProvider = FutureProvider<List<FavoriModel>>((ref) async {
  final service = ref.watch(favoriServiceProvider);
  final apiRecs = await service.getRecommandations();
  if (apiRecs.isNotEmpty) {
    return apiRecs;
  }
  // Repli pertinent basé sur le patrimoine incontournable si aucun favori ou hors-ligne
  return [
    const FavoriModel(
      id: 101,
      titre: 'Grande Mosquée de Djenné',
      categorie: 'Lieu Historique',
      imageUrl: 'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=600&auto=format&fit=crop',
      route: '/city-detail',
    ),
    const FavoriModel(
      id: 102,
      titre: 'Tigadèguèna (Sauce Arachide)',
      categorie: 'Gastronomie',
      imageUrl: 'assets/images/plats/tiguadegue_na.jpeg',
      route: '/dish-detail',
    ),
    const FavoriModel(
      id: 103,
      titre: 'Culture & Peuple Bambara',
      categorie: 'Ethnie & Tradition',
      imageUrl: 'assets/images/ethnies/bambara_homme.jpeg',
      route: '/ethnicity-detail',
    ),
    const FavoriModel(
      id: 104,
      titre: 'Tombeau des Askia',
      categorie: 'Lieu Historique',
      imageUrl: 'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=600&auto=format&fit=crop',
      route: '/city-detail',
    ),
  ];
});


class FavorisNotifier extends StateNotifier<AsyncValue<List<FavoriModel>>> {
  final FavoriService _service;

  FavorisNotifier(this._service) : super(const AsyncValue.loading()) {
    loadFavoris();
  }

  User? _safeCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Détermine le fichier de cache en isolant strictement chaque compte utilisateur
  File? _getCacheFile() {
    final user = _safeCurrentUser();
    if (user == null) {
      return null; // Aucun cache sur disque pour les visiteurs déconnectés
    }
    final safeUid = user.uid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = 'favoris_cache_$safeUid.json';

    try {
      final appDir = Directory('/data/user/0/com.maliexplorer.mali_explorer_frontend/app_flutter');
      if (appDir.existsSync()) {
        return File('${appDir.path}/$filename');
      }
    } catch (_) {}
    return File('${Directory.systemTemp.path}/$filename');
  }

  List<FavoriModel> _loadLocalCache() {
    try {
      final file = _getCacheFile();
      if (file != null && file.existsSync()) {
        final content = file.readAsStringSync();
        if (content.isNotEmpty) {
          final List<dynamic> list = jsonDecode(content);
          return list.map((e) => FavoriModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FavorisNotifier] Erreur lecture cache local: $e');
    }
    return [];
  }

  void _saveLocalCache(List<FavoriModel> favoris) {
    try {
      final file = _getCacheFile();
      if (file == null) return;
      final jsonStr = jsonEncode(favoris.map((f) => f.toJson()).toList());
      file.writeAsStringSync(jsonStr, flush: true);
    } catch (e) {
      debugPrint('[FavorisNotifier] Erreur écriture cache local: $e');
    }
  }

  /// Purge synchrone de la mémoire et des fichiers caches locaux sur déconnexion
  Future<void> purgeLocalCacheAndMemory() async {
    state = const AsyncValue.data([]);
    try {
      final currentFile = _getCacheFile();
      final legacyFiles = [
        ?currentFile,
        File('${Directory.systemTemp.path}/favoris_cache.json'),
        File('/data/user/0/com.maliexplorer.mali_explorer_frontend/app_flutter/favoris_cache.json'),
      ];

      for (final f in legacyFiles) {
        if (f.existsSync()) {
          f.writeAsStringSync('[]', flush: true);
          f.deleteSync();
        }
      }
    } catch (e) {
      debugPrint('[FavorisNotifier] Erreur purge cache: $e');
    }
  }

  /// Alias de compatibilité pour la purge du cache
  void clearLocalCache() {
    purgeLocalCacheAndMemory();
  }

  Future<void> loadFavoris() async {
    final user = _safeCurrentUser();
    // Si l'utilisateur n'est pas connecté, réinitialiser à vide sans charger de cache
    if (user == null) {
      state = const AsyncValue.data([]);
      return;
    }

    final localList = _loadLocalCache();
    if (localList.isNotEmpty) {
      state = AsyncValue.data(localList);
    }

    try {
      final backendList = await _service.getFavoris();
      if (backendList.isNotEmpty) {
        // Fusionner avec le cache local pour ne rien perdre
        final Map<String, FavoriModel> map = {};
        for (final item in localList) {
          map[item.titre] = item;
        }
        for (final item in backendList) {
          final existing = map[item.titre];
          if (existing != null && item.imageUrl.isEmpty && existing.imageUrl.isNotEmpty) {
            map[item.titre] = FavoriModel(
              id: item.id,
              titre: item.titre,
              categorie: item.categorie.isNotEmpty ? item.categorie : existing.categorie,
              imageUrl: existing.imageUrl,
              route: item.route.isNotEmpty ? item.route : existing.route,
              referenceId: item.referenceId ?? existing.referenceId,
            );
          } else {
            map[item.titre] = item;
          }
        }
        final merged = map.values.toList();
        _saveLocalCache(merged);
        state = AsyncValue.data(merged);
      } else {
        // Le serveur confirme 0 favoris pour cet utilisateur -> vider le cache local
        _saveLocalCache([]);
        state = const AsyncValue.data([]);
      }
    } catch (e, st) {
      if (localList.isNotEmpty) {
        state = AsyncValue.data(localList);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  bool isFavorite(String titre) {
    final list = state.value ?? [];
    return list.any((f) => f.titre.trim().toLowerCase() == titre.trim().toLowerCase());
  }

  Future<void> toggleFavori({
    required String titre,
    required String categorie,
    required String imageUrl,
    required String route,
    int? referenceId,
    bool isLieu = false,
    bool isArticle = false,
  }) async {
    final currentList = List<FavoriModel>.from(state.value ?? []);
    final index = currentList.indexWhere(
      (f) => f.titre.trim().toLowerCase() == titre.trim().toLowerCase(),
    );

    if (index >= 0) {
      // Suppression optimiste immédiate
      final removed = currentList.removeAt(index);
      state = AsyncValue.data(List.unmodifiable(currentList));
      _saveLocalCache(currentList);

      try {
        if (isLieu && (referenceId ?? removed.referenceId) != null) {
          await _service.supprimerLieuFavori(referenceId ?? removed.referenceId!);
        } else if (isArticle && (referenceId ?? removed.referenceId) != null) {
          await _service.supprimerArticleFavori(referenceId ?? removed.referenceId!);
        }
      } catch (e) {
        debugPrint('[FavorisNotifier] Erreur suppression backend: $e');
      }
    } else {
      // Ajout optimiste immédiat
      final newItem = FavoriModel(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        titre: titre,
        categorie: categorie,
        imageUrl: imageUrl,
        route: route,
        referenceId: referenceId,
      );
      currentList.insert(0, newItem);
      state = AsyncValue.data(List.unmodifiable(currentList));
      _saveLocalCache(currentList);

      try {
        if (isLieu && referenceId != null) {
          await _service.ajouterLieuFavori(referenceId);
        } else if (isArticle && referenceId != null) {
          await _service.ajouterArticleFavori(referenceId);
        }
      } catch (e) {
        debugPrint('[FavorisNotifier] Erreur ajout backend: $e');
      }
    }
  }

  Future<void> removeFavori(FavoriModel item) async {
    final currentList = List<FavoriModel>.from(state.value ?? []);
    currentList.removeWhere((f) => f.titre == item.titre || f.id == item.id);
    state = AsyncValue.data(List.unmodifiable(currentList));
    _saveLocalCache(currentList);

    try {
      if (item.referenceId != null) {
        await _service.supprimerLieuFavori(item.referenceId!);
      }
    } catch (e) {
      debugPrint('[FavorisNotifier] Erreur suppression backend: $e');
    }
  }

  Future<void> addFavori(FavoriModel item) async {
    if (isFavorite(item.titre)) return;
    await toggleFavori(
      titre: item.titre,
      categorie: item.categorie,
      imageUrl: item.imageUrl,
      route: item.route,
      referenceId: item.referenceId,
    );
  }
}

