import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class GastronomieListScreen extends StatefulWidget {
  const GastronomieListScreen({super.key});

  @override
  State<GastronomieListScreen> createState() => _GastronomieListScreenState();
}

class _GastronomieListScreenState extends State<GastronomieListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  final List<DishListItem> _dishes = [
    DishListItem(
      title: 'Tiguadèguè na',
      description:
          'Sauce crémeuse à la pâte d\'arachide servie traditionnellement...',
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      isFavorite: false,
    ),
    DishListItem(
      title: 'Saka-saka',
      description:
          'Ragoût savoureux de feuilles de manioc pilées, d\'huile de palme et d...',
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=600&auto=format&fit=crop',
      isFavorite: false,
    ),
    DishListItem(
      title: 'Fakoye',
      description:
          'Sauce emblématique du Nord, préparée à base de feuilles de corèt...',
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop',
      isFavorite: false,
    ),
    DishListItem(
      title: 'Tô',
      description:
          'Pâte de mil compacte servie avec une sauce gluante au gombo ou à l\'...',
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=600&auto=format&fit=crop',
      isFavorite: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          // 1. Structure globale en colonne : En-tête vert + Fiche blanche
          Column(
            children: [
              // En-tête vert (Titre & sous-titre)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Gastronomie',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: Text(
                          'Découvrez les saveurs gourmandes et authentiques du Mali',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche contenant la liste des plats
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    child: Column(
                      children: [
                        // Barre de recherche
                        _buildSearchBar(),

                        const SizedBox(height: 18),

                        // Liste des plats
                        ..._dishes.map((dish) => _buildDishCard(dish)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8B9B95), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher une spécialité...',
                hintStyle: TextStyle(
                  color: Color(0xFF8B9B95),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(DishListItem dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation vers la page détail du plat (Sakasaka)
            context.push(AppRouter.dishDetail);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                // Image carrée du plat
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    dish.imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 76,
                      height: 76,
                      color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        color: Color(0xFF075E4D),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Titre et description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF075E4D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C7C77),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton favori
                IconButton(
                  onPressed: () {
                    setState(() {
                      dish.isFavorite = !dish.isFavorite;
                    });
                  },
                  icon: Icon(
                    dish.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: dish.isFavorite
                        ? const Color(0xFFE53935)
                        : const Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class DishListItem {
  final String title;
  final String description;
  final String imageUrl;
  bool isFavorite;

  DishListItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
  });
}
