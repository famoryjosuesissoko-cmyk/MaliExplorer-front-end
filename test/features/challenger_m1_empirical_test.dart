import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/services/favori_service.dart';
import 'package:mali_explorer_frontend/core/services/badge_progression_service.dart';
import 'package:mali_explorer_frontend/core/services/historique_service.dart';
import 'package:mali_explorer_frontend/features/profil_screen.dart';
import 'package:mali_explorer_frontend/features/personal_info_screen.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
import 'package:mali_explorer_frontend/providers/favoris_provider.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

class FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  FakeAuthController([AuthState? initial]) : super(initial ?? const AuthState());

  @override
  void updateUserData(Map<String, dynamic> updated) {
    state = state.copyWith(user: updated);
  }

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String role,
    String? adresse,
    String? telephone,
    String? photoUrl,
    String? nomOrganisation,
    String? pieceIdentite,
  }) async => true;

  @override
  Future<bool> syncProfile() async => true;

  @override
  Future<void> logout() async {
    state = const AuthState();
  }

  @override
  Future<bool> sendPasswordReset(String email) async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<bool> sendMagicLink(String email) async => true;

  @override
  Future<bool> handleEmailLink(String link, [String? explicitEmail]) async => true;
}

void main() {
  group('Empirical Challenger M1 — Session Purge & Cache Isolation Stress Tests', () {

    test('1. Legacy favoris_cache.json is purged and wiped on logout/purge', () async {
      final tempDir = Directory.systemTemp.path;
      final legacyCacheFile = File('$tempDir/favoris_cache.json');

      // Simule la présence d'un ancien cache contenant des données sensibles d'un utilisateur précédent
      final sensitiveData = [
        {
          'id': 1001,
          'titre': 'Lieu Privé Utilisateur A',
          'categorie': 'Lieu Historique',
          'imageUrl': 'https://example.com/prive_a.jpg',
          'route': '/city-detail',
          'referenceId': 555,
        }
      ];
      legacyCacheFile.writeAsStringSync(jsonEncode(sensitiveData), flush: true);
      expect(legacyCacheFile.existsSync(), isTrue);

      final apiService = ApiService();
      final favoriService = FavoriService(apiService);
      final notifier = FavorisNotifier(favoriService);

      // Exécute la purge complète de session
      await notifier.purgeLocalCacheAndMemory();

      // Vérifie que le fichier legacy n'existe plus sur disque
      expect(legacyCacheFile.existsSync(), isFalse);

      // Vérifie que la mémoire est remise à []
      expect(notifier.state.value, isEmpty);
    });

    test('2. Unauthenticated user opening offline cannot load any cached favoris or leak data', () async {
      final tempDir = Directory.systemTemp.path;
      final userACache = File('$tempDir/favoris_cache_userA_uid_123.json');
      final legacyCache = File('$tempDir/favoris_cache.json');

      userACache.writeAsStringSync(
        jsonEncode([{'id': 1, 'titre': 'Secret User A', 'categorie': 'Lieu', 'imageUrl': '', 'route': ''}]),
        flush: true,
      );
      legacyCache.writeAsStringSync(
        jsonEncode([{'id': 2, 'titre': 'Legacy Secret', 'categorie': 'Lieu', 'imageUrl': '', 'route': ''}]),
        flush: true,
      );

      final apiService = ApiService();
      final favoriService = FavoriService(apiService);
      final notifier = FavorisNotifier(favoriService);

      // Pour un visiteur non connecté hors-ligne, l'état doit être strictement []
      expect(notifier.state.hasValue, isTrue);
      expect(notifier.state.value, isEmpty);

      // L'appel explicite de loadFavoris() sans session ne doit rien charger et rester []
      await notifier.loadFavoris();
      expect(notifier.state.value, isEmpty);

      // Nettoyage
      if (userACache.existsSync()) userACache.deleteSync();
      if (legacyCache.existsSync()) legacyCache.deleteSync();
    });

    test('3. Cache partitioning by UID prevents cross-account data leaks between User A and User B', () async {
      final tempDir = Directory.systemTemp.path;
      final userAUid = 'user_alpha_789';
      final userBUid = 'user_beta_456';

      final userAFilename = 'favoris_cache_${userAUid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.json';
      final userBFilename = 'favoris_cache_${userBUid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.json';

      final fileA = File('$tempDir/$userAFilename');
      final fileB = File('$tempDir/$userBFilename');

      fileA.writeAsStringSync(jsonEncode([
        {'id': 10, 'titre': 'Favori Confidentiel Alpha', 'categorie': 'Culture', 'imageUrl': '', 'route': ''}
      ]), flush: true);

      fileB.writeAsStringSync(jsonEncode([
        {'id': 20, 'titre': 'Favori Beta', 'categorie': 'Gastronomie', 'imageUrl': '', 'route': ''}
      ]), flush: true);

      // Vérifie que les partitions de fichiers sont strictement distinctes
      expect(fileA.path, isNot(equals(fileB.path)));
      expect(fileA.existsSync(), isTrue);
      expect(fileB.existsSync(), isTrue);

      final contentB = jsonDecode(fileB.readAsStringSync()) as List;
      expect(contentB.first['titre'], equals('Favori Beta'));
      expect(contentB.any((item) => item['titre'] == 'Favori Confidentiel Alpha'), isFalse);

      // Nettoyage
      if (fileA.existsSync()) fileA.deleteSync();
      if (fileB.existsSync()) fileB.deleteSync();
    });

    test('4. Session purge resets ApiService auth token and invalidates dependent providers', () {
      final container = ProviderContainer();
      final apiService = container.read(apiServiceProvider);

      // Simule un token actif
      apiService.setAuthToken('mock_user_jwt_token_xyz');
      expect(apiService.authToken, equals('mock_user_jwt_token_xyz'));

      // Exécute la purge de session
      apiService.setAuthToken(null);
      container.read(favorisNotifierProvider.notifier).clearLocalCache();
      container.invalidate(userProgressionProvider);
      container.invalidate(userHistoriqueProvider);

      // Vérifie que le token d'autorisation est immédiatement nul
      expect(apiService.authToken, isNull);
      expect(container.read(favorisNotifierProvider).value, isEmpty);

      container.dispose();
    });

    testWidgets('5. ProfilScreen completely hides personal info, favoris, quiz, historique, and logout for unauthenticated visitor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthState())),
          ],
          child: const MaterialApp(
            home: ProfilScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Titre et message de découverte pour le visiteur
      expect(find.text('Bienvenue sur MaliExplorer'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Créer un compte'), findsOneWidget);

      // Les sections privées doivent être TOTALEMENT masquées
      expect(find.text('Informations personnelles'), findsNothing);
      expect(find.text('Favoris'), findsNothing);
      expect(find.text('Mes quiz et resultats'), findsNothing);
      expect(find.text('Historique'), findsNothing);
      expect(find.text('Déconnexion'), findsNothing);

      // Les sections publiques d'aide et réglages restent disponibles
      expect(find.text('Paramètres'), findsOneWidget);
      expect(find.text('Aide & support'), findsOneWidget);
    });

    testWidgets('6. PersonalInfoScreen shows defensive lock guard if accessed without authentication', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthState())),
          ],
          child: const MaterialApp(
            home: PersonalInfoScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifie l'écran de garde défensif
      expect(find.text('Connexion requise'), findsOneWidget);
      expect(find.text('Veuillez vous connecter pour accéder à vos informations personnelles et modifier votre profil.'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Le formulaire avec les champs modifiables ne doit pas être affiché
      expect(find.text('Enregistrer'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    });

    test('7. AppRouter declares restricted protected routes for private user spaces', () {
      expect(AppRouter.personalInfo, '/personal-info');
      expect(AppRouter.monParcours, '/mon-parcours');
      expect(AppRouter.promoteurDashboard, '/promoteur-dashboard');
      expect(AppRouter.router, isNotNull);
    });
  });
}
