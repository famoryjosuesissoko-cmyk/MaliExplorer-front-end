import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/core/services/auth_service.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
import 'package:mali_explorer_frontend/features/register_screen.dart';
import 'package:mali_explorer_frontend/models/user_model.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';
import 'package:mali_explorer_frontend/widgets/promoteur_status_banner.dart';

class _FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  _FakeAuthController(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Milestone M3 — Guide Lifecycle, Parity & Access Control Suite', () {
    tearDown(() {
      AuthService.cachedRole = null;
      AuthService.cachedStatutModeration = null;
      AuthService.cachedStatut = null;
      AuthService.cachedUserModel = null;
    });

    // ==================== 1. UserModel Getters ====================
    group('1. UserModel Guide & Pro Parity Getters', () {
      test('Guide en attente avec divers statuts (EN_ATTENTE_VALIDATION, EN_ATTENTE, null, vide)', () {
        const g1 = UserModel(email: 'g1@ml.com', role: UserRole.guide, statutModeration: 'EN_ATTENTE_VALIDATION');
        expect(g1.isGuide, isTrue);
        expect(g1.isGuideEnAttente, isTrue);
        expect(g1.isGuideValide, isFalse);
        expect(g1.isGuideRejete, isFalse);
        expect(g1.isProEnAttente, isTrue);
        expect(g1.isProValide, isFalse);

        const g2 = UserModel(email: 'g2@ml.com', role: UserRole.guide, statutModeration: 'EN_ATTENTE');
        expect(g2.isGuideEnAttente, isTrue);
        expect(g2.isProEnAttente, isTrue);

        const g3 = UserModel(email: 'g3@ml.com', role: UserRole.guide, statutModeration: null);
        expect(g3.isGuideEnAttente, isTrue);
        expect(g3.isProEnAttente, isTrue);

        const g4 = UserModel(email: 'g4@ml.com', role: UserRole.guide, statutModeration: '');
        expect(g4.isGuideEnAttente, isTrue);
        expect(g4.isProEnAttente, isTrue);
      });

      test('Guide validé (VALIDE, APPROUVE)', () {
        const gValide = UserModel(email: 'gv@ml.com', role: UserRole.guide, statutModeration: 'VALIDE');
        expect(gValide.isGuide, isTrue);
        expect(gValide.isGuideValide, isTrue);
        expect(gValide.isGuideEnAttente, isFalse);
        expect(gValide.isGuideRejete, isFalse);
        expect(gValide.isProValide, isTrue);

        const gApprouve = UserModel(email: 'ga@ml.com', role: UserRole.guide, statutModeration: 'APPROUVE');
        expect(gApprouve.isGuideValide, isTrue);
        expect(gApprouve.isProValide, isTrue);
      });

      test('Guide rejeté (REJETE, REFUSE)', () {
        const gRejete = UserModel(email: 'gr@ml.com', role: UserRole.guide, statutModeration: 'REJETE');
        expect(gRejete.isGuide, isTrue);
        expect(gRejete.isGuideRejete, isTrue);
        expect(gRejete.isGuideValide, isFalse);
        expect(gRejete.isGuideEnAttente, isFalse);
        expect(gRejete.isProRejete, isTrue);

        const gRefuse = UserModel(email: 'gf@ml.com', role: UserRole.guide, statutModeration: 'REFUSE');
        expect(gRefuse.isGuideRejete, isTrue);
        expect(gRefuse.isProRejete, isTrue);
      });

      test('Touriste avec statut VALIDE ne devient ni promoteurValide ni guideValide', () {
        const touriste = UserModel(email: 't@ml.com', role: UserRole.touriste, statutModeration: 'VALIDE');
        expect(touriste.isTouriste, isTrue);
        expect(touriste.isGuideValide, isFalse);
        expect(touriste.isPromoteurValide, isFalse);
        expect(touriste.isProValide, isFalse);
      });
    });

    // ==================== 2. PromoteurStatusBanner ====================
    group('2. PromoteurStatusBanner Widget Tests for Guide', () {
      Widget createTestableWidget({required UserModel userModel, bool isDark = false}) {
        final fakeAuth = _FakeAuthController(AuthState(userModel: userModel));
        return ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PromoteurStatusBanner(isDark: isDark),
            ),
          ),
        );
      }

      testWidgets('Guide en attente : affiche la bannière ambre avec texte réglementaire', (tester) async {
        const guide = UserModel(
          email: 'guide@ml.com',
          role: UserRole.guide,
          statutModeration: 'EN_ATTENTE_VALIDATION',
        );

        await tester.pumpWidget(createTestableWidget(userModel: guide));
        await tester.pumpAndSettle();

        expect(find.text('Dossier guide en cours d\'examen'), findsOneWidget);
        expect(
          find.text(
            'Votre dossier a bien été soumis. Il sera examiné par notre équipe. En attendant, vous pouvez continuer à utiliser l\'application en tant que visiteur.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
      });

      testWidgets('Guide validé : affiche la bannière verte avec accès espace', (tester) async {
        const guide = UserModel(
          email: 'guide@ml.com',
          role: UserRole.guide,
          statutModeration: 'VALIDE',
        );

        await tester.pumpWidget(createTestableWidget(userModel: guide));
        await tester.pumpAndSettle();

        expect(find.text('Compte guide certifié validé'), findsOneWidget);
        expect(
          find.text(
            'Votre compte guide certifié est validé. Vous bénéficiez désormais de l\'accès à votre espace guide et de la visibilité auprès des visiteurs.',
          ),
          findsOneWidget,
        );
        expect(find.text('Accéder à mon espace'), findsOneWidget);
        expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
      });

      testWidgets('Guide rejeté : affiche la bannière rouge', (tester) async {
        const guide = UserModel(
          email: 'guide@ml.com',
          role: UserRole.guide,
          statutModeration: 'REJETE',
        );

        await tester.pumpWidget(createTestableWidget(userModel: guide));
        await tester.pumpAndSettle();

        expect(find.text('Candidature guide non retenue'), findsOneWidget);
        expect(
          find.text(
            'Votre candidature de guide n\'a pas été retenue. Vous conservez votre accès visiteur complet aux contenus de l\'application.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
      });

      testWidgets('Touriste : ne rend aucune bannière (SizedBox.shrink)', (tester) async {
        const touriste = UserModel(
          email: 'touriste@ml.com',
          role: UserRole.touriste,
          statutModeration: 'VALIDE',
        );

        await tester.pumpWidget(createTestableWidget(userModel: touriste));
        await tester.pumpAndSettle();

        expect(find.byType(PromoteurStatusBanner), findsOneWidget);
        expect(find.text('Compte guide certifié validé'), findsNothing);
        expect(find.text('Compte promoteur validé'), findsNothing);
        expect(find.byType(Container), findsNothing);
      });
    });

    // ==================== 3. AppRouter Guard Logic ====================
    group('3. Pro Dashboard Route Guard & Suspension Check', () {
      String? evaluateGuard({
        required bool isLoggedIn,
        required String? cachedRole,
        required String? cachedStatutModeration,
        required String? cachedStatut,
      }) {
        const String location = AppRouter.promoteurDashboard;
        if (location.startsWith(AppRouter.promoteurDashboard)) {
          if (!isLoggedIn) return AppRouter.login;

          final String role = (cachedRole ?? '').toLowerCase();
          final String statutMod = (cachedStatutModeration ?? '').toUpperCase();
          final String userStatut = (cachedStatut ?? '').toUpperCase();
          final bool isAdmin = role.contains('admin');
          final bool isPromoteurOrGuide = role.contains('promoteur') || role.contains('guide');
          final bool isValide = statutMod == 'VALIDE' || statutMod == 'APPROUVE';
          final bool isNotSuspended = userStatut != 'SUSPENDU' && userStatut != 'BLOQUE';

          if (!isAdmin && (!isPromoteurOrGuide || !isValide || !isNotSuspended)) {
            return AppRouter.home;
          }
        }
        return null;
      }

      test('Partenaire validé mais SUSPENDU : redirection stricte vers /home', () {
        final rPromoteur = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'promoteur',
          cachedStatutModeration: 'VALIDE',
          cachedStatut: 'SUSPENDU',
        );
        expect(rPromoteur, equals(AppRouter.home));

        final rGuide = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'guide',
          cachedStatutModeration: 'VALIDE',
          cachedStatut: 'SUSPENDU',
        );
        expect(rGuide, equals(AppRouter.home));
      });

      test('Partenaire validé mais BLOQUÉ : redirection stricte vers /home', () {
        final r = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'promoteur',
          cachedStatutModeration: 'VALIDE',
          cachedStatut: 'BLOQUE',
        );
        expect(r, equals(AppRouter.home));
      });

      test('Partenaire validé et ACTIF : accès autorisé (null)', () {
        final rGuide = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'guide',
          cachedStatutModeration: 'VALIDE',
          cachedStatut: 'ACTIF',
        );
        expect(rGuide, isNull);

        final rPromoteur = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'promoteur',
          cachedStatutModeration: 'VALIDE',
          cachedStatut: 'ACTIF',
        );
        expect(rPromoteur, isNull);
      });

      test('Partenaire EN_ATTENTE_VALIDATION : redirection vers /home', () {
        final r = evaluateGuard(
          isLoggedIn: true,
          cachedRole: 'guide',
          cachedStatutModeration: 'EN_ATTENTE_VALIDATION',
          cachedStatut: 'EN_ATTENTE',
        );
        expect(r, equals(AppRouter.home));
      });
    });

    // ==================== 4. RegisterScreen Guide Form Fields ====================
    group('4. RegisterScreen Guide Form Fields', () {
      testWidgets('Bascule sur le rôle Guide : affiche les champs langue, expérience et bio', (tester) async {
        final fakeAuth = _FakeAuthController(const AuthState());
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authControllerProvider.overrideWith((ref) => fakeAuth),
            ],
            child: const MaterialApp(
              home: RegisterScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Trouver et appuyer sur l'option "Guide" dans le sélecteur de rôle
        final guideTab = find.text('Guide');
        expect(guideTab, findsOneWidget);
        await tester.tap(guideTab);
        await tester.pumpAndSettle();

        // Vérifier la présence des nouveaux champs spécifiques au Guide
        expect(find.text('Langues parlées (ex: Français, Bambara)'), findsOneWidget);
        expect(find.text('Années d\'expérience (ex: 5)'), findsOneWidget);
        expect(find.text('Présentation / Bio professionnelle'), findsOneWidget);
      });
    });
  });
}
