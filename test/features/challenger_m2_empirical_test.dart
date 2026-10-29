import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mali_explorer_frontend/core/services/auth_service.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
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

  group('Challenger M2 — Empirical Adversarial Stress Suite', () {
    tearDown(() {
      AuthService.cachedRole = null;
      AuthService.cachedStatutModeration = null;
    });

    // -------------------------------------------------------------------------
    // 1. RESPONSIVENESS & RENDERFLEX OVERFLOW ON 360x640 & EXTREME VIEWPORTS
    // -------------------------------------------------------------------------
    testWidgets('1. Viewport 360x640: Zero RenderFlex overflow when "Espace Promoteur" is active', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const promoteurValide = UserModel(
        email: 'hamath.prom@mali.ml',
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
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil')),
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

      // Vérification textuelle et absence de crash / overflow
      expect(find.text('Espace Promoteur'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'No RenderFlex overflow or layout exception should occur at 360x640');
    });

    testWidgets('2. Extreme Narrow Viewport 320dp width (320x568, e.g. iPhone SE 1st gen): Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const promoteurValide = UserModel(
        email: 'narrow.screen@mali.ml',
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
      expect(tester.takeException(), isNull, reason: 'Should withstand 320dp width without RenderFlex overflow');
    });

    testWidgets('3. Accessibility Stress: Large text scaling (1.5x) on 360x640 does not cause overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const promoteurValide = UserModel(
        email: 'scale.test@mali.ml',
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
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp.router(routerConfig: testRouter),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Espace Promoteur'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'FittedBox scaleDown should prevent overflow under 1.5x font scale');
    });

    // -------------------------------------------------------------------------
    // 2. LOGOUT & INSTANT REVERSION TO 5 DEFAULT TABS (QUIZ) WITHOUT INDEX ERROR
    // -------------------------------------------------------------------------
    testWidgets('4. Logout while ON /promoteur-dashboard reverts tab bar instantly to Quiz without crash or index error', (tester) async {
      const promoteurValide = UserModel(
        email: 'prom.active@mali.ml',
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
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Screen Home')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Screen Carte')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Screen Explorer')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Screen Quiz')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Screen Dashboard Pro')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Screen Profil')),
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

      // Initial : Promoteur validé sur son dashboard
      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsNothing);
      expect(find.text('Espace Promoteur'), findsOneWidget);

      // Simulation de la déconnexion immédiate
      fakeAuth.updateState(const AuthState());
      await tester.pumpAndSettle();

      // Vérification 1 : Pas de crash, pas d'exception d'index
      expect(tester.takeException(), isNull);

      // Vérification 2 : La barre affiche exactement l'icône Quiz et plus l'icône Promoteur
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget, reason: 'Tab 4 must instantly restore Quiz icon');
      expect(find.byIcon(Icons.business_center_rounded), findsNothing, reason: 'Promoteur icon must be completely removed');

      // Vérification 3 : Exactement 5 onglets dans la barre (ni 4 ni 6, aucune duplication)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.map_rounded), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // Vérification 4 : Clic sur le 4ème onglet restaure la navigation vers Quiz
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Screen Quiz'), findsOneWidget);
      expect(find.text('Quiz'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Rapid successive auth cycle does not duplicate tabs or corrupt state', (tester) async {
      final fakeAuth = _FakeAuthController(const AuthState());

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Screen Home')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Screen Carte')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Screen Explorer')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Screen Quiz')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Screen Pro')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Screen Profil')),
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

      const pValide = UserModel(email: 'v@ml.com', role: UserRole.promoteur, statutModeration: 'VALIDE');
      const pAttente = UserModel(email: 'a@ml.com', role: UserRole.promoteur, statutModeration: 'EN_ATTENTE');
      const pRejete = UserModel(email: 'r@ml.com', role: UserRole.promoteur, statutModeration: 'REJETE');
      const touriste = UserModel(email: 't@ml.com', role: UserRole.touriste);

      // Cycle rapide
      final states = [
        const AuthState(), // 0. Visiteur
        const AuthState(userModel: pValide), // 1. Promoteur validé
        const AuthState(userModel: pAttente), // 2. Promoteur en attente
        const AuthState(userModel: pValide), // 3. Re-validation
        const AuthState(userModel: pRejete), // 4. Rejet
        const AuthState(userModel: touriste), // 5. Touriste
        const AuthState(), // 6. Visiteur
      ];

      for (int i = 0; i < states.length; i++) {
        fakeAuth.updateState(states[i]);
        await tester.pumpAndSettle();

        final bool shouldBePro = states[i].currentUserModel?.isPromoteurValide ?? false;

        if (shouldBePro) {
          expect(find.byIcon(Icons.business_center_rounded), findsOneWidget, reason: 'Step $i should show promoteur icon');
          expect(find.byIcon(Icons.help_outline_rounded), findsNothing, reason: 'Step $i should not show quiz icon');
        } else {
          expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget, reason: 'Step $i should show quiz icon');
          expect(find.byIcon(Icons.business_center_rounded), findsNothing, reason: 'Step $i should not show promoteur icon');
        }

        // Toujours 5 icônes distinctes
        expect(find.byIcon(Icons.home_rounded), findsOneWidget);
        expect(find.byIcon(Icons.map_rounded), findsOneWidget);
        expect(find.byIcon(Icons.travel_explore_rounded), findsOneWidget);
        expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      }
    });

    // -------------------------------------------------------------------------
    // 3. PERSISTENT CACHE RECOVERY IN MAINSHELL
    // -------------------------------------------------------------------------
    testWidgets('6. MainShell honors cached role & statutModeration when userModel in AuthState is null', (tester) async {
      AuthService.cachedRole = 'promoteur';
      AuthService.cachedStatutModeration = 'VALIDE';

      final fakeAuth = _FakeAuthController(const AuthState(userModel: null));

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('Home')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('Carte')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('Explorer')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('Quiz')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('Dashboard')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('Profil')),
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

      expect(find.byIcon(Icons.business_center_rounded), findsOneWidget, reason: 'Cached promoteur VALIDE must be respected');
      expect(find.byIcon(Icons.help_outline_rounded), findsNothing);

      // Now change cache to EN_ATTENTE
      AuthService.cachedStatutModeration = 'EN_ATTENTE';
      fakeAuth.updateState(const AuthState(isLoading: true)); // trigger rebuild with new state
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget, reason: 'Cached EN_ATTENTE must revert to Quiz');
      expect(find.byIcon(Icons.business_center_rounded), findsNothing);
    });

    // -------------------------------------------------------------------------
    // 4. NAVIGATION INTEGRITY & TAPPING ON ALL 5 TABS
    // -------------------------------------------------------------------------
    testWidgets('7. Comprehensive navigation taps across all 5 destinations in both modes', (tester) async {
      final fakeAuth = _FakeAuthController(const AuthState());

      final testRouter = GoRouter(
        initialLocation: AppRouter.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(path: AppRouter.home, builder: (context, state) => const Text('View: Home')),
              GoRoute(path: AppRouter.carte, builder: (context, state) => const Text('View: Carte')),
              GoRoute(path: AppRouter.explorer, builder: (context, state) => const Text('View: Explorer')),
              GoRoute(path: AppRouter.quizList, builder: (context, state) => const Text('View: Quiz')),
              GoRoute(path: AppRouter.promoteurDashboard, builder: (context, state) => const Text('View: Promoteur')),
              GoRoute(path: AppRouter.profil, builder: (context, state) => const Text('View: Profil')),
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

      // Tap Carte
      await tester.tap(find.byIcon(Icons.map_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Carte'), findsOneWidget);

      // Tap Explorer
      await tester.tap(find.byIcon(Icons.travel_explore_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Explorer'), findsOneWidget);

      // Tap Quiz
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Quiz'), findsOneWidget);

      // Tap Profil
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Profil'), findsOneWidget);

      // Switch to Promoteur Valide mode
      const pValide = UserModel(email: 'v@ml.com', role: UserRole.promoteur, statutModeration: 'VALIDE');
      fakeAuth.updateState(const AuthState(userModel: pValide));
      await tester.pumpAndSettle();

      // Tap Espace Promoteur
      await tester.tap(find.byIcon(Icons.business_center_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Promoteur'), findsOneWidget);

      // Tap Home
      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();
      expect(find.text('View: Home'), findsOneWidget);
    });
  });
}
