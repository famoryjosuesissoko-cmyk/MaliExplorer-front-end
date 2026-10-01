import 'package:go_router/go_router.dart';
import '../features/dish_detail_screen.dart';
import '../features/ethnicity_detail_screen.dart';
import '../features/home_screen.dart';
import '../features/splash_screen.dart';

/// Configuration centralisée du routage GoRouter pour MaliExplorer.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/dish-detail',
      name: 'dish-detail',
      builder: (context, state) => const DishDetailScreen(),
    ),
    GoRoute(
      path: '/ethnicity-detail',
      name: 'ethnicity-detail',
      builder: (context, state) => const EthnicityDetailScreen(),
    ),
  ],
);
