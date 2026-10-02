import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash_screen.dart';
import '../features/home_screen.dart';
import '../features/gastronomie_list_screen.dart';
import '../features/ethnies_list_screen.dart';
import '../features/villes_list_screen.dart';
import '../features/plat_detail_screen.dart';
import '../features/ethnie_detail_screen.dart';
import '../features/ville_detail_screen.dart';

/// Configuration du routeur GoRouter pour MaliExplorer
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

  // Routes des listes
  static const String gastronomieList = '/gastronomie-list';
  static const String ethniesList = '/ethnies-list';
  static const String villesList = '/villes-list';

  // Routes des détails
  static const String dishDetail = '/dish-detail';
  static const String ethnicityDetail = '/ethnicity-detail';
  static const String cityDetail = '/city-detail';

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

      // 3. Page Détail d'un Plat (Sakasaka)
      // 3. Listes par catégorie
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

      // 4. Pages de détail
      GoRoute(
        path: dishDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const DishDetailScreen();
        },
      ),

      // 4. Page Détail d'une Ethnie (Les Dogons)
      GoRoute(
        path: ethnicityDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const EthnicityDetailScreen();
        },
      ),

      // 5. Page Détail d'une Ville (Tombouctou)
      GoRoute(
        path: cityDetail,
        builder: (BuildContext context, GoRouterState state) {
          return const CityDetailScreen();
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page non trouvée : ${state.uri}'))),
  );
}
