import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favori_model.dart';
import '../models/president_model.dart';
import '../models/plat_model.dart';
import '../models/ethnie_model.dart';
import '../models/ville_model.dart';
import '../models/region_model.dart';
import '../models/religion_model.dart';
import '../providers/favoris_provider.dart';

class FavorisScreen extends ConsumerStatefulWidget {
  const FavorisScreen({super.key});

  @override
  ConsumerState<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends ConsumerState<FavorisScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. En-tête vert
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRouter.profil);
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Mes favoris',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche avec la liste des favoris
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ref.watch(favorisProvider).when(
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: Color(0xFFE53935),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Erreur de chargement des favoris',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16332D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => ref.invalidate(favorisProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF075E4D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                        data: (favorites) {
                          return RefreshIndicator(
                            color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                            onRefresh: () async {
                              await ref.read(favorisNotifierProvider.notifier).loadFavoris();
                            },
                            child: ListView(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                              children: [
                                if (favorites.isEmpty)
                                  _buildEmptyState(isDark)
                                else ...[
                                  ...favorites.asMap().entries.map((entry) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _buildFavoriteCard(entry.value, entry.key, isDark),
                                      )),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: isDark ? AppColors.darkTextDisabled : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun favori pour le moment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Explorez et ajoutez vos lieux et plats préférés !',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriModel item, int index, bool isDark) {
    return Dismissible(
      key: Key('${item.titre}_${item.id}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await ref.read(favorisNotifierProvider.notifier).removeFavori(item);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.titre} retiré des favoris'),
              duration: const Duration(seconds: 2),
              backgroundColor: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
            ),
          );
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
      ),
      child: InkWell(
        onTap: () {
          final route = item.route;
          final titre = item.titre.toLowerCase();
          if (route == AppRouter.presidentDetail || route.contains('president')) {
            PresidentModel? match;
            try {
              match = PresidentModel.chronologicalPresidents.firstWhere(
                (p) =>
                    p.nom.toLowerCase().contains(titre) ||
                    titre.contains(p.nom.toLowerCase()) ||
                    p.fullName.toLowerCase().contains(titre) ||
                    titre.contains(p.prenom.toLowerCase()),
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              final resolvedPhoto = (item.imageUrl.isNotEmpty &&
                      (item.imageUrl.startsWith('http') || item.imageUrl.startsWith('/') || item.imageUrl.startsWith('uploads/')))
                  ? item.displayPhoto
                  : match.photoUrl;
              context.push(AppRouter.presidentDetail, extra: match.copyWith(photoUrl: resolvedPhoto));
            } else {
              final dynamicPres = PresidentModel(
                id: item.referenceId ?? item.id,
                prenom: '',
                nom: item.titre,
                periodeMandat: item.categorie,
                biographie: '',
                photoUrl: item.displayPhoto,
              );
              context.push(AppRouter.presidentDetail, extra: dynamicPres);
            }
          } else if (route == AppRouter.dishDetail || route.contains('dish')) {
            PlatModel? match;
            try {
              match = PlatModel.defaultPlats.firstWhere(
                (p) =>
                    p.nom.toLowerCase().contains(titre) ||
                    titre.contains(p.nom.toLowerCase()) ||
                    ((titre.contains('saka') || titre.contains('saga')) &&
                        (p.nom.toLowerCase().contains('saka') ||
                            p.nom.toLowerCase().contains('saga'))),
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              final resolvedPhoto = (item.imageUrl.isNotEmpty &&
                      (item.imageUrl.startsWith('http') || item.imageUrl.startsWith('/') || item.imageUrl.startsWith('uploads/')))
                  ? item.displayPhoto
                  : match.imageUrl;
              context.push(AppRouter.dishDetail, extra: match.copyWith(imageUrl: resolvedPhoto));
            } else {
              final dynamicPlat = PlatModel(
                id: item.referenceId ?? item.id,
                nom: item.titre,
                description: item.categorie,
                imageUrl: item.displayPhoto,
                difficulte: 'Facile',
              );
              context.push(AppRouter.dishDetail, extra: dynamicPlat);
            }
          } else if (route == AppRouter.ethnicityDetail || route.contains('ethnic')) {
            EthnieModel? match;
            try {
              match = EthnieModel.defaultEthnies.firstWhere(
                (e) =>
                    e.nom.toLowerCase().contains(titre) ||
                    titre.contains(e.nom.toLowerCase()),
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              context.push(AppRouter.ethnicityDetail, extra: match);
            } else {
              final dynamicEthnie = EthnieModel.fromJson({
                'id': item.referenceId ?? item.id,
                'nom': item.titre,
                'imageUrl': item.displayPhoto,
                'photoHomme': item.displayPhoto,
                'region': item.categorie,
              });
              context.push(AppRouter.ethnicityDetail, extra: dynamicEthnie);
            }
          } else if (route == AppRouter.regionDetail || route.contains('region')) {
            RegionModel? match;
            try {
              match = RegionData.regions.firstWhere(
                (r) =>
                    r.nom.toLowerCase().contains(titre) ||
                    titre.contains(r.nom.toLowerCase()) ||
                    r.id.toLowerCase() == titre,
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              context.push(AppRouter.regionDetail, extra: match);
            } else {
              final dynamicRegion = RegionModel(
                id: (item.referenceId ?? item.id).toString(),
                nom: item.titre,
                chefLieu: item.titre,
                latitude: 12.6392,
                longitude: -8.0029,
                description: '',
                imageCover: item.displayPhoto,
                population: 'N/A',
                superficie: 'N/A',
              );
              context.push(AppRouter.regionDetail, extra: dynamicRegion);
            }
          } else if (route == AppRouter.cityDetail || route.contains('city')) {
            VilleModel? match;
            try {
              match = VilleModel.defaultVilles.firstWhere(
                (v) =>
                    v.nom.toLowerCase().contains(titre) ||
                    titre.contains(v.nom.toLowerCase()) ||
                    (item.referenceId != null && v.id == item.referenceId),
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              final resolvedPhoto = (item.imageUrl.isNotEmpty &&
                      (item.imageUrl.startsWith('http') || item.imageUrl.startsWith('/') || item.imageUrl.startsWith('assets/')))
                  ? item.displayPhoto
                  : match.imageUrl;
              context.push(AppRouter.cityDetail, extra: match.copyWith(imageUrl: resolvedPhoto));
            } else {
              final ville = VilleModel(
                id: item.referenceId ?? item.id,
                nom: item.titre,
                region: item.categorie.replaceAll('Région : ', ''),
                description: '',
                imageUrl: item.displayPhoto,
              );
              context.push(AppRouter.cityDetail, extra: ville);
            }
          } else if (route == AppRouter.religionDetail || route.contains('religion')) {
            ReligionModel? match;
            try {
              match = ReligionModel.defaultReligions.firstWhere(
                (r) =>
                    r.nom.toLowerCase().contains(titre) ||
                    titre.contains(r.nom.toLowerCase()) ||
                    (item.referenceId != null && r.id == item.referenceId),
              );
            } catch (_) {
              match = null;
            }
            if (match != null) {
              final resolvedPhoto = (item.imageUrl.isNotEmpty &&
                      (item.imageUrl.startsWith('http') || item.imageUrl.startsWith('/') || item.imageUrl.startsWith('assets/')))
                  ? item.displayPhoto
                  : match.imageUrl;
              context.push(AppRouter.religionDetail, extra: match.copyWith(imageUrl: resolvedPhoto));
            } else {
              final dynamicRel = ReligionModel(
                id: item.referenceId ?? item.id,
                nom: item.titre,
                categorie: item.categorie,
                description: '',
                histoire: '',
                pratiques: '',
                fetes: '',
                lieuxDeCulte: '',
                regionsConcernees: '',
                imageUrl: item.displayPhoto,
              );
              context.push(AppRouter.religionDetail, extra: dynamicRel);
            }
          } else if (route.isNotEmpty) {
            context.push(route, extra: item);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Image miniature avec support automatique des assets locaux
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.displayPhoto.startsWith('assets/')
                    ? Image.asset(
                        item.displayPhoto,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholder(isDark),
                      )
                    : Image.network(
                        item.displayPhoto,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholder(isDark),
                      ),
              ),
              const SizedBox(width: 14),

              // Titre et Catégorie
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titre,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.categorie,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () async {
                  await ref.read(favorisNotifierProvider.notifier).removeFavori(item);
                },
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFDC2626),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: 58,
      height: 58,
      color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F3),
      child: Icon(
        Icons.image_outlined,
        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
      ),
    );
  }
}
