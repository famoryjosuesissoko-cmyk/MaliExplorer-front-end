import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

/// Page d'Accueil 100% Responsive et adaptative pour toutes les tailles d'écrans.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<CategoryItem> _categories = const [
    CategoryItem(
      title: 'Lieu historique',
      icon: Icons.account_balance_rounded,
      bgColor: Color(0xFFFDF0D5),
      iconColor: AppColors.solarYellow,
    ),
    CategoryItem(
      title: 'Cultures/ Ethnies',
      icon: Icons.theater_comedy_rounded,
      bgColor: Color(0xFFD6F5EC),
      iconColor: AppColors.secondaryEmerald,
    ),
    CategoryItem(
      title: 'Gastronomies',
      icon: Icons.restaurant_rounded,
      bgColor: Color(0xFFFFE3E3),
      iconColor: Color(0xFFE65151),
    ),
    CategoryItem(
      title: 'Villes & Religions',
      icon: Icons.mosque_rounded,
      bgColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF3B82F6),
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
    final double screenHeight = screenSize.height;

    // Hauteur responsive du Hero (adaptée selon la hauteur de l'écran)
    final double heroHeight = (screenHeight * 0.36).clamp(240.0, 320.0);
    const double searchBarHeight = 52.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Contenu principal défilable
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Section avec image & barre de recherche intégrée responsive
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Image et gradient du Hero
                    _buildHeroHeader(context, heroHeight),

                    // Barre de recherche chevauchant le bas du Hero
                    Positioned(
                      bottom: -(searchBarHeight / 2),
                      left: math.max(16.0, screenWidth * 0.05),
                      right: math.max(16.0, screenWidth * 0.05),
                      child: _buildSearchBar(searchBarHeight),
                    ),
                  ],
                ),
              ),

              // Espace pour le débordement de la barre de recherche
              SliverToBoxAdapter(
                child: SizedBox(height: (searchBarHeight / 2) + 20),
              ),

              // 2. Grille responsive des 4 catégories
              SliverToBoxAdapter(child: _buildCategoriesSection(screenWidth)),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // 3. Carte de mise en avant (Tombouctou)
              SliverToBoxAdapter(
                child: _buildFeaturedCard(screenWidth, screenHeight),
              ),

              // Espace inférieur pour ne pas être caché par la barre de navigation
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),

          // 4. Barre de navigation inférieure flottante responsive
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, MediaQuery.of(context).padding.bottom + 6.0),
            child: _buildBottomNavigationBar(screenWidth),
          ),
        ],
      ),
    );
  }

  /// 1. Section Header avec image de fond & barre supérieure responsive
  Widget _buildHeroHeader(BuildContext context, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFB5703C),
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=1000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.65),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.45),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo officiel MaliExplorer
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 200.0),
                        child: Image.asset(
                          'assets/images/MaliExplorer.png',
                          height: 42,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                            Icons.explore,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: const EdgeInsets.only(bottom: 200),
                        child: Text(
                          'MaliExplorer',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1.5),
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Bouton "Se connecter"
                Padding(
                  padding: const EdgeInsets.only(bottom: 190.0),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF075E4D),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 2. Barre de recherche flottante
  Widget _buildSearchBar(double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un lieu, une recette, une region',
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
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF075E4D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Ligne responsive des 4 catégories
  Widget _buildCategoriesSection(double screenWidth) {
    final double horizontalPadding = math.max(12.0, screenWidth * 0.035);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.asMap().entries.map((entry) {
          final int index = entry.key;
          final CategoryItem cat = entry.value;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (index == 0) {
                  context.push(AppRouter.cityDetail);
                } else if (index == 1) {
                  context.push(AppRouter.ethnicityDetail);
                } else if (index == 2) {
                  context.push(AppRouter.dishDetail);
                } else {
                  context.push(AppRouter.cityDetail);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cercle d'icône
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.iconColor, size: 22),
                    ),
                    const SizedBox(height: 7),
                    // Nom avec FittedBox pour éviter tout débordement
                    SizedBox(
                      height: 28,
                      child: Center(
                        child: Text(
                          cat.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E38),
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4. Carte responsive mise en avant "Tombouctou"
  Widget _buildFeaturedCard(double screenWidth, double screenHeight) {
    final double cardHeight = (screenHeight * 0.27).clamp(190.0, 240.0);
    final double horizontalPadding = math.max(12.0, screenWidth * 0.035);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: InkWell(
        onTap: () => context.push(AppRouter.cityDetail),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: cardHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=1000&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Dégradé sombre en bas pour lisibilité
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),

              // Contenu texte
              Positioned(
                left: 18,
                bottom: 18,
                right: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Tombouctou',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Ville légendaire, patrimoine mondial',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFE0E0E0),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Bouton rond blanc avec flèche
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  width: 44,
                  height: 44,
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
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF16332D),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Barre de navigation inférieure stylisée et responsive
  Widget _buildBottomNavigationBar(double screenWidth) {
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
      }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
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

class CategoryItem {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const CategoryItem({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}