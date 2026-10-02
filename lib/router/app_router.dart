import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash_screen.dart';
import '../features/home_screen.dart';
import '../features/dish_detail_screen.dart';
import '../features/ethnicity_detail_screen.dart';
import '../features/city_detail_screen.dart';

/// Configuration du routeur GoRouter pour MaliExplorer
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
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
