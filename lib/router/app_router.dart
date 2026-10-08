import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash_screen.dart';
import '../features/home_screen.dart';
import '../features/carte_screen.dart';
import '../features/explorer_screen.dart';
import '../features/login_screen.dart';
import '../features/register_screen.dart';
import '../features/gastronomie_list_screen.dart';
import '../features/ethnies_list_screen.dart';
import '../features/villes_list_screen.dart';
import '../features/chefs_etat_screen.dart';
import '../features/artisans_screen.dart';
import '../features/guides_screen.dart';
import '../features/plat_detail_screen.dart';
import '../features/ethnie_detail_screen.dart';
import '../features/ville_detail_screen.dart';
import '../features/quiz_list_screen.dart';
import '../features/quiz_play_screen.dart';
import '../features/profil_screen.dart';
import '../features/mon_parcours_screen.dart';
import '../features/favoris_screen.dart';
import '../features/artisan_dashboard_screen.dart';
import '../features/artisan_add_product_screen.dart';
import '../features/terms_conditions_screen.dart';
import '../features/personal_info_screen.dart';
import '../features/settings_screen.dart';
import '../features/help_support_screen.dart';
import '../features/historique_screen.dart';
import '../models/plat_model.dart';
import '../models/ethnie_model.dart';
import '../models/ville_model.dart';
import '../models/quiz_model.dart';
import '../widgets/main_shell.dart';

/// Configuration du routeur GoRouter pour MaliExplorer avec ShellRoute persistent
class AppRouter {
  // Clés de navigation pour séparer la navigation racine des onglets du shell
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellNav');

  static const String splash = '/';
  static const String home = '/home';
  static const String carte = '/carte';
  static const String explorer = '/explorer';
  static const String login = '/login';
  static const String register = '/register';

  // Routes des listes
  static const String gastronomieList = '/gastronomie-list';
  static const String ethniesList = '/ethnies-list';
  static const String villesList = '/villes-list';
  static const String chefsEtat = '/chefs-etat';
  static const String artisans = '/artisans';
  static const String guides = '/guides';

  // Routes des détails
  static const String dishDetail = '/dish-detail';
  static const String ethnicityDetail = '/ethnicity-detail';
  static const String cityDetail = '/city-detail';

  // Alias francophones conformes à la nomenclature
  static const String platDetail = dishDetail;
  static const String ethnieDetail = ethnicityDetail;
  static const String villeDetail = cityDetail;

  // Routes des Quiz
  static const String quizList = '/quiz';
  static const String quizPlay = '/quiz-play';

  // Routes du Profil & Découverte & Espace Artisan
  static const String profil = '/profil';
  static const String monParcours = '/mon-parcours';
  static const String favoris = '/favoris';
  static const String historique = '/historique';
  static const String artisanDashboard = '/artisan-dashboard';
  static const String artisanAddProduct = '/artisan-add-product';
  static const String terms = '/terms';
  static const String personalInfo = '/personal-info';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    routes: <RouteBase>[
      // 1. Splash Screen (Au-dessus du shell, plein écran)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),

      // 2. MainShell persistant pour les 5 destinations principales
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShell(child: child);
        },
        routes: <RouteBase>[
          // Destination 0 : Accueil
          GoRoute(
            path: home,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: HomeScreen());
            },
          ),

          // Destination 1 : Carte
          GoRoute(
            path: carte,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: CarteScreen());
            },
          ),

          // Destination 2 : Explorer
          GoRoute(
            path: explorer,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: ExplorerScreen());
            },
          ),

          // Destination 3 : Quiz
          GoRoute(
            path: quizList,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: QuizListScreen());
            },
          ),

          // Destination 4 : Profil
          GoRoute(
            path: profil,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const NoTransitionPage(child: ProfilScreen());
            },
          ),
        ],
      ),

      // 3. Authentification (Plein écran au-dessus du MainShell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),

      // 4. Listes par catégorie & patrimoine (Poussent au-dessus du MainShell avec rootNavigatorKey)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: gastronomieList,
        builder: (BuildContext context, GoRouterState state) {
          return const GastronomieListScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: ethniesList,
        builder: (BuildContext context, GoRouterState state) {
          return const EthniesListScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: villesList,
        builder: (BuildContext context, GoRouterState state) {
          return const VillesListScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: chefsEtat,
        builder: (BuildContext context, GoRouterState state) {
          return const ChefsEtatScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: artisans,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisansScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: guides,
        builder: (BuildContext context, GoRouterState state) {
          return const GuidesScreen();
        },
      ),

      // 5. Pages de détail (Poussent au-dessus du MainShell avec rootNavigatorKey)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: dishDetail,
        builder: (BuildContext context, GoRouterState state) {
          final plat = state.extra is PlatModel
              ? state.extra as PlatModel
              : null;
          return DishDetailScreen(plat: plat);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: ethnicityDetail,
        builder: (BuildContext context, GoRouterState state) {
          final ethnie = state.extra is EthnieModel
              ? state.extra as EthnieModel
              : null;
          return EthnicityDetailScreen(ethnie: ethnie);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: cityDetail,
        builder: (BuildContext context, GoRouterState state) {
          final ville = state.extra is VilleModel
              ? state.extra as VilleModel
              : null;
          return CityDetailScreen(ville: ville);
        },
      ),

      // 6. Quiz Play (Partie interactive en cours, plein écran)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: quizPlay,
        builder: (BuildContext context, GoRouterState state) {
          final quiz = state.extra is QuizModel
              ? state.extra as QuizModel
              : null;
          return QuizPlayScreen(quiz: quiz);
        },
      ),

      // 7. Parcours, Favoris & Espace Artisan (Poussent au-dessus du MainShell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: monParcours,
        builder: (BuildContext context, GoRouterState state) {
          return const MonParcoursScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: favoris,
        builder: (BuildContext context, GoRouterState state) {
          return const FavorisScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: historique,
        builder: (BuildContext context, GoRouterState state) {
          return const HistoriqueScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: artisanDashboard,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisanDashboardScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: artisanAddProduct,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisanAddProductScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: terms,
        builder: (BuildContext context, GoRouterState state) {
          return const TermsConditionsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: personalInfo,
        builder: (BuildContext context, GoRouterState state) {
          return const PersonalInfoScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: settings,
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: helpSupport,
        builder: (BuildContext context, GoRouterState state) {
          return const HelpSupportScreen();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page non trouvée : ${state.uri}'))),
  );
}
