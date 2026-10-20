import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/explorer_publication_model.dart';
import '../providers/explorer_provider.dart';
import '../router/app_router.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {
      'titre': 'Villes & Régions',
      'sousTitre': '6 cités historiques et leurs merveilles',
      'route': AppRouter.villesList,
      'image': 'assets/images/explorer_villes_regions.jpeg',
      'badge': '6 Villes',
      'icon': Icons.location_city_rounded,
    },
    {
      'titre': 'Gastronomie Malienne',
      'sousTitre': 'Tigadèguèna, Fakoye, Tô et délices',
      'route': AppRouter.gastronomieList,
      'image': 'assets/images/explorer_gastronomie.jpeg',
      'badge': 'Plats Typiques',
      'icon': Icons.restaurant_menu_rounded,
    },
    {
      'titre': 'Ethnies & Traditions',
      'sousTitre': 'Bambara, Dogon, Peul, Soninké, Touareg',
      'route': AppRouter.ethniesList,
      'image': 'assets/images/explorer_ethnies_traditions.jpeg',
      'badge': '6 Peuples',
      'icon': Icons.groups_rounded,
    },
    {
      'titre': 'Chefs d\'État & Histoire',
      'sousTitre': 'Figures républicaines depuis 1960',
      'route': AppRouter.chefsEtat,
      'image': 'assets/images/explorer_chefs_etat.jpeg',
      'badge': 'Histoire',
      'icon': Icons.history_edu_rounded,
    },
    {
      'titre': 'Guides Touristiques',
      'sousTitre': 'Professionnels locaux certifiés',
      'route': AppRouter.guides,
      'image': 'assets/images/explorer_guides.jpeg',
      'badge': 'Accompagnement',
      'icon': Icons.person_pin_circle_rounded,
    },
    {
      'titre': 'Langues Nationales & Lexique',
      'sousTitre': 'Bamanankan, Fulfulde, Songhaï, Soninké, Tamasheq',
      'route': AppRouter.languesNationales,
      'image': 'assets/images/Languages of the World_ Flags and Knowledge.png',
      'badge': 'Lexique',
      'icon': Icons.record_voice_over_rounded,
    },
    {
      'titre': 'Infos Pratiques Voyageurs',
      'sousTitre': 'Visas, santé, devises, saisons & urgences',
      'route': AppRouter.infosPratiques,
      'image': 'assets/images/passport couverture.jpeg',
      'badge': 'Guide Voyage',
      'icon': Icons.info_outline_rounded,
    },
    {
      'titre': 'Religions & Spiritualités',
      'sousTitre': 'Islam, Christianisme, Animisme & Concorde',
      'route': AppRouter.religionsList,
      'image': 'assets/images/Religion at Golden Sunrise.png',
      'badge': 'Religions',
      'icon': Icons.mosque_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val.trim());
    ref.read(explorerSearchQueryProvider.notifier).state = val.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentFilter = ref.watch(explorerFilterTypeProvider);
    final publications = ref.watch(filteredExplorerPublicationsProvider);

    // Filtrer les catégories patrimoine statiques si recherche
    final filteredCategories = _categories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (cat['titre'] as String).toLowerCase().contains(q) ||
          (cat['sousTitre'] as String).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundSecondary
          : const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert avec barre de recherche et filtres thématiques
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EXPLORER',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFF2B544),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Validé & Certifié',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Barre de recherche
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark
                          ? Border.all(color: AppColors.darkBorder)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.20 : 0.08,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF16332D),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Rechercher villes, plats, créations, festivals...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.darkTextDisabled
                              : const Color(0xFF8B9B95),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark
                              ? const Color(0xFF4DB6AC)
                              : const Color(0xFF075E4D),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : const Color(0xFF6C7C77),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Onglets / Chips de sélection (Tous, Produits, Festivals, Patrimoine)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'tous',
                          'Tout',
                          Icons.dashboard_rounded,
                          currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'festivals',
                          'Festivals & Événements',
                          Icons.festival_rounded,
                          currentFilter,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'patrimoine',
                          'Patrimoine Culturel',
                          Icons.account_balance_rounded,
                          currentFilter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiche contenant le flux de découverte
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: RefreshIndicator(
                color: const Color(0xFF075E4D),
                onRefresh: () => ref
                    .read(explorerPublicationsProvider.notifier)
                    .chargerPublications(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                  children: [
                    // Si 'patrimoine' ou 'tous', afficher le patrimoine
                    if (currentFilter == 'patrimoine' ||
                        currentFilter == 'tous') ...[
                      if (currentFilter == 'tous' &&
                          filteredCategories.isNotEmpty)
                        _buildSectionHeader(
                          'Patrimoine & Histoire',
                          'Découvrez les trésors du Mali',
                          isDark,
                        ),
                      ...filteredCategories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildCategoryCard(cat, isDark),
                        ),
                      ),
                    ],

                    // Si recherche active et aucun résultat dans les catégories ni les publications
                    if (_searchQuery.isNotEmpty &&
                        filteredCategories.isEmpty &&
                        publications.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun résultat pour "$_searchQuery"',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                label: const Text('Effacer la recherche'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF075E4D),
                                  side: const BorderSide(
                                    color: Color(0xFF075E4D),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Si 'tous' ou 'festivals', afficher les publications validées
                    if (currentFilter != 'patrimoine') ...[
                      if (currentFilter == 'tous' &&
                          publications.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildSectionHeader(
                          'Événements Culturels Validés',
                          'Par nos Promoteurs et Partenaires culturels',
                          isDark,
                        ),
                      ],

                      if (publications.isEmpty && currentFilter != 'tous')
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 54,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aucun contenu validé pour le moment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Seules les publications approuvées sont visibles.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...publications.map(
                          (pub) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildPublicationCard(pub, isDark),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String filterKey,
    String label,
    IconData icon,
    String activeFilter,
  ) {
    final isSelected = activeFilter == filterKey;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(explorerFilterTypeProvider.notifier).state = filterKey;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? const Color(0xFF075E4D) : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF075E4D) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF6C7C77),
            ),
          ),
        ],
      ),
    );
  }

  /// Carte pour les catégories statiques (Villes, Plats, Ethnies, Présidents, etc.)
  Widget _buildCategoryCard(Map<String, dynamic> cat, bool isDark) {
    final String targetRoute = cat['route'] as String;
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => context.push(targetRoute),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 115,
                  height: 110,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      (cat['image'] as String).startsWith('assets/')
                          ? Image.asset(
                              cat['image'] as String,
                              width: 115,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) =>
                                  Container(
                                    width: 115,
                                    height: 110,
                                    color: const Color(0xFF075E4D),
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      color: Colors.white70,
                                      size: 36,
                                    ),
                                  ),
                            )
                          : Image.network(
                              cat['image'] as String,
                              width: 115,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) =>
                                  Container(
                                    width: 115,
                                    height: 110,
                                    color: const Color(0xFF075E4D),
                                    child: Icon(
                                      cat['icon'] as IconData,
                                      color: Colors.white70,
                                      size: 36,
                                    ),
                                  ),
                            ),
                      Container(color: Colors.black.withValues(alpha: 0.15)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceElevated
                              : const Color(0xFF075E4D).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          cat['badge'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF4DB6AC)
                                : const Color(0xFF075E4D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        cat['titre'] as String,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF16332D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat['sousTitre'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF6C7C77),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF8B9B95),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte dynamique pour les événements et festivals culturels
  Widget _buildPublicationCard(ExplorerPublicationModel pub, bool isDark) {
    final isFestival = pub.type == PublicationType.festivalEvenement;

    return Container(
      height: 125,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Incrémentation idempotente de vue
            ref
                .read(explorerPublicationsProvider.notifier)
                .incrementerView(pub.id);
            _showPublicationDetailsModal(context, pub, isDark);
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Image de la publication
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 120,
                  height: 125,
                  child: _buildSafePublicationImage(pub.imageUrl),
                ),
              ),

              // Contenu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badges (Type & Prix / Date)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE65100,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isFestival ? 'Festival' : 'Patrimoine',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (pub.prix != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pub.prix!,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          else if (pub.date != null)
                            Text(
                              pub.date!,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : const Color(0xFF6C7C77),
                              ),
                            ),
                        ],
                      ),

                      // Titre
                      Text(
                        pub.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF16332D),
                        ),
                      ),

                      // Auteur & Localisation
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : const Color(0xFF6C7C77),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${pub.auteur} • ${pub.localisation}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : const Color(0xFF6C7C77),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Statistiques vues & commentaires
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 13,
                            color: Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pub.vues} vues',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 12,
                            color: Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pub.commentaires} avis',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFF075E4D).withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.festival_rounded, color: Color(0xFF075E4D), size: 32),
      ),
    );
  }

  Widget _buildSafePublicationImage(String imageUrl) {
    final clean = imageUrl.trim();
    if (clean.isEmpty) {
      return _buildImageFallback();
    }
    if (clean.startsWith('assets/')) {
      return Image.asset(
        clean,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }
    return _buildImageFallback();
  }

  void _showPublicationDetailsModal(
    BuildContext context,
    ExplorerPublicationModel pub,
    bool isDark,
  ) {
    final isFestival = pub.type == PublicationType.festivalEvenement;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: _buildSafePublicationImage(pub.imageUrl),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE65100,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isFestival ? 'Événement Culturel' : 'Patrimoine',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                          if (pub.prix != null)
                            Text(
                              pub.prix!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E7D32),
                              ),
                            )
                          else if (pub.date != null)
                            Text(
                              pub.date!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pub.titre,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF16332D),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Par ${pub.auteur} • ${pub.localisation}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : const Color(0xFF6C7C77),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        pub.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : const Color(0xFF2A3D36),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 15,
                            color: Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pub.vues} vues',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.chat_bubble_rounded,
                            size: 14,
                            color: Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pub.commentaires} commentaires',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _handleInscriptionEvenement(pub);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF075E4D),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: const Text(
                    'S\'inscrire à l\'Événement',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleInscriptionEvenement(ExplorerPublicationModel pub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (dlgCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_rounded,
                color: Color(0xFFE65100),
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Confirmer l\'inscription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : const Color(0xFF16332D),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voulez-vous réserver votre accès à :',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : const Color(0xFF6C7C77),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pub.titre,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : const Color(0xFF075E4D),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: Color(0xFFE65100),
                ),
                const SizedBox(width: 4),
                Text(
                  pub.date ?? 'Date à venir',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Color(0xFF6C7C77),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    pub.localisation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF6C7C77),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tarif : ${pub.prix ?? "Accès Libre"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dlgCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Votre réservation pour "${pub.titre}" est confirmée !',
                  ),
                  backgroundColor: const Color(0xFF075E4D),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E4D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
