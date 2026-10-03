import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash_screen.dart';
import '../features/home_screen.dart';
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

/// Configuration du routeur GoRouter pour MaliExplorer
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

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

  // Routes des Quiz
  static const String quizList = '/quiz';
  static const String quizPlay = '/quiz-play';

  // Routes du Profil & Découverte & Espace Artisan
  static const String profil = '/profil';
  static const String monParcours = '/mon-parcours';
  static const String favoris = '/favoris';
  static const String artisanDashboard = '/artisan-dashboard';
  static const String artisanAddProduct = '/artisan-add-product';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: <RouteBase>[
      // 1. Splash Screen
      GoRoute(
        path: splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),

      // 2. Page d'Accueil
      GoRoute(
        path: home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),

      // 3. Listes par catégorie & patrimoine
      GoRoute(
        path: gastronomieList,
        builder: (BuildContext context, GoRouterState state) {
          return const GastronomieListScreen();
        },
      ),
      GoRoute(
        path: ethniesList,
        builder: (BuildContext context, GoRouterState state) {
          return const EthniesListScreen();
        },
      ),
      GoRoute(
        path: villesList,
        builder: (BuildContext context, GoRouterState state) {
          return const VillesListScreen();
        },
      ),
      GoRoute(
        path: chefsEtat,
        builder: (BuildContext context, GoRouterState state) {
          return const ChefsEtatScreen();
        },
      ),
      GoRoute(
        path: artisans,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisansScreen();
        },
      ),
      GoRoute(
        path: guides,
        builder: (BuildContext context, GoRouterState state) {
          return const GuidesScreen();
        },
      ),

      // 4. Pages de détail
      GoRoute(
        path: dishDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const DishDetailScreen();
        },
      ),
      GoRoute(
        path: ethnicityDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const EthnicityDetailScreen();
        },
      ),
      GoRoute(
        path: cityDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const CityDetailScreen();
        },
      ),

      // 5. Quiz
      GoRoute(
        path: quizList,
        builder: (BuildContext context, GoRouterState state) {
          return const QuizListScreen();
        },
      ),
      GoRoute(
        path: quizPlay,
        builder: (BuildContext context, GoRouterState state) {
          return const QuizPlayScreen();
        },
      ),

      // 6. Profil, Parcours, Favoris & Espace Artisan
      GoRoute(
        path: profil,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfilScreen();
        },
      ),
      GoRoute(
        path: monParcours,
        builder: (BuildContext context, GoRouterState state) {
          return const MonParcoursScreen();
        },
      ),
      GoRoute(
        path: favoris,
        builder: (BuildContext context, GoRouterState state) {
          return const FavorisScreen();
        },
      ),
      GoRoute(
        path: artisanDashboard,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisanDashboardScreen();
        },
      ),
      GoRoute(
        path: artisanAddProduct,
        builder: (BuildContext context, GoRouterState state) {
          return const ArtisanAddProductScreen();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page non trouvée : ${state.uri}'))),
  );
}
