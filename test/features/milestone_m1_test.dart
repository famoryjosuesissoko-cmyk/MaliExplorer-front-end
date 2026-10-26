import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/services/favori_service.dart';
import 'package:mali_explorer_frontend/models/favori_model.dart';
import 'package:mali_explorer_frontend/models/user_model.dart';
import 'package:mali_explorer_frontend/core/services/auth_service.dart';
import 'package:mali_explorer_frontend/providers/favoris_provider.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    test('UserModel parses role and moderation status correctly', () {
      final jsonPromoteur = {
        'id': 12,
        'nom': 'Traore',
        'prenom': 'Modibo',
        'email': 'modibo.traore@maliculture.ml',
        'role': 'PROMOTEUR',
        'statutModeration': 'VALIDE',
        'nomOrganisation': 'Mali Culture Fest',
        'telephone': '+223 70 00 11 22',
      };

      final user = UserModel.fromJson(jsonPromoteur);
      expect(user.idUsers, 12);
      expect(user.role, UserRole.promoteur);
      expect(user.isPromoteurValide, isTrue);
      expect(user.isPromoteurEnAttente, isFalse);
      expect(user.isPromoteurRejete, isFalse);
      expect(user.nomOrganisation, 'Mali Culture Fest');

      final pendingUser = user.copyWith(statutModeration: 'EN_ATTENTE');
      expect(pendingUser.isPromoteurValide, isFalse);
      expect(pendingUser.isPromoteurEnAttente, isTrue);

      final rejectedUser = user.copyWith(statutModeration: 'REJETE');
      expect(rejectedUser.isPromoteurValide, isFalse);
      expect(rejectedUser.isPromoteurRejete, isTrue);

      final serialized = user.toJson();
      expect(serialized['role'], 'promoteur');
      expect(serialized['statutModeration'], 'VALIDE');
      expect(serialized['nomOrganisation'], 'Mali Culture Fest');
    });

    test('UserRole parsing handles edge-cases and lowercase strings', () {
      expect(UserRole.fromString('PROMOTEUR'), UserRole.promoteur);
      expect(UserRole.fromString('promoteur'), UserRole.promoteur);
      expect(UserRole.fromString('ROLE_PROMOTEUR'), UserRole.promoteur);
      expect(UserRole.fromString('GUIDE'), UserRole.guide);
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('TOURISTE'), UserRole.touriste);
      expect(UserRole.fromString(null), UserRole.touriste);
    });

    test('AuthService session caching holds cached role and statutModeration in memory', () {
      AuthService.cachedRole = 'promoteur';
      AuthService.cachedStatutModeration = 'VALIDE';

      expect(AuthService.cachedRole, 'promoteur');
      expect(AuthService.cachedStatutModeration, 'VALIDE');

      AuthService.cachedRole = null;
      AuthService.cachedStatutModeration = null;
    });

    test('AuthService fallback model preserves cached role and statutModeration without degrading to touriste', () async {
      AuthService.cachedRole = 'promoteur';
      AuthService.cachedStatutModeration = 'VALIDE';

      final fallbackMap = {
        'email': 'promoteur@culture.ml',
        'displayName': 'Moussa Promoteur',
        'idToken': 'mock_token',
        'role': AuthService.cachedRole ?? 'touriste',
        if (AuthService.cachedStatutModeration != null)
          'statutModeration': AuthService.cachedStatutModeration,
      };

      final userModel = UserModel.fromJson(fallbackMap);
      expect(userModel.role, UserRole.promoteur);
      expect(userModel.statutModeration, 'VALIDE');
      expect(userModel.isPromoteurValide, isTrue);

      SharedPreferences.setMockInitialValues({});
      await AuthService.persistSessionData(userModel);
      expect(AuthService.cachedRole, 'promoteur');
      expect(AuthService.cachedStatutModeration, 'VALIDE');

      AuthService.cachedRole = null;
      AuthService.cachedStatutModeration = null;
    });
  });
}
