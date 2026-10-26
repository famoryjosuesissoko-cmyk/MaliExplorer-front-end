import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mali_explorer_frontend/core/services/auth_service.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
import 'package:mali_explorer_frontend/features/profil_screen.dart';
import 'package:mali_explorer_frontend/models/user_model.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';
import 'package:mali_explorer_frontend/widgets/main_shell.dart';

class _FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  _FakeAuthController(super.initialState);

  void updateState(AuthState newState) {
    state = newState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone M2 — Dynamic Navigation Tab Bar & ShellRoute Alignment', () {
    tearDown(() {
      AuthService.cachedRole = null;
      AuthService.cachedStatutModeration = null;
    });

    test('1. AppRouter ShellRoute configuration contains both /quiz and /promoteur-dashboard without duplicates', () {
      final routes = AppRouter.router.configuration.routes;
      final shellRoutes = routes.whereType<ShellRoute>().toList();
      expect(shellRoutes, isNotEmpty, reason: 'MainShell persistent ShellRoute should exist');

      final shellRoute = shellRoutes.first;
      final childPaths = shellRoute.routes.whereType<GoRoute>().map((r) => r.path).toList();

      expect(childPaths, contains(AppRouter.home));
      expect(childPaths, contains(AppRouter.carte));
      expect(childPaths, contains(AppRouter.explorer));
      expect(childPaths, contains(AppRouter.quizList));
      expect(childPaths, contains(AppRouter.promoteurDashboard));
      expect(childPaths, contains(AppRouter.profil));

      // Vérification de l'absence de duplication
      final allGoRoutes = <GoRoute>[];
      void collectGoRoutes(List<RouteBase> list) {
        for (final r in list) {
          if (r is GoRoute) allGoRoutes.add(r);
          if (r.routes.isNotEmpty) collectGoRoutes(r.routes);
        }
      }
      collectGoRoutes(routes);

      final promoteurRoutes = allGoRoutes.where((r) => r.path == AppRouter.promoteurDashboard).toList();
      expect(promoteurRoutes.length, 1, reason: 'Il ne doit y avoir aucune duplication de /promoteur-dashboard');

      final quizRoutes = allGoRoutes.where((r) => r.path == AppRouter.quizList).toList();
      expect(quizRoutes.length, 1, reason: 'Il ne doit y avoir aucune duplication de /quiz');
    });

    testWidgets('2. Visiteur non connecté : Barre à 5 onglets avec Quiz au 4ème onglet', (tester) async {
      final fakeAuth = _FakeAuthController(const AuthState());

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.map_rounded), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget, reason: 'Quiz icon should be present for visitor');
      expect(find.byIcon(Icons.business_center_rounded), findsNothing, reason: 'Promoteur icon should not be present');
      expect(find.text('Quiz'), findsNothing); // label visible only when selected
      expect(find.text('Accueil'), findsOneWidget); // activeIndex 0 label visible

      // Taper sur le 4ème onglet (Quiz)
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Quiz Page'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget); // now active
    });

    testWidgets('3. Touriste connecté : Maintien strict de l\'onglet Quiz', (tester) async {
      const touriste = UserModel(
        email: 'touriste@mali.ml',
        nom: 'Coulibaly',
        prenom: 'Mamadou',
        role: UserRole.touriste,
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: touriste));

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);
    });

    testWidgets('4. Promoteur non validé (EN_ATTENTE ou REJETE) : Maintien strict de l\'onglet Quiz', (tester) async {
      const promoteurEnAttente = UserModel(
        email: 'promoteur.attente@mali.ml',
        role: UserRole.promoteur,
        statutModeration: 'EN_ATTENTE',
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: promoteurEnAttente));

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Vérification EN_ATTENTE
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);

      // Transition vers REJETE
      const promoteurRejete = UserModel(
        email: 'promoteur.rejete@mali.ml',
        role: UserRole.promoteur,
        statutModeration: 'REJETE',
      );
      fakeAuth.updateState(const AuthState(userModel: promoteurRejete));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);
    });

    testWidgets('5. Promoteur VALIDÉ : Le 4ème onglet devient dynamiquement Espace Promoteur', (tester) async {
      const promoteurValide = UserModel(
        email: 'promoteur.valide@mali.ml',
        role: UserRole.promoteur,
        statutModeration: 'VALIDE',
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: promoteurValide));

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget, reason: 'Promoteur tab icon must be displayed for validated promoteur');
      expect(find.byIcon(Icons.help_outline_rounded), findsNothing, reason: 'Quiz tab icon must be substituted');

      // Taper sur l'onglet Espace Promoteur
      await tester.tap(find.byIcon(Icons.business_center_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsOneWidget);
      expect(find.text('Espace Promoteur'), findsOneWidget);
    });

    testWidgets('6. Promoteur APPROUVÉ : Le 4ème onglet est également Espace Promoteur', (tester) async {
      const promoteurApprouve = UserModel(
        email: 'promoteur.approuve@mali.ml',
        role: UserRole.promoteur,
        statutModeration: 'APPROUVE',
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: promoteurApprouve));

      final testRouter = GoRouter(
        initialLocation: AppRouter.promoteurDashboard,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget);
      expect(find.text('Espace Promoteur'), findsOneWidget);
      expect(find.text('Dashboard Page'), findsOneWidget);
    });

    testWidgets('7. Réactivité en temps réel : permutation dynamique sans redémarrage ni crash', (tester) async {
      final fakeAuth = _FakeAuthController(const AuthState());

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home Page')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte Page')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer Page')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz Page')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard Page')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil Page')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial : Visiteur -> Quiz
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);

      // 2. Connexion promoteur validé -> Espace Promoteur
      const pValide = UserModel(
        email: 'valide@ml.com',
        role: UserRole.promoteur,
        statutModeration: 'VALIDE',
      );
      fakeAuth.updateState(const AuthState(userModel: pValide));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsNothing);

      // 3. Déconnexion -> Quiz restauré
      fakeAuth.updateState(const AuthState());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);
    });

    testWidgets('8. ProfilScreen propose une tuile dédiée pour les Quiz avec Icons.quiz_rounded', (tester) async {
      const promoteurValide = UserModel(
        email: 'prom@mali.ml',
        nom: 'Diallo',
        prenom: 'Hamath',
        role: UserRole.promoteur,
        statutModeration: 'VALIDE',
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: promoteurValide));

      bool navigatedToQuiz = false;
      final testRouter = GoRouter(
        initialLocation: AppRouter.profil,
        routes: [
          GoRoute(path: AppRouter.profil, builder: (context, state) => const ProfilScreen()),
          GoRoute(
            path: AppRouter.quizList,
            builder: (context, state) {
              navigatedToQuiz = true;
              return const Scaffold(body: Text('Écran Liste Quiz'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Quiz et Défis Culturels'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tuile Quiz présente dans ProfilScreen
      expect(find.text('Quiz et Défis Culturels'), findsOneWidget);
      expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);

      // Clic sur la tuile Quiz
      await tester.tap(find.text('Quiz et Défis Culturels'));
      await tester.pumpAndSettle();

      expect(navigatedToQuiz, isTrue);
      expect(find.text('Écran Liste Quiz'), findsOneWidget);
    });

    testWidgets('9. ProfilScreen propose également la tuile Quiz pour les visiteurs', (tester) async {
      final fakeAuth = _FakeAuthController(const AuthState());

      final testRouter = GoRouter(
        initialLocation: AppRouter.profil,
        routes: [
          GoRoute(path: AppRouter.profil, builder: (context, state) => const ProfilScreen()),
          GoRoute(path: AppRouter.quizList, builder: (context, state) => const Scaffold(body: Text('Écran Liste Quiz'))),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Stream.value(null)),
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Quiz et Défis Culturels'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Quiz et Défis Culturels'), findsOneWidget);
      expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);
    });

    testWidgets('10. MainShell ne provoque aucun RenderFlex overflow sur petits écrans (360x640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const promoteurValide = UserModel(
        email: 'prom@mali.ml',
        role: UserRole.promoteur,
        statutModeration: 'VALIDE',
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: promoteurValide));

      final testRouter = GoRouter(
        initialLocation: AppRouter.promoteurDashboard,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard')),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Espace Promoteur'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
