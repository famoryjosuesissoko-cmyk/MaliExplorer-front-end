import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../models/home_slide_model.dart';
import '../models/search_result_item.dart';
import '../models/ville_model.dart';
import '../providers/home_extended_providers.dart';
import '../router/app_router.dart';

/// Page d'Accueil 100% Responsive et adaptative avec Diaporama Hero 5s, Carrousel continu des Villes et Recherche Dynamique.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  // Diaporama Hero automatique
  Timer? _slideshowTimer;
  int _currentSlideIndex = 0;

  // Carrousel des villes défilement continu
  late ScrollController _cityScrollController;
  Timer? _cityAutoScrollTimer;
  bool _isCityUserScrolling = false;

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
  void initState() {
    super.initState();
    _cityScrollController = ScrollController();

    // Timer du Diaporama Hero (changement automatique toutes les 5 secondes)
    _slideshowTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final slidesAsync = ref.read(homeSlidesProvider);
      slidesAsync.whenData((slides) {
        if (slides.isNotEmpty && mounted) {
          setState(() {
            _currentSlideIndex = (_currentSlideIndex + 1) % slides.length;
          });
        }
      });
    });

    // Défilement automatique continu du carrousel des villes
    _startCityAutoScroll();
  }

  void _startCityAutoScroll() {
    _cityAutoScrollTimer?.cancel();
    _cityAutoScrollTimer = Timer.periodic(const Duration(milliseconds: 40), (
      _,
    ) {
      if (!mounted ||
          _isCityUserScrolling ||
          !_cityScrollController.hasClients) {
        return;
      }
      final maxScroll = _cityScrollController.position.maxScrollExtent;
      final currentScroll = _cityScrollController.offset;
      if (currentScroll >= maxScroll - 2) {
        _cityScrollController.jumpTo(0);
      } else {
        _cityScrollController.jumpTo(currentScroll + 1.2);
      }
    });
  }

  @override
  void dispose() {
    _slideshowTimer?.cancel();
    _cityAutoScrollTimer?.cancel();
    _cityScrollController.dispose();
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(homeSearchQueryProvider.notifier).state = val.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double heroHeight = (screenHeight * 0.32).clamp(220.0, 280.0);
    const double searchBarHeight = 52.0;
    final double searchBarHalf = searchBarHeight / 2;
    final double fixedHeaderTotalHeight = heroHeight + searchBarHalf;

    final searchQuery = ref.watch(homeSearchQueryProvider);
    final searchResultsAsync = ref.watch(globalSearchResultsProvider);
    final isSearching = searchQuery.length >= 2;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFF7F8F5),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Contenu principal défilant sous l'en-tête et la barre de recherche
          Positioned.fill(
            child: RefreshIndicator(
              color: const Color(0xFF075E4D),
              backgroundColor: Colors.white,
              edgeOffset: fixedHeaderTotalHeight,
              onRefresh: () async {
                ref.invalidate(homeSlidesProvider);
                ref.invalidate(homeVillesProvider);
                ref.invalidate(religionsProvider);
                try {
                  await Future.wait([
                    ref.read(homeSlidesProvider.future),
                    ref.read(homeVillesProvider.future),
                  ]);
                } catch (_) {}
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  top: fixedHeaderTotalHeight + 16,
                  bottom: 110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Grille responsive des 4 catégories
                    _buildCategoriesSection(screenWidth, isDark),

                    const SizedBox(height: 22),

                    // Section Villes : Carrousel horizontal continu et fluide
                    _buildContinuousCitiesCarousel(
                      screenWidth,
                      screenHeight,
                      isDark,
                    ),

                    const SizedBox(height: 18),

                    // Bannière interactive du Quiz Culturel
                    _buildQuizBanner(screenWidth, isDark),
                  ],
                ),
              ),
            ),
          ),

          // 2. En-tête Hero & Barre de recherche FIXES au sommet
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: fixedHeaderTotalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight,
                  child: _buildHeroSlideshow(context, heroHeight),
                ),

                Positioned(
                  top: heroHeight - searchBarHalf,
                  left: math.max(16.0, screenWidth * 0.05),
                  right: math.max(16.0, screenWidth * 0.05),
                  child: _buildSearchBar(searchBarHeight, isDark),
                ),
              ],
            ),
          ),

          // 3. Overlay moderne de suggestions de recherche dynamique
          if (isSearching)
            Positioned(
              top: fixedHeaderTotalHeight + 6,
              left: math.max(16.0, screenWidth * 0.05),
              right: math.max(16.0, screenWidth * 0.05),
              bottom: 20,
              child: _buildSearchSuggestionsOverlay(searchResultsAsync, isDark),
            ),
        ],
      ),
    );
  }

  /// 1. Diaporama Hero automatique avec transition en fondu de 5 secondes
  Widget _buildHeroSlideshow(BuildContext context, double height) {
    final slidesAsync = ref.watch(homeSlidesProvider);

    return slidesAsync.when(
      data: (slides) {
        final slideList = slides.isNotEmpty
            ? slides
            : HomeSlideModel.defaultSlides;
        final currentSlide = slideList[_currentSlideIndex % slideList.length];

        return Container(
          height: height,
          width: double.infinity,
          color: const Color(0xFFB5703C),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image animée avec AnimatedSwitcher pour un fondu fluide
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 900),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: KeyedSubtree(
                  key: ValueKey<String>(
                    '${currentSlide.id}_${currentSlide.imageUrl}',
                  ),
                  child: _buildSlideImage(currentSlide.imageUrl),
                ),
              ),

              // Dégradé sombre pour préserver la lisibilité parfaite de l'en-tête
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.60),
                    ],
                  ),
                ),
              ),

              // Barre supérieure (Logo MaliExplorer + Bouton Authentification)
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/MaliExplorer.png',
                                height: 42,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
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
                        _buildAuthButton(context),
                      ],
                    ),
                  ),
                ),
              ),

              // Indicateur discret de pagination du diaporama
              Positioned(
                left: 16,
                bottom: 34,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Points indicateurs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(slideList.length, (idx) {
                        final isActive =
                            idx == (_currentSlideIndex % slideList.length);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: isActive ? 16 : 6,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFD6A23A)
                                : Colors.white60,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: height,
        color: const Color(0xFFB5703C),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (_, _) => _buildHeroStaticFallback(context, height),
    );
  }

  Widget _buildSlideImage(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/home_hero.jpeg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    if (trimmed.startsWith('/')) {
      return Image.network(
        '${ApiConstants.baseUrl}$trimmed',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/home_hero.jpeg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Image.asset(
      trimmed,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => Container(color: const Color(0xFFB5703C)),
    );
  }

  Widget _buildHeroStaticFallback(BuildContext context, double height) {
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
    );
  }

  Widget _buildAuthButton(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final bool isLoggedIn = snapshot.hasData && snapshot.data != null;
        if (isLoggedIn) {
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
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 18,
              ),
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
            Text(
              'Déconnexion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de MaliExplorer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF6C7C77)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

  /// 2. Barre de recherche flottante dynamique avec debounce & bouton d'effacement
  Widget _buildSearchBar(double height, bool isDark) {
    final query = ref.watch(homeSearchQueryProvider);

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
          const Icon(Icons.search_rounded, color: Color(0xFF8B9B95), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : const Color(0xFF16332D),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher une ville, région, religion, recette...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF8B9B95),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (query.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchFocusNode.unfocus();
                ref.read(homeSearchQueryProvider.notifier).state = '';
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFF6C7C77),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Overlay de suggestions sous la barre de recherche
  Widget _buildSearchSuggestionsOverlay(
    AsyncValue<List<SearchResultItem>> searchResultsAsync,
    bool isDark,
  ) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : const Color(0xFF075E4D).withValues(alpha: 0.15),
          ),
        ),
        child: searchResultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Aucun résultat correspondant',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF6C7C77),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: isDark
                    ? AppColors.darkBorder
                    : Colors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final item = results[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                      child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? (item.imageUrl!.startsWith('assets/')
                              ? Image.asset(
                                  item.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _getCategoryIcon(item.categorie),
                                )
                              : Image.network(
                                  ApiConstants.resolveImageUrl(item.imageUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _getCategoryIcon(item.categorie),
                                ))
                          : _getCategoryIcon(item.categorie),
                    ),
                  ),
                  title: Text(
                    item.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF16332D),
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.categorie,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                      ),
                      if (item.sousTitre != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.sousTitre!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B9B95),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF8B9B95),
                  ),
                  onTap: () {
                    _searchFocusNode.unfocus();
                    ref.read(homeSearchQueryProvider.notifier).state = '';
                    _searchController.clear();
                    context.push(item.route, extra: item);
                  },
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF075E4D),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Recherche en cours...',
                    style: TextStyle(color: Color(0xFF6C7C77)),
                  ),
                ],
              ),
            ),
          ),
          error: (_, _) => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Une erreur est survenue lors de la recherche.',
                style: TextStyle(color: Color(0xFFE53935), fontSize: 13),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String cat) {
    IconData icon = Icons.explore;
    if (cat.contains('Ville')) icon = Icons.location_city_rounded;
    if (cat.contains('Région')) icon = Icons.map_rounded;
    if (cat.contains('Lieu')) icon = Icons.account_balance_rounded;
    if (cat.contains('Gastro')) icon = Icons.restaurant_rounded;
    if (cat.contains('Ethnie')) icon = Icons.groups_rounded;
    if (cat.contains('Religion')) icon = Icons.mosque_rounded;
    if (cat.contains('Président')) icon = Icons.history_edu_rounded;
    if (cat.contains('Guide')) icon = Icons.person_pin_circle_rounded;
    return Icon(icon, color: const Color(0xFF075E4D), size: 24);
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
                  // Clic sur "Villes & Religions" -> ouvre le nouveau module Religions
                  context.push(AppRouter.religionsList);
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
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.04,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : cat.bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.iconColor, size: 25),
                    ),
                    const SizedBox(height: 7),
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
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF2C3E38),
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

  /// 4. Carrousel continu et fluide des Villes
  Widget _buildContinuousCitiesCarousel(
    double screenWidth,
    double screenHeight,
    bool isDark,
  ) {
    final double cardHeight = (screenHeight * 0.27).clamp(190.0, 240.0);
    final double horizontalPadding = math.max(12.0, screenWidth * 0.035);
    final villesAsync = ref.watch(homeVillesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Villes du Mali',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF16332D),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRouter.villesList),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        villesAsync.when(
          data: (villes) {
            final cityList = villes.isNotEmpty
                ? villes
                : _getStaticDefaultCities();
            // Création d'une liste multipliée pour boucle continue sans accroc
            final infiniteCities = [...cityList, ...cityList, ...cityList];

            return SizedBox(
              height: cardHeight,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification) {
                    _isCityUserScrolling = true;
                  } else if (notification is ScrollEndNotification) {
                    _isCityUserScrolling = false;
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _cityScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  itemCount: infiniteCities.length,
                  itemBuilder: (context, index) {
                    final ville = infiniteCities[index];
                    return _buildCityCard(ville, cardHeight, isDark);
                  },
                ),
              ),
            );
          },
          loading: () => SizedBox(
            height: cardHeight,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF075E4D)),
            ),
          ),
          error: (_, _) => SizedBox(
            height: cardHeight,
            child: _buildStaticFallbackCityCard(cardHeight, horizontalPadding),
          ),
        ),
      ],
    );
  }

  Widget _buildCityCard(VilleModel ville, double cardHeight, bool isDark) {
    const double cardWidth = 270.0;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: () => context.push(AppRouter.cityDetail, extra: ville),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildCityImage(ville.displayPhoto),
                // Dégradé sombre en bas
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.82),
                      ],
                    ),
                  ),
                ),

                // Contenu texte
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ville.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ville.description.isNotEmpty
                            ? ville.description
                            : 'Ville historique, joyau culturel du Mali',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFE0E0E0),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bouton rond flèche
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Container(
                    width: 40,
                    height: 40,
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
                      size: 20,
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

  Widget _buildCityImage(String photo) {
    final trimmed = photo.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/home_tombouctou.jpeg',
          fit: BoxFit.cover,
        ),
      );
    }
    if (trimmed.startsWith('/')) {
      return Image.network(
        '${ApiConstants.baseUrl}$trimmed',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/home_tombouctou.jpeg',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      trimmed,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(color: const Color(0xFF075E4D)),
    );
  }

  Widget _buildStaticFallbackCityCard(
    double cardHeight,
    double horizontalPadding,
  ) {
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
            image: const DecorationImage(
              image: AssetImage('assets/images/home_tombouctou.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  List<VilleModel> _getStaticDefaultCities() {
    return const [
      VilleModel(
        id: 1,
        nom: 'Tombouctou',
        region: 'Région de Tombouctou',
        description:
            'Cité mystérieuse des 333 saints et patrimoine mondial de l\'humanité.',
        imageUrl: 'assets/images/home_tombouctou.jpeg',
      ),
      VilleModel(
        id: 2,
        nom: 'Djenné',
        region: 'Région de Mopti',
        description:
            'Cité millénaire réputée pour sa majestueuse Grande Mosquée en terre crue.',
        imageUrl: 'assets/images/djenne_cover.jpeg',
      ),
      VilleModel(
        id: 3,
        nom: 'Ségou',
        region: 'Région de Ségou',
        description:
            'Cité des balanzans, capitale historique du fier royaume Bambara.',
        imageUrl: 'assets/images/segou_cover.jpg',
      ),
      VilleModel(
        id: 4,
        nom: 'Mopti',
        region: 'Région de Mopti',
        description:
            'La "Venise du Mali", port fluvial et grand carrefour des cultures fluviales.',
        imageUrl: 'assets/images/mopti_cover.jpg',
      ),
      VilleModel(
        id: 5,
        nom: 'Bamako',
        region: 'District de Bamako',
        description:
            'Capitale vibrante sur les rives du fleuve Niger, cœur économique et artistique.',
        imageUrl: 'assets/images/bamako_cover.jpeg',
      ),
      VilleModel(
        id: 6,
        nom: 'Sikasso',
        region: 'Région de Sikasso',
        description:
            'Capitale du Kénédougou, grenier verdoyant et verger nourricier du Mali.',
        imageUrl: 'assets/images/sikasso_cover.jpeg',
      ),
    ];
  }

  /// 5. Bannière interactive du Quiz Culturel
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
                color: isDark
                    ? const Color(0xFF332A15)
                    : const Color(0xFFFEF3C7),
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF16332D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Testez vos connaissances et gagnez des badges Bambara !',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF6C7C77),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Jouer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
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
