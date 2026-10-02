import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

/// Page Détail du Plat (Exemple : Sakasaka)
class DishDetailScreen extends StatefulWidget {
  const DishDetailScreen({super.key});

  @override
  State<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends State<DishDetailScreen> {
  bool _isFavorite = true;
  int _selectedNavIndex = 0;

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
                        const Text(
                          'Sakasaka',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Plat traditionnel',
                          style: TextStyle(
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
                        const Text(
                          'Le Sakasaka (également appelé Saka-Saka ou Saga Saga) est un plat traditionnel extrêmement populaire au Mali, ainsi que dans plusieurs pays d\'Afrique centrale et de l\'Ouest. C\'est une sauce riche, onctueuse et très savoureuse préparée à base de feuilles de manioc pilées.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A5568),
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Section Ingrédients principaux
                        Row(
                          children: const [
                            Icon(
                              Icons.restaurant_menu_rounded,
                              color: Color(0xFFD6A23A),
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ingrédients principaux',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                          ],
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

          // 3. Barre de navigation inférieure flottante
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, MediaQuery.of(context).padding.bottom + 6.0),
            child: _buildBottomNavigationBar(),
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
          decoration: const BoxDecoration(
            color: Color(0xFF2C3E38),
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
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

                // Bouton Favoris (Cœur rouge)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
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
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite
                          ? const Color(0xFFE53935)
                          : const Color(0xFF6C7C77),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            Icons.home_rounded,
            'Accueil',
            isSelected: _selectedNavIndex == 0,
            onTap: () => context.go(AppRouter.home),
          ),
          _buildNavItem(
            1,
            Icons.menu_book_rounded,
            'Carte',
            isSelected: _selectedNavIndex == 1,
          ),
          _buildNavItem(
            2,
            Icons.explore_outlined,
            'Découvrir',
            isSelected: _selectedNavIndex == 2,
          ),
          _buildNavItem(
            3,
            Icons.help_outline_rounded,
            'Quiz',
            isSelected: _selectedNavIndex == 3,
          ),
          _buildNavItem(
            4,
            Icons.person_outline_rounded,
            'Profil',
            isSelected: _selectedNavIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF075E4D),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              )
            else
              Icon(icon, color: const Color(0xFF6C7C77), size: 22),
            const SizedBox(height: 2.5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF075E4D)
                      : const Color(0xFF6C7C77),
                ),
              ),
            ),
          ],
        ),
      ),
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
