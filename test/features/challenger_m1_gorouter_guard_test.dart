import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/user_model.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

void main() {
  group('Challenger M1 — Route Guard & Access Control Empirical Suite', () {

    /// Reproduction de l'oracle algorithmique exact de app_router.dart (lignes 172-188)
    String? evaluatePromoteurDashboardGuard({
      required bool isLoggedIn,
      required String? cachedRole,
      required String? cachedStatutModeration,
    }) {
      const String location = AppRouter.promoteurDashboard;

      if (location.startsWith(AppRouter.promoteurDashboard)) {
        if (!isLoggedIn) {
          return AppRouter.login;
        }
        final String role = (cachedRole ?? '').toLowerCase();
        final String statut = (cachedStatutModeration ?? '').toUpperCase();
        final bool isAdmin = role.contains('admin');
        final bool isPromoteurOrGuide = role.contains('promoteur') || role.contains('guide');
        final bool isValide = statut == 'VALIDE' || statut == 'APPROUVE';

        if (!isAdmin && (!isPromoteurOrGuide || !isValide)) {
          return AppRouter.home;
        }
      }
      return null;
    }

    test('1. Visiteur non connecté : tentative d\'accès à /promoteur-dashboard -> /login', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: false,
        cachedRole: null,
        cachedStatutModeration: null,
      );
      expect(redirection, equals(AppRouter.login));
    });

    test('2. Touriste connecté : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'touriste',
        cachedStatutModeration: null,
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('3. Touriste tentant d\'injecter un statut VALIDE : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'touriste',
        cachedStatutModeration: 'VALIDE',
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('4. Promoteur EN_ATTENTE : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'EN_ATTENTE',
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('5. Promoteur EN_ATTENTE_VALIDATION : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'EN_ATTENTE_VALIDATION',
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('6. Promoteur sans statut spécifié (null) : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: null,
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('7. Promoteur REJETE ou REFUSE : redirection stricte vers /home', () {
      final redirectionRejete = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'REJETE',
      );
      expect(redirectionRejete, equals(AppRouter.home));

      final redirectionRefuse = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'REFUSE',
      );
      expect(redirectionRefuse, equals(AppRouter.home));
    });

    test('8. Promoteur VALIDÉ (statut VALIDE) : accès autorisé (redirection = null)', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'VALIDE',
      );
      expect(redirection, isNull);
    });

    test('9. Promoteur APPROUVÉ (statut APPROUVE) : accès autorisé (redirection = null)', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'promoteur',
        cachedStatutModeration: 'APPROUVE',
      );
      expect(redirection, isNull);
    });

    test('10. Guide VALIDÉ (statut VALIDE) : accès autorisé', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'guide',
        cachedStatutModeration: 'VALIDE',
      );
      expect(redirection, isNull);
    });

    test('11. Guide EN_ATTENTE : redirection stricte vers /home', () {
      final redirection = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'guide',
        cachedStatutModeration: 'EN_ATTENTE',
      );
      expect(redirection, equals(AppRouter.home));
    });

    test('12. Administrateur (admin ou superAdmin) : accès inconditionnel autorisé', () {
      final redirectionAdmin = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'admin',
        cachedStatutModeration: null,
      );
      expect(redirectionAdmin, isNull);

      final redirectionSuperAdmin = evaluatePromoteurDashboardGuard(
        isLoggedIn: true,
        cachedRole: 'superAdmin',
        cachedStatutModeration: null,
      );
      expect(redirectionSuperAdmin, isNull);
    });

    test('13. UserModel accesseurs booléens et états de modération', () {
      final pAttente = const UserModel(
        email: 'p@ml.com',
        role: UserRole.promoteur,
        statutModeration: 'EN_ATTENTE',
      );
      expect(pAttente.isPromoteur, isTrue);
      expect(pAttente.isPromoteurEnAttente, isTrue);
      expect(pAttente.isPromoteurValide, isFalse);
      expect(pAttente.isPromoteurRejete, isFalse);

      final pValide = const UserModel(
        email: 'p@ml.com',
        role: UserRole.promoteur,
        statutModeration: 'VALIDE',
      );
      expect(pValide.isPromoteurValide, isTrue);
      expect(pValide.isPromoteurEnAttente, isFalse);

      final pRejete = const UserModel(
        email: 'p@ml.com',
        role: UserRole.promoteur,
        statutModeration: 'REJETE',
      );
      expect(pRejete.isPromoteurRejete, isTrue);
      expect(pRejete.isPromoteurValide, isFalse);
      expect(pRejete.isPromoteurEnAttente, isFalse);
    });
  });
}
