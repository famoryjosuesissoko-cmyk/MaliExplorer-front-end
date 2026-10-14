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
import '../features/promoteur_dashboard_screen.dart';
import '../models/plat_model.dart';
import '../models/ethnie_model.dart';
import '../models/ville_model.dart';
import '../models/quiz_model.dart';
import '../models/president_model.dart';
import '../features/president_detail_screen.dart';
import '../features/langues_nationales_screen.dart';
import '../features/infos_pratiques_screen.dart';
import '../features/region_detail_screen.dart';
import '../features/visite_virtuelle_360_screen.dart';
import '../features/religions_list_screen.dart';
import '../features/religion_detail_screen.dart';
import '../models/region_model.dart';
import '../models/religion_model.dart';
import '../models/search_result_item.dart';
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
  static const String languesNationales = '/langues-nationales';
  static const String infosPratiques = '/infos-pratiques';
  static const String religionsList = '/religions-list';

  // Routes des détails
  static const String dishDetail = '/dish-detail';
  static const String ethnicityDetail = '/ethnicity-detail';
  static const String cityDetail = '/city-detail';
  static const String presidentDetail = '/president-detail';
  static const String regionDetail = '/region-detail';
  static const String religionDetail = '/religion-detail';
  static const String visiteVirtuelle360 = '/visite-virtuelle-360';

  // Alias francophones conformes à la nomenclature
  static const String platDetail = dishDetail;
  static const String ethnieDetail = ethnicityDetail;
  static const String villeDetail = cityDetail;
  static const String chefEtatDetail = presidentDetail;

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
  static const String promoteurDashboard = '/promoteur-dashboard';
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
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: languesNationales,
        builder: (BuildContext context, GoRouterState state) {
          return const LanguesNationalesScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: infosPratiques,
        builder: (BuildContext context, GoRouterState state) {
          return const InfosPratiquesScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: religionsList,
        builder: (BuildContext context, GoRouterState state) {
          return const ReligionsListScreen();
        },
      ),

      // 5. Pages de détail (Poussent au-dessus du MainShell avec rootNavigatorKey)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: dishDetail,
        builder: (BuildContext context, GoRouterState state) {
          PlatModel? plat;
          final extra = state.extra;
          if (extra is PlatModel) {
            plat = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is PlatModel) {
              plat = extra.payload as PlatModel;
            } else {
              final q = extra.titre.toLowerCase();
              plat = PlatModel.defaultPlats.firstWhere(
                (p) => p.nom.toLowerCase().contains(q) || q.contains(p.nom.toLowerCase()) ||
                    ((q.contains('saka') || q.contains('saga')) && (p.nom.toLowerCase().contains('saka') || p.nom.toLowerCase().contains('saga'))),
                orElse: () => PlatModel(
                  id: int.tryParse(extra.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  nom: extra.titre,
                  description: extra.description ?? '',
                  imageUrl: extra.imageUrl ?? PlatModel.getLocalPhoto(extra.titre),
                ),
              );
            }
          } else if (extra is int) {
            plat = PlatModel.defaultPlats.firstWhere(
              (p) => p.id == extra,
              orElse: () => PlatModel.defaultPlats.first,
            );
          } else if (extra is String) {
            final q = extra.toLowerCase();
            plat = PlatModel.defaultPlats.firstWhere(
              (p) => p.nom.toLowerCase().contains(q) || q.contains(p.nom.toLowerCase()) ||
                  ((q.contains('saka') || q.contains('saga')) && (p.nom.toLowerCase().contains('saka') || p.nom.toLowerCase().contains('saga'))),
              orElse: () => PlatModel.defaultPlats.first,
            );
          } else if (extra is Map<String, dynamic>) {
            try {
              plat = PlatModel.fromJson(extra);
            } catch (_) {}
          }
          return DishDetailScreen(plat: plat);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: ethnicityDetail,
        builder: (BuildContext context, GoRouterState state) {
          EthnieModel? ethnie;
          final extra = state.extra;
          if (extra is EthnieModel) {
            ethnie = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is EthnieModel) {
              ethnie = extra.payload as EthnieModel;
            } else {
              final q = extra.titre.toLowerCase();
              ethnie = EthnieModel.defaultEthnies.firstWhere(
                (e) => e.nom.toLowerCase().contains(q) || q.contains(e.nom.toLowerCase()),
                orElse: () => EthnieModel.defaultEthnies.first,
              );
            }
          } else if (extra is int) {
            ethnie = EthnieModel.defaultEthnies.firstWhere(
              (e) => e.id == extra,
              orElse: () => EthnieModel.defaultEthnies.first,
            );
          } else if (extra is String) {
            final q = extra.toLowerCase();
            ethnie = EthnieModel.defaultEthnies.firstWhere(
              (e) => e.nom.toLowerCase().contains(q) || q.contains(e.nom.toLowerCase()),
              orElse: () => EthnieModel.defaultEthnies.first,
            );
          }
          return EthnicityDetailScreen(ethnie: ethnie);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: cityDetail,
        builder: (BuildContext context, GoRouterState state) {
          VilleModel? ville;
          final extra = state.extra;
          if (extra is VilleModel) {
            ville = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is VilleModel) {
              ville = extra.payload as VilleModel;
            } else {
              ville = VilleModel(
                id: int.tryParse(extra.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                nom: extra.titre,
                region: extra.sousTitre ?? '',
                description: extra.description ?? '',
                imageUrl: extra.imageUrl ?? VilleModel.getLocalPhoto(extra.titre),
              );
            }
          } else if (extra is Map<String, dynamic>) {
            try {
              ville = VilleModel.fromJson(extra);
            } catch (_) {}
          }
          return CityDetailScreen(ville: ville);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: presidentDetail,
        builder: (BuildContext context, GoRouterState state) {
          PresidentModel? president;
          final extra = state.extra;
          if (extra is PresidentModel) {
            president = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is PresidentModel) {
              president = extra.payload as PresidentModel;
            }
          }
          return PresidentDetailScreen(president: president);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: regionDetail,
        builder: (BuildContext context, GoRouterState state) {
          RegionModel? region;
          final extra = state.extra;
          if (extra is RegionModel) {
            region = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is RegionModel) {
              region = extra.payload as RegionModel;
            } else {
              final q = extra.titre.toLowerCase();
              region = RegionData.regions.firstWhere(
                (r) => r.nom.toLowerCase().contains(q) || q.contains(r.nom.toLowerCase()) || r.chefLieu.toLowerCase().contains(q),
                orElse: () => RegionData.regions.first,
              );
            }
          } else if (extra is String) {
            final q = extra.toLowerCase();
            region = RegionData.regions.firstWhere(
              (r) => r.id.toLowerCase() == q || r.nom.toLowerCase().contains(q) || r.chefLieu.toLowerCase().contains(q),
              orElse: () => RegionData.regions.first,
            );
          }
          return RegionDetailScreen(region: region);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: religionDetail,
        builder: (BuildContext context, GoRouterState state) {
          ReligionModel? religion;
          final extra = state.extra;
          if (extra is ReligionModel) {
            religion = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is ReligionModel) {
              religion = extra.payload as ReligionModel;
            } else {
              final q = extra.titre.toLowerCase();
              religion = ReligionModel.defaultReligions.firstWhere(
                (r) => r.nom.toLowerCase().contains(q) || q.contains(r.nom.toLowerCase()),
                orElse: () => ReligionModel.defaultReligions.first,
              );
            }
          } else if (extra is int) {
            religion = ReligionModel.defaultReligions.firstWhere(
              (r) => r.id == extra,
              orElse: () => ReligionModel.defaultReligions.first,
            );
          } else if (extra is String) {
            final q = extra.toLowerCase();
            religion = ReligionModel.defaultReligions.firstWhere(
              (r) => r.nom.toLowerCase().contains(q) || q.contains(r.nom.toLowerCase()),
              orElse: () => ReligionModel.defaultReligions.first,
            );
          }
          return ReligionDetailScreen(religion: religion);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: visiteVirtuelle360,
        builder: (BuildContext context, GoRouterState state) {
          final extraMap = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : null;
          return VisiteVirtuelle360Screen(
            title: extraMap?['title'] as String?,
            panoramaPath: extraMap?['panorama'] as String?,
          );
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
        path: promoteurDashboard,
        builder: (BuildContext context, GoRouterState state) {
          return const PromoteurDashboardScreen();
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
