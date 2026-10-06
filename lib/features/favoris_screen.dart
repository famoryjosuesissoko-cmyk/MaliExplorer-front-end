import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favori_model.dart';
import '../providers/favoris_provider.dart';

class FavorisScreen extends ConsumerStatefulWidget {
  const FavorisScreen({super.key});

  @override
  ConsumerState<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends ConsumerState<FavorisScreen> {

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ref.watch(favorisProvider).when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF075E4D),
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
                            return _buildEmptyState();
                          }
                          return RefreshIndicator(
                            color: const Color(0xFF075E4D),
                            onRefresh: () async => ref.read(favorisNotifierProvider.notifier).loadFavoris(),
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                              itemCount: favorites.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = favorites[index];
                                return _buildFavoriteCard(item, index);
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'Aucun favori pour le moment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF16332D),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Explorez et ajoutez vos lieux et plats préférés !',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6C7C77),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriModel item, int index) {
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
              backgroundColor: const Color(0xFF075E4D),
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
          if (item.route.isNotEmpty) {
            context.push(item.route);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Image miniature
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 58,
                    height: 58,
                    color: const Color(0xFFF1F5F3),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
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
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.categorie,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6C7C77),
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
}
