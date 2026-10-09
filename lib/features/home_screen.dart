import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Hauteur responsive du Hero (adaptée selon la hauteur de l'écran)
    final double heroHeight = (screenHeight * 0.36).clamp(240.0, 320.0);
    const double searchBarHeight = 52.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
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
                      child: _buildSearchBar(searchBarHeight, isDark),
                    ),
                  ],
                ),
              ),

              // Espace pour le débordement de la barre de recherche
              SliverToBoxAdapter(
                child: SizedBox(height: (searchBarHeight / 2) + 20),
              ),

              // 2. Grille responsive des 4 catégories
              SliverToBoxAdapter(child: _buildCategoriesSection(screenWidth, isDark)),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // 3. Carte de mise en avant (Tombouctou)
              SliverToBoxAdapter(
                child: _buildFeaturedCard(screenWidth, screenHeight),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // 4. Bannière interactive du Quiz Culturel
              SliverToBoxAdapter(
                child: _buildQuizBanner(screenWidth, isDark),
              ),

              // Espace inférieur pour ne pas être caché par la barre de navigation
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
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
          image: AssetImage('assets/images/home_hero.jpeg'),
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
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo officiel MaliExplorer & Titre remontés vers le haut
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
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
                      const SizedBox(width: 8),
                      const Text(
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
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Bouton Dynamique d'Authentification (Se connecter / Se déconnecter)
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    final bool isLoggedIn = snapshot.hasData && snapshot.data != null;

                    if (isLoggedIn) {
                      // Utilisateur Connecté : Bouton Rouge "Se déconnecter" avec icône
                      return Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmSignOut(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                          label: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }

                    // Utilisateur Non-Connecté : Bouton Vert "Se connecter" standard
                    return Container(
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
                        onPressed: () => context.push(AppRouter.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Déconnexion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter de MaliExplorer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6C7C77))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion réussie.'),
                    backgroundColor: Color(0xFF075E4D),
                  ),
                );
              }
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  /// 2. Barre de recherche flottante
  Widget _buildSearchBar(double height, bool isDark) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
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
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un lieu, une recette, une région...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8B9B95),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF075E4D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Ligne responsive des 4 catégories
  Widget _buildCategoriesSection(double screenWidth, bool isDark) {
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
                  context.push(AppRouter.villesList);
                } else if (index == 1) {
                  context.push(AppRouter.ethniesList);
                } else if (index == 2) {
                  context.push(AppRouter.gastronomieList);
                } else {
                  context.push(AppRouter.villesList);
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
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cercle d'icône
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : cat.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.iconColor, size: 25),
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
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2C3E38),
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

  /// 4. Bannière interactive du Quiz Culturel
  Widget _buildQuizBanner(double screenWidth, bool isDark) {
    final double horizontalPadding = math.max(12.0, screenWidth * 0.035);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF332A15) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.solarYellow,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz & Culture Malienne',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Testez vos connaissances et gagnez des badges Bambara !',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.quizList),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                elevation: 0,
              ),
              child: const Text('Jouer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ],
        ),
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
              image: AssetImage('assets/images/home_tombouctou.jpeg'),
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