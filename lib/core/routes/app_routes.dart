import '../../models/quiz_model.dart';
import 'package:go_router/go_router.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/regions/regions_screen.dart';
import '../../screens/regions/region_detail_screen.dart';
import '../../screens/villes/villes_screen.dart';
import '../../screens/villes/ville_detail_screen.dart';
import '../../screens/lieux_historiques/lieux_screen.dart';
import '../../screens/lieux_historiques/lieu_detail_screen.dart';
import '../../screens/lieux_historiques/galerie_360_screen.dart';
import '../../screens/plats/plats_screen.dart';
import '../../screens/plats/plat_detail_screen.dart';
import '../../screens/ethnies/ethnies_screen.dart';
import '../../screens/ethnies/ethnie_detail_screen.dart';
import '../../screens/presidents/presidents_screen.dart';
import '../../screens/presidents/president_detail_screen.dart';
import '../../screens/articles/articles_screen.dart';
import '../../screens/articles/article_detail_screen.dart';
import '../../screens/evenements/evenements_screen.dart';
import '../../screens/evenements/evenement_detail_screen.dart';
import '../../screens/carte/carte_screen.dart';
import '../../screens/quiz/quiz_screen.dart';
import '../../screens/quiz/quiz_play_screen.dart';
import '../../screens/quiz/quiz_result_screen.dart';
import '../../screens/badges/badges_screen.dart';
import '../../screens/favoris/favoris_screen.dart';
import '../../screens/partenaires/partenaires_screen.dart';
import '../../screens/partenaires/partenaire_form_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/regions',
        builder: (context, state) => const RegionsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return RegionDetailScreen(regionId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/villes',
        builder: (context, state) => const VillesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return VilleDetailScreen(villeId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/lieux',
        builder: (context, state) => const LieuxScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return LieuDetailScreen(lieuId: id);
            },
          ),
          GoRoute(
            path: '360/:id',
            builder: (context, state) {
              final panoramaUrl = state.extra as String? ?? '';
              return Galerie360Screen(panoramaUrl: panoramaUrl);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/plats',
        builder: (context, state) => const PlatsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return PlatDetailScreen(platId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/ethnies',
        builder: (context, state) => const EthniesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return EthnieDetailScreen(ethnieId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/presidents',
        builder: (context, state) => const PresidentsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return PresidentDetailScreen(presidentId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/articles',
        builder: (context, state) => const ArticlesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return ArticleDetailScreen(articleId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/evenements',
        builder: (context, state) => const EvenementsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return EvenementDetailScreen(evenementId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/carte',
        builder: (context, state) => const CarteScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
        routes: [
          GoRoute(
            path: 'play/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
              return QuizPlayScreen(quizId: id);
            },
          ),
          GoRoute(
            path: 'result',
            builder: (context, state) {
              final res = state.extra as QuizResultModel? ?? const QuizResultModel.empty();
              return QuizResultScreen(result: res);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/badges',
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/favoris',
        builder: (context, state) => const FavorisScreen(),
      ),
      GoRoute(
        path: '/partenaires',
        builder: (context, state) => const PartenairesScreen(),
        routes: [
          GoRoute(
            path: 'inscription',
            builder: (context, state) => const PartenaireFormScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
