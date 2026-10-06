import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plat_model.dart';
import '../providers/favoris_provider.dart';

/// Page Détail du Plat
class DishDetailScreen extends ConsumerStatefulWidget {
  final PlatModel? plat;

  const DishDetailScreen({super.key, this.plat});

  @override
  ConsumerState<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends ConsumerState<DishDetailScreen> {

  final List<IngredientItem> _ingredients = const [
    IngredientItem(title: 'Feuilles\nde manioc', icon: Icons.eco_rounded),
    IngredientItem(title: 'Poisson\nfumé', icon: Icons.set_meal_rounded),
    IngredientItem(title: 'Pâte\nd\'arachide', icon: Icons.grain_rounded),
    IngredientItem(title: 'Huile\nde palme', icon: Icons.water_drop_rounded),
  ];

  final List<SimilarDishItem> _similarDishes = const [
    SimilarDishItem(
      title: 'Tigadegué',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
    ),
    SimilarDishItem(
      title: 'Atieke',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=600&auto=format&fit=crop',
    ),
    SimilarDishItem(
      title: 'Fakoye',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);

    final String nomPlat = widget.plat?.nom ?? 'Sakasaka';
    final String categoriePlat = widget.plat?.regions.isNotEmpty == true
        ? 'Origine / Région : ${widget.plat!.regions.join(", ")}'
        : 'Plat traditionnel';
    final String description = widget.plat?.description ??
        'Le Sakasaka (également appelé Saka-Saka ou Saga Saga) est un plat traditionnel extrêmement populaire au Mali, ainsi que dans plusieurs pays d\'Afrique centrale et de l\'Ouest. C\'est une sauce riche, onctueuse et très savoureuse préparée à base de feuilles de manioc pilées.';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Stack(
        children: [
          // Contenu principal déroulant
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Hero du plat avec boutons Retour & Favoris
                _buildHeroImage(context, heroHeight),

                // 2. Fiche descriptive blanche
                Transform.translate(
                  offset: const Offset(0, -26),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre & badge
                        Text(
                          nomPlat,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoriePlat,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E8F76),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A5568),
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Section Ingrédients principaux
                        const Text(
                          'Ingrédients principaux',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cartes des ingrédients
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ..._ingredients.map((ing) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF9EE),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFF2E6C6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        ing.icon,
                                        color: const Color(0xFFD6A23A),
                                        size: 24,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        ing.title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6B7280),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 4),
                            // Petit bouton cœur secondaire
                            Container(
                              width: 38,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_border_rounded,
                                color: Color(0xFF0E8F76),
                                size: 20,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // Section Autres plats similaires
                        const Text(
                          'Autres plats similaire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Ligne des 3 plats similaires
                        Row(
                          children: _similarDishes.map((dish) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(13),
                                      ),
                                      child: Image.network(
                                        dish.imageUrl,
                                        height: 72,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 72,
                                                  color: const Color(
                                                    0xFFD6A23A,
                                                  ).withValues(alpha: 0.3),
                                                  child: const Icon(
                                                    Icons.fastfood_rounded,
                                                    color: Color(0xFFD6A23A),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        dish.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF075E4D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, double height) {
    return Stack(
      children: [
        // Image du plat
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E38),
            image: DecorationImage(
              image: NetworkImage(
                widget.plat?.imageUrl != null && widget.plat!.imageUrl.isNotEmpty
                    ? widget.plat!.imageUrl
                    : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Bouton Retour & Favoris en haut
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton retour
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF16332D),
                      size: 20,
                    ),
                  ),
                ),

                // Bouton Favoris (Cœur rouge réactif)
                Builder(
                  builder: (context) {
                    ref.watch(favorisNotifierProvider);
                    final String nomPlat = widget.plat?.nom ?? 'Sakasaka';
                    final String categoriePlat = widget.plat?.regions.isNotEmpty == true
                        ? 'Origine : ${widget.plat!.regions.join(", ")}'
                        : 'Plat traditionnel';
                    final isFav = ref.read(favorisNotifierProvider.notifier).isFavorite(nomPlat);

                    return InkWell(
                      onTap: () async {
                        await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                          titre: nomPlat,
                          categorie: categoriePlat,
                          imageUrl: widget.plat?.imageUrl ??
                              'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
                          route: '/dishDetail',
                          referenceId: widget.plat?.id,
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFE53935)
                              : const Color(0xFF6C7C77),
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class IngredientItem {
  final String title;
  final IconData icon;

  const IngredientItem({required this.title, required this.icon});
}

class SimilarDishItem {
  final String title;
  final String imageUrl;

  const SimilarDishItem({required this.title, required this.imageUrl});
}
