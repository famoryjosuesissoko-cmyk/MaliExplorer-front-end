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
                            context.go(AppRouter.home);
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
                          if (favorites.isEmpty) {
                            return _buildEmptyState(isDark);
                          }
                          return RefreshIndicator(
                            color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                            onRefresh: () async => ref.read(favorisNotifierProvider.notifier).loadFavoris(),
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                              itemCount: favorites.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = favorites[index];
                                return _buildFavoriteCard(item, index, isDark);
                              },
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
            final match = PresidentModel.chronologicalPresidents.firstWhere(
              (p) =>
                  p.nom.toLowerCase().contains(titre) ||
                  titre.contains(p.nom.toLowerCase()) ||
                  p.fullName.toLowerCase().contains(titre) ||
                  titre.contains(p.prenom.toLowerCase()),
              orElse: () => PresidentModel.chronologicalPresidents.first,
            );
            context.push(AppRouter.presidentDetail, extra: match);
          } else if (route == AppRouter.dishDetail || route.contains('dish')) {
            final match = PlatModel.defaultPlats.firstWhere(
              (p) =>
                  p.nom.toLowerCase().contains(titre) ||
                  titre.contains(p.nom.toLowerCase()),
              orElse: () => PlatModel.defaultPlats.first,
            );
            context.push(AppRouter.dishDetail, extra: match);
          } else if (route == AppRouter.ethnicityDetail || route.contains('ethnic')) {
            final match = EthnieModel.defaultEthnies.firstWhere(
              (e) =>
                  e.nom.toLowerCase().contains(titre) ||
                  titre.contains(e.nom.toLowerCase()),
              orElse: () => EthnieModel.defaultEthnies.first,
            );
            context.push(AppRouter.ethnicityDetail, extra: match);
          } else if (route == AppRouter.cityDetail || route.contains('city')) {
            final ville = VilleModel(
              id: item.referenceId ?? 0,
              nom: item.titre,
              region: item.categorie.replaceAll('Région : ', ''),
              description: '',
              imageUrl: item.displayPhoto,
            );
            context.push(AppRouter.cityDetail, extra: ville);
          } else if (route.isNotEmpty) {
            context.push(route);
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
