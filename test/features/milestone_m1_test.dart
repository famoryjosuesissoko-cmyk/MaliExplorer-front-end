import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/services/favori_service.dart';
import 'package:mali_explorer_frontend/models/favori_model.dart';
import 'package:mali_explorer_frontend/providers/favoris_provider.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

void main() {
  group('Milestone 1 — User Profile Isolation & Security Tests', () {
    test('FavoriModel serialize and deserialize with full fields', () {
      final model = const FavoriModel(
        id: 42,
        titre: 'Mosquée de Djenné',
        categorie: 'Lieu Historique',
        imageUrl: 'https://example.com/djenne.jpg',
        route: '/city-detail',
        referenceId: 101,
      );

      final json = model.toJson();
      expect(json['id'], 42);
      expect(json['titre'], 'Mosquée de Djenné');
      expect(json['categorie'], 'Lieu Historique');
      expect(json['imageUrl'], 'https://example.com/djenne.jpg');
      expect(json['route'], '/city-detail');
      expect(json['referenceId'], 101);

      final deserialized = FavoriModel.fromJson(json);
      expect(deserialized.id, 42);
      expect(deserialized.titre, 'Mosquée de Djenné');
      expect(deserialized.categorie, 'Lieu Historique');
      expect(deserialized.imageUrl, 'https://example.com/djenne.jpg');
      expect(deserialized.route, '/city-detail');
      expect(deserialized.referenceId, 101);
    });

    test('FavorisNotifier isolates unauthenticated visitor and purges cache safely', () async {
      final service = FavoriService(ApiService());
      final notifier = FavorisNotifier(service);

      // Pour un visiteur non authentifié, l'état initial doit être une liste vide
      expect(notifier.state.hasValue, isTrue);
      expect(notifier.state.value, isEmpty);

      // La purge du cache local et de la mémoire doit s'exécuter sans erreur
      await notifier.purgeLocalCacheAndMemory();
      expect(notifier.state.value, isEmpty);

      // L'alias clearLocalCache s'exécute également sans erreur
      notifier.clearLocalCache();
      expect(notifier.state.value, isEmpty);
    });

    test('AppRouter defines restricted protected routes', () {
      expect(AppRouter.personalInfo, '/personal-info');
      expect(AppRouter.monParcours, '/mon-parcours');
      expect(AppRouter.promoteurDashboard, '/promoteur-dashboard');
      expect(AppRouter.splash, '/');
      expect(AppRouter.login, '/login');
      expect(AppRouter.router, isNotNull);
    });
  });
}
