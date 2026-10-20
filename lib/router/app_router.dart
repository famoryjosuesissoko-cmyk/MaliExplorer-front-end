import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../features/guides_screen.dart';
import '../features/plat_detail_screen.dart';
import '../features/ethnie_detail_screen.dart';
import '../features/ville_detail_screen.dart';
import '../features/quiz_list_screen.dart';
import '../features/quiz_play_screen.dart';
import '../features/profil_screen.dart';
import '../features/mon_parcours_screen.dart';
import '../features/favoris_screen.dart';
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
import '../models/favori_model.dart';
import '../widgets/main_shell.dart';

/// Écouteur réactif transformant un flux Stream en Listenable pour GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

String _normalizeText(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[àâä]'), 'a')
      .replaceAll(RegExp(r'[îï]'), 'i')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

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

  // Routes du Profil & Découverte
  static const String profil = '/profil';
  static const String monParcours = '/mon-parcours';
  static const String favoris = '/favoris';
  static const String historique = '/historique';
  static const String promoteurDashboard = '/promoteur-dashboard';
  static const String terms = '/terms';
  static const String personalInfo = '/personal-info';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';

  /// Liste des routes strictement réservées aux utilisateurs authentifiés
  static const Set<String> _authRequiredRoutes = {
    personalInfo,
    monParcours,
    promoteurDashboard,
  };

  /// Écoute le flux d'authentification en gérant l'absence d'initialisation Firebase (ex: tests headless)
  static Stream<dynamic> _safeAuthStateChanges() {
    try {
      return FirebaseAuth.instance.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Récupère l'utilisateur actuel sans lever d'exception si Firebase n'est pas initialisé
  static User? _safeCurrentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    refreshListenable: GoRouterRefreshStream(_safeAuthStateChanges()),
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = _safeCurrentUser() != null;
      final String location = state.matchedLocation;

      // Protection des routes privées : redirection automatique vers login
      if (_authRequiredRoutes.contains(location) && !isLoggedIn) {
        return login;
      }

      return null;
    },
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
            } else if (extra.payload is int) {
              final idVal = extra.payload as int;
              plat = PlatModel.defaultPlats.firstWhere(
                (p) => p.id == idVal,
                orElse: () => PlatModel(
                  id: idVal,
                  nom: extra.titre,
                  description: extra.description ?? '',
                  imageUrl: extra.imageUrl ?? PlatModel.getLocalPhoto(extra.titre),
                ),
              );
            } else {
              final q = _normalizeText(extra.titre);
              plat = PlatModel.defaultPlats.firstWhere(
                (p) {
                  final nomNorm = _normalizeText(p.nom);
                  return nomNorm.contains(q) ||
                      q.contains(nomNorm) ||
                      ((q.contains('saka') || q.contains('saga')) &&
                          (nomNorm.contains('saka') || nomNorm.contains('saga')));
                },
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
              orElse: () => PlatModel(
                id: extra,
                nom: 'Plat #$extra',
                description: '',
                imageUrl: 'assets/images/plats/tiguadegue_na.jpeg',
              ),
            );
          } else if (extra is String) {
            final q = _normalizeText(extra);
            final parsedId = int.tryParse(extra);
            plat = PlatModel.defaultPlats.firstWhere(
              (p) {
                if (parsedId != null && p.id == parsedId) return true;
                final nomNorm = _normalizeText(p.nom);
                return nomNorm.contains(q) ||
                    q.contains(nomNorm) ||
                    ((q.contains('saka') || q.contains('saga')) &&
                        (nomNorm.contains('saka') || nomNorm.contains('saga')));
              },
              orElse: () => PlatModel(
                id: parsedId ?? 0,
                nom: extra,
                description: '',
                imageUrl: PlatModel.getLocalPhoto(extra),
              ),
            );
          } else if (extra is FavoriModel) {
            plat = PlatModel(
              id: extra.referenceId ?? extra.id,
              nom: extra.titre,
              description: extra.categorie,
              imageUrl: extra.displayPhoto,
              difficulte: 'Facile',
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
            } else if (extra.payload is int) {
              final idVal = extra.payload as int;
              ethnie = EthnieModel.defaultEthnies.firstWhere(
                (e) => e.id == idVal,
                orElse: () => EthnieModel.fromJson({
                  'id': idVal,
                  'nom': extra.titre,
                  'description': extra.description ?? '',
                  'imageUrl': extra.imageUrl ?? EthnieModel.getLocalPhotoHomme(extra.titre),
                  'photoHomme': extra.imageUrl ?? EthnieModel.getLocalPhotoHomme(extra.titre),
                  'photoFemme': EthnieModel.getLocalPhotoFemme(extra.titre),
                }),
              );
            } else {
              final q = _normalizeText(extra.titre);
              ethnie = EthnieModel.defaultEthnies.firstWhere(
                (e) {
                  final nomNorm = _normalizeText(e.nom);
                  return nomNorm.contains(q) || q.contains(nomNorm);
                },
                orElse: () => EthnieModel.fromJson({
                  'id': int.tryParse(extra.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  'nom': extra.titre,
                  'description': extra.description ?? '',
                  'imageUrl': extra.imageUrl ?? EthnieModel.getLocalPhotoHomme(extra.titre),
                  'photoHomme': extra.imageUrl ?? EthnieModel.getLocalPhotoHomme(extra.titre),
                  'photoFemme': EthnieModel.getLocalPhotoFemme(extra.titre),
                }),
              );
            }
          } else if (extra is int) {
            ethnie = EthnieModel.defaultEthnies.firstWhere(
              (e) => e.id == extra,
              orElse: () => EthnieModel.fromJson({
                'id': extra,
                'nom': 'Ethnie #$extra',
                'description': '',
                'imageUrl': 'assets/images/ethnies/bambara_homme.jpeg',
                'photoHomme': 'assets/images/ethnies/bambara_homme.jpeg',
                'photoFemme': 'assets/images/ethnies/Bambara2.jpeg',
              }),
            );
          } else if (extra is String) {
            final q = _normalizeText(extra);
            final parsedId = int.tryParse(extra);
            ethnie = EthnieModel.defaultEthnies.firstWhere(
              (e) {
                if (parsedId != null && e.id == parsedId) return true;
                final nomNorm = _normalizeText(e.nom);
                return nomNorm.contains(q) || q.contains(nomNorm);
              },
              orElse: () => EthnieModel.fromJson({
                'id': parsedId ?? 0,
                'nom': extra,
                'description': '',
                'imageUrl': EthnieModel.getLocalPhotoHomme(extra),
                'photoHomme': EthnieModel.getLocalPhotoHomme(extra),
                'photoFemme': EthnieModel.getLocalPhotoFemme(extra),
              }),
            );
          } else if (extra is FavoriModel) {
            ethnie = EthnieModel.fromJson({
              'id': extra.referenceId ?? extra.id,
              'nom': extra.titre,
              'description': extra.categorie,
              'imageUrl': extra.displayPhoto,
              'photoHomme': extra.displayPhoto,
            });
          } else if (extra is Map<String, dynamic>) {
            try {
              ethnie = EthnieModel.fromJson(extra);
            } catch (_) {}
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
            } else if (extra.payload is int) {
              final idVal = extra.payload as int;
              ville = VilleModel.defaultVilles.firstWhere(
                (v) => v.id == idVal,
                orElse: () => VilleModel(
                  id: idVal,
                  nom: extra.titre,
                  region: extra.sousTitre ?? '',
                  description: extra.description ?? '',
                  imageUrl: extra.imageUrl ?? VilleModel.getLocalPhoto(extra.titre),
                ),
              );
            } else {
              final q = _normalizeText(extra.titre);
              ville = VilleModel.defaultVilles.firstWhere(
                (v) {
                  final nomNorm = _normalizeText(v.nom);
                  return nomNorm.contains(q) || q.contains(nomNorm);
                },
                orElse: () => VilleModel(
                  id: int.tryParse(extra.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  nom: extra.titre,
                  region: extra.sousTitre ?? '',
                  description: extra.description ?? '',
                  imageUrl: extra.imageUrl ?? VilleModel.getLocalPhoto(extra.titre),
                ),
              );
            }
          } else if (extra is int) {
            ville = VilleModel.defaultVilles.firstWhere(
              (v) => v.id == extra,
              orElse: () => VilleModel(
                id: extra,
                nom: 'Ville #$extra',
                region: '',
                description: '',
                imageUrl: 'assets/images/bamako_cover.jpeg',
              ),
            );
          } else if (extra is String) {
            final q = _normalizeText(extra);
            final parsedId = int.tryParse(extra);
            ville = VilleModel.defaultVilles.firstWhere(
              (v) {
                if (parsedId != null && v.id == parsedId) return true;
                final nomNorm = _normalizeText(v.nom);
                return nomNorm.contains(q) || q.contains(nomNorm);
              },
              orElse: () => VilleModel(
                id: parsedId ?? 0,
                nom: extra,
                region: '',
                description: '',
                imageUrl: VilleModel.getLocalPhoto(extra),
              ),
            );
          } else if (extra is FavoriModel) {
            ville = VilleModel(
              id: extra.referenceId ?? extra.id,
              nom: extra.titre,
              region: extra.categorie.replaceAll('Région : ', ''),
              description: '',
              imageUrl: extra.displayPhoto,
            );
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
            } else if (extra.payload is int) {
              final idVal = extra.payload as int;
              president = PresidentModel.chronologicalPresidents.firstWhere(
                (p) => p.id == idVal,
                orElse: () => PresidentModel(
                  id: idVal,
                  prenom: '',
                  nom: extra.titre,
                  periodeMandat: extra.sousTitre ?? '',
                  biographie: extra.description ?? '',
                  photoUrl: extra.imageUrl ?? PresidentModel.getLocalPhoto(extra.titre, idVal),
                ),
              );
            } else {
              final q = _normalizeText(extra.titre);
              president = PresidentModel.chronologicalPresidents.firstWhere(
                (p) {
                  final nomNorm = _normalizeText(p.nom);
                  final prenomNorm = _normalizeText(p.prenom);
                  final fullNorm = _normalizeText(p.fullName);
                  return nomNorm.contains(q) ||
                      q.contains(nomNorm) ||
                      prenomNorm.contains(q) ||
                      q.contains(prenomNorm) ||
                      fullNorm.contains(q) ||
                      q.contains(fullNorm);
                },
                orElse: () => PresidentModel(
                  id: int.tryParse(extra.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  prenom: '',
                  nom: extra.titre,
                  periodeMandat: extra.sousTitre ?? '',
                  biographie: extra.description ?? '',
                  photoUrl: extra.imageUrl ?? PresidentModel.getLocalPhoto(extra.titre),
                ),
              );
            }
          } else if (extra is int) {
            president = PresidentModel.chronologicalPresidents.firstWhere(
              (p) => p.id == extra,
              orElse: () => PresidentModel(
                id: extra,
                prenom: '',
                nom: 'Chef d\'État #$extra',
                periodeMandat: '',
                biographie: '',
                photoUrl: PresidentModel.getLocalPhoto('Chef d\'État #$extra', extra),
              ),
            );
          } else if (extra is String) {
            final q = _normalizeText(extra);
            final parsedId = int.tryParse(extra);
            president = PresidentModel.chronologicalPresidents.firstWhere(
              (p) {
                if (parsedId != null && p.id == parsedId) return true;
                final nomNorm = _normalizeText(p.nom);
                final prenomNorm = _normalizeText(p.prenom);
                final fullNorm = _normalizeText(p.fullName);
                return nomNorm.contains(q) ||
                    q.contains(nomNorm) ||
                    prenomNorm.contains(q) ||
                    q.contains(prenomNorm) ||
                    fullNorm.contains(q) ||
                    q.contains(fullNorm);
              },
              orElse: () => PresidentModel(
                id: parsedId ?? 0,
                prenom: '',
                nom: extra,
                periodeMandat: '',
                biographie: '',
                photoUrl: PresidentModel.getLocalPhoto(extra, parsedId),
              ),
            );
          } else if (extra is FavoriModel) {
            president = PresidentModel(
              id: extra.referenceId ?? extra.id,
              prenom: '',
              nom: extra.titre,
              periodeMandat: extra.categorie,
              biographie: '',
              photoUrl: extra.displayPhoto,
            );
          } else if (extra is Map<String, dynamic>) {
            try {
              president = PresidentModel.fromJson(extra);
            } catch (_) {}
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

          RegionModel? findRegion(String query) {
            final norm = _normalizeText(query);
            if (norm.isEmpty) return null;
            // 1. Correspondance exacte sur identifiant, nom ou chef-lieu
            for (final r in RegionData.regions) {
              if (_normalizeText(r.id) == norm ||
                  _normalizeText(r.nom) == norm ||
                  _normalizeText(r.chefLieu) == norm) {
                return r;
              }
            }
            // 2. Correspondance partielle
            for (final r in RegionData.regions) {
              final nomNorm = _normalizeText(r.nom);
              final chefNorm = _normalizeText(r.chefLieu);
              final idNorm = _normalizeText(r.id);
              if (nomNorm.contains(norm) ||
                  norm.contains(nomNorm) ||
                  chefNorm.contains(norm) ||
                  norm.contains(chefNorm) ||
                  idNorm.contains(norm) ||
                  norm.contains(idNorm)) {
                return r;
              }
            }
            return null;
          }

          RegionModel? findRegionByIntId(int id) {
            const map = {
              1: 'bamako',
              2: 'segou',
              3: 'mopti',
              4: 'tombouctou',
              5: 'sikasso',
              6: 'gao',
              7: 'kayes',
              8: 'koulikoro',
              9: 'kidal',
              10: 'taoudenit',
              11: 'menaka',
              12: 'koutiala',
              13: 'san',
              14: 'kenieba',
              15: 'kita',
              16: 'bandiagara',
            };
            final slug = map[id];
            if (slug != null) {
              return RegionData.findById(slug);
            }
            if (id >= 1 && id <= RegionData.regions.length) {
              return RegionData.regions[id - 1];
            }
            return null;
          }

          if (extra is RegionModel) {
            region = extra;
          } else if (extra is SearchResultItem) {
            if (extra.payload is RegionModel) {
              region = extra.payload as RegionModel;
            } else if (extra.payload is int) {
              region = findRegionByIntId(extra.payload as int) ?? findRegion(extra.titre);
            } else {
              region = findRegion(extra.titre);
            }
            if (region == null && extra.titre.isNotEmpty) {
              region = RegionModel(
                id: extra.id,
                nom: extra.titre,
                chefLieu: extra.sousTitre?.replaceFirst('Chef-lieu: ', '') ?? extra.titre,
                latitude: 12.6392,
                longitude: -8.0029,
                description: extra.description ?? '',
                imageCover: extra.imageUrl ?? 'assets/images/bamako_cover.jpeg',
                population: 'N/A',
                superficie: 'N/A',
              );
            }
          } else if (extra is int) {
            region = findRegionByIntId(extra);
          } else if (extra is String) {
            final parsedId = int.tryParse(extra);
            if (parsedId != null) {
              region = findRegionByIntId(parsedId) ?? findRegion(extra);
            } else {
              region = findRegion(extra);
            }
          } else if (extra is FavoriModel) {
            region = findRegion(extra.titre) ??
                RegionModel(
                  id: (extra.referenceId ?? extra.id).toString(),
                  nom: extra.titre,
                  chefLieu: extra.titre,
                  latitude: 12.6392,
                  longitude: -8.0029,
                  description: extra.categorie,
                  imageCover: extra.displayPhoto,
                  population: 'N/A',
                  superficie: 'N/A',
                );
          } else if (extra is Map<String, dynamic>) {
            final nom = extra['nom'] ?? extra['nomRegion'] ?? '';
            final idVal = extra['id'] ?? extra['idRegion'];
            if (idVal is int) {
              region = findRegionByIntId(idVal);
            }
            region ??= findRegion(nom.toString());
          }

          if (region == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Région introuvable'),
                backgroundColor: const Color(0xFF075E4D),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off_rounded, size: 64, color: Color(0xFF8B9B95)),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune région correspondante trouvée',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075E4D),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Retour'),
                      ),
                    ],
                  ),
                ),
              ),
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
          } else if (extra is FavoriModel) {
            final q = extra.titre.toLowerCase();
            religion = ReligionModel.defaultReligions.firstWhere(
              (r) =>
                  (extra.referenceId != null && r.id == extra.referenceId) ||
                  r.nom.toLowerCase().contains(q) ||
                  q.contains(r.nom.toLowerCase()),
              orElse: () => ReligionModel(
                id: extra.referenceId ?? extra.id,
                nom: extra.titre,
                categorie: extra.categorie,
                description: '',
                histoire: '',
                pratiques: '',
                fetes: '',
                lieuxDeCulte: '',
                regionsConcernees: '',
                imageUrl: extra.displayPhoto,
              ),
            );
            if (extra.imageUrl.isNotEmpty &&
                (extra.imageUrl.startsWith('http') || extra.imageUrl.startsWith('assets/'))) {
              religion = religion.copyWith(imageUrl: extra.displayPhoto);
            }
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

      // 7. Parcours, Favoris & Profil (Poussent au-dessus du MainShell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: monParcours,
        redirect: (BuildContext context, GoRouterState state) {
          if (_safeCurrentUser() == null) {
            return AppRouter.login;
          }
          return null;
        },
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
        path: promoteurDashboard,
        redirect: (BuildContext context, GoRouterState state) {
          if (_safeCurrentUser() == null) {
            return AppRouter.login;
          }
          return null;
        },
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
        redirect: (BuildContext context, GoRouterState state) {
          if (_safeCurrentUser() == null) {
            return AppRouter.login;
          }
          return null;
        },
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
