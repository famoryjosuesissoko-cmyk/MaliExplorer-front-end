import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../models/explorer_publication_model.dart';
import '../providers/explorer_provider.dart';
import '../router/app_router.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  static void showMesBilletsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _MesBilletsSheet(),
    );
  }

  static void showDigitalTicketModal(
    BuildContext context,
    Map<String, dynamic> ticket,
  ) {
    showDialog(
      context: context,
      builder: (dctx) => _DigitalTicketDialog(ticket: ticket),
    );
  }

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
      'image': 'assets/images/Mali’s Languages, Our Heritage.png',
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
      'image': 'assets/images/religion_cover.jpeg',
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
    final publicationsAsync = ref.watch(filteredExplorerPublicationsProvider);

    // Filtrer les catégories patrimoine statiques si recherche
    final filteredCategories = _categories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (cat['titre'] as String).toLowerCase().contains(q) ||
          (cat['sousTitre'] as String).toLowerCase().contains(q);
    }).toList();

    final hasNoPubs = publicationsAsync.maybeWhen(
      data: (pubs) => pubs.isEmpty,
      orElse: () => false,
    );

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
                      const Expanded(
                        child: Text(
                          'EXPLORER',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () =>
                                ExplorerScreen.showMesBilletsModal(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6A23A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Mes billets',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
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
                                  size: 15,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Certifié',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        hasNoPubs)
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
                      publicationsAsync.when(
                        loading: () => _buildEventsLoading(
                          isDark,
                          isCompact: currentFilter == 'tous',
                        ),
                        error: (err, stack) => _buildEventsError(err, isDark),
                        data: (pubs) {
                          if (pubs.isEmpty) {
                            if (_searchQuery.isNotEmpty) {
                              return const SizedBox.shrink();
                            }
                            return _buildEventsEmpty(
                              isDark,
                              isCompact: currentFilter == 'tous',
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentFilter == 'tous') ...[
                                const SizedBox(height: 12),
                                _buildSectionHeader(
                                  'Événements Culturels Validés',
                                  'Par nos Promoteurs et Partenaires culturels',
                                  isDark,
                                ),
                              ],
                              ...pubs.map(
                                (pub) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildPublicationCard(pub, isDark),
                                ),
                              ),
                            ],
                          );
                        },
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

  Widget _buildEventsLoading(bool isDark, {bool isCompact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isCompact ? 24 : 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFF075E4D),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Chargement des événements...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : const Color(0xFF6C7C77),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsError(Object error, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.redAccent.withValues(alpha: 0.3)
                  : Colors.red.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Événements temporairement indisponibles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF16332D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Impossible de joindre le serveur. Vérifiez votre connexion.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(explorerPublicationsProvider.notifier)
                      .chargerPublications();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075E4D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
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
    );
  }

  Widget _buildEventsEmpty(bool isDark, {bool isCompact = false}) {
    if (isCompact) {
      return Container(
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : const Color(0xFF075E4D).withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Color(0xFF075E4D),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aucun événement publié pour le moment.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF16332D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Les prochains festivals validés apparaîtront ici dès leur publication.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 54,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun événement publié pour le moment.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'De nouveaux festivals et événements culturels validés seront bientôt publiés.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
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
      constraints: const BoxConstraints(minHeight: 110),
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: SizedBox(
                  width: 115,
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
                    vertical: 10,
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
    int quantite = 1;
    String canalChoisi = 'ORANGE_MONEY'; // ORANGE_MONEY, WAVE, MASTERCARD
    final String rawPrix = (pub.prix ?? 'Gratuit').trim();
    final num prixUnitaire = rawPrix.toLowerCase().contains('gratuit')
        ? 0.0
        : (double.tryParse(rawPrix.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0);
    bool isSubmitting = false;

    final String dateDebut =
        (pub.dateDebut != null && pub.dateDebut!.isNotEmpty)
        ? pub.dateDebut!
        : (pub.date != null && pub.date!.isNotEmpty
              ? pub.date!
              : 'Date à confirmer');
    final String heureDebut =
        (pub.heureDebut != null && pub.heureDebut!.isNotEmpty)
        ? pub.heureDebut!
        : '09:00';
    final String dateFin = (pub.dateFin != null && pub.dateFin!.isNotEmpty)
        ? pub.dateFin!
        : dateDebut;
    final String heureFin = (pub.heureFin != null && pub.heureFin!.isNotEmpty)
        ? pub.heureFin!
        : '18:00';
    final String lieuEvt = pub.localisation.isNotEmpty
        ? pub.localisation
        : 'Mali';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final total = prixUnitaire * quantite;
          final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom > 0
              ? MediaQuery.of(ctx).viewInsets.bottom + 24
              : MediaQuery.of(ctx).padding.bottom + 40;
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: bottomPadding,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFD6A23A,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_rounded,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Réservation de Billets',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16332D),
                              ),
                            ),
                            Text(
                              'Mode test (aucun débit bancaire réel)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6C7C77),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Récapitulatif complet de l'événement avant achat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pub.titre,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Color(0xFF075E4D),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Début : $dateDebut à $heureDebut',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              size: 14,
                              color: Color(0xFF075E4D),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Fin : $dateFin à $heureFin',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              size: 14,
                              color: Color(0xFFD6A23A),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Lieu : $lieuEvt',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.sell_rounded,
                              size: 14,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              prixUnitaire <= 0
                                  ? 'Prix unitaire : Gratuit (0 FCFA)'
                                  : 'Prix unitaire : ${prixUnitaire.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Sélecteur de quantité
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quantité sélectionnée :',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantite > 1
                                ? () => setModalState(() => quantite--)
                                : null,
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                            color: const Color(0xFF075E4D),
                          ),
                          Text(
                            '$quantite',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: quantite < 10
                                ? () => setModalState(() => quantite++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: const Color(0xFF075E4D),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Moyen de paiement :',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCanalPaiementOption(
                          label: 'Orange Money',
                          canal: 'ORANGE_MONEY',
                          assetPath:
                              'assets/images/orange_money Brand Card.png',
                          color: const Color(0xFFFF6600),
                          selected: canalChoisi == 'ORANGE_MONEY',
                          onTap: () =>
                              setModalState(() => canalChoisi = 'ORANGE_MONEY'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanalPaiementOption(
                          label: 'Wave',
                          canal: 'WAVE',
                          assetPath: 'assets/images/wave.png',
                          color: const Color(0xFF1EA1F2),
                          selected: canalChoisi == 'WAVE',
                          onTap: () =>
                              setModalState(() => canalChoisi = 'WAVE'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCanalPaiementOption(
                          label: 'Mastercard',
                          canal: 'MASTERCARD',
                          assetPath: 'assets/images/mastercard 1990 logo.jpeg',
                          color: const Color(0xFFEB001B),
                          selected: canalChoisi == 'MASTERCARD',
                          onTap: () =>
                              setModalState(() => canalChoisi = 'MASTERCARD'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant total :',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16332D),
                          ),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              try {
                                final int idEvt = int.tryParse(pub.id) ?? 0;
                                final res = await ApiService().post(
                                  '/evenements/${pub.id}/billets/simuler-achat',
                                  body: {
                                    'idEvenement': idEvt > 0 ? idEvt : pub.id,
                                    'quantite': quantite,
                                    'canalPaiement': canalChoisi,
                                  },
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (res.statusCode == 201 ||
                                    res.statusCode == 200) {
                                  final body = Map<String, dynamic>.from(
                                    jsonDecode(utf8.decode(res.bodyBytes))
                                        as Map,
                                  );
                                  if (mounted) {
                                    ExplorerScreen.showDigitalTicketModal(
                                      context,
                                      body,
                                    );
                                  }
                                } else if (res.statusCode == 401 ||
                                    res.statusCode == 403) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Veuillez vous connecter pour réserver un billet.',
                                        ),
                                        backgroundColor: Color(0xFFDC2626),
                                      ),
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur lors de la réservation (${res.statusCode}).',
                                        ),
                                        backgroundColor: const Color(
                                          0xFFDC2626,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Impossible de joindre le serveur : $e',
                                      ),
                                      backgroundColor: const Color(0xFFDC2626),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirmer la commande',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCanalPaiementOption({
    required String label,
    required String canal,
    required String assetPath,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.withValues(alpha: 0.25),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                assetPath,
                height: 32,
                width: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.payment_rounded, color: color, size: 24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                color: selected ? color : const Color(0xFF16332D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MesBilletsSheet extends StatefulWidget {
  const _MesBilletsSheet();

  @override
  State<_MesBilletsSheet> createState() => _MesBilletsSheetState();
}

class _MesBilletsSheetState extends State<_MesBilletsSheet> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _billets = [];

  @override
  void initState() {
    super.initState();
    _loadBillets();
  }

  Future<void> _loadBillets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService().get('/evenements/billets/mes-billets');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is List && mounted) {
          setState(() {
            _billets = decoded
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            _loading = false;
          });
          return;
        }
      } else if (res.statusCode == 401 || res.statusCode == 403) {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Connectez-vous pour retrouver vos billets réservés.';
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Impossible de charger vos billets.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 24;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF075E4D),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Mes Billets & Preuves d\'achat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF16332D),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadBillets,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF075E4D)),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF6C7C77),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (_billets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Vous n\'avez pas encore réservé de billet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF6C7C77)),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _billets.length,
                  itemBuilder: (ctx, idx) {
                    final b = _billets[idx];
                    final titre = (b['titreEvenement'] ?? 'Événement')
                        .toString();
                    final refCmd = (b['referenceCommande'] ?? '').toString();
                    final qte = (b['quantite'] ?? 1).toString();
                    final total = (b['montantTotal'] ?? 0).toString();
                    final devise = (b['devise'] ?? 'FCFA').toString();
                    final dateDebut = (b['dateDebutEvenement'] ?? '')
                        .toString();
                    final lieu = (b['lieuEvenement'] ?? 'Mali').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          ExplorerScreen.showDigitalTicketModal(context, b);
                        },
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF075E4D,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        title: Text(
                          titre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16332D),
                          ),
                        ),
                        subtitle: Text(
                          '$qte billet(s) • $total $devise\n${dateDebut.isNotEmpty ? '$dateDebut • ' : ''}$lieu\nRéf : $refCmd',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF6C7C77),
                            height: 1.35,
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF075E4D),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DigitalTicketDialog extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const _DigitalTicketDialog({required this.ticket});

  @override
  State<_DigitalTicketDialog> createState() => _DigitalTicketDialogState();
}

class _DigitalTicketDialogState extends State<_DigitalTicketDialog> {
  bool _verifying = false;
  String? _verificationResult;
  bool _verifiedValid = false;

  Future<void> _verifyTicket(String refCmd) async {
    setState(() {
      _verifying = true;
      _verificationResult = null;
    });
    try {
      final res = await ApiService().get(
        '/evenements/billets/verifier/${Uri.encodeComponent(refCmd)}',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final bool valide = data['valide'] == true;
        final String msg = (data['message'] ?? 'Billet vérifié').toString();
        if (mounted) {
          setState(() {
            _verifying = false;
            _verifiedValid = valide;
            _verificationResult = msg;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _verifying = false;
            _verifiedValid = false;
            _verificationResult = 'Référence introuvable ou non valide.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _verifiedValid = false;
          _verificationResult = 'Erreur lors de la vérification.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final String refCmd = (t['referenceCommande'] ?? 'TKT-MALI').toString();
    final String titreEvt = (t['titreEvenement'] ?? 'Événement MaliExplorer')
        .toString();
    final String dateDebut = (t['dateDebutEvenement'] ?? 'À confirmer')
        .toString();
    final String heureDebut = (t['heureDebutEvenement'] ?? '09:00').toString();
    final String lieuEvt = (t['lieuEvenement'] ?? 'Mali').toString();
    final String villeEvt = (t['villeEvenement'] ?? '').toString();
    final String fullLieu = villeEvt.isNotEmpty && !lieuEvt.contains(villeEvt)
        ? '$lieuEvt, $villeEvt'
        : lieuEvt;
    final String participant = (t['nomAcheteur'] ?? 'Participant MaliExplorer')
        .toString();
    final String quantite = (t['quantite'] ?? 1).toString();
    final String montant = (t['montantTotal'] ?? 0).toString();
    final String devise = (t['devise'] ?? 'FCFA').toString();
    final String canal = (t['canalPaiement'] ?? 'ORANGE_MONEY').toString();
    final String rawDateCmd =
        (t['dateCreation'] ?? DateTime.now().toIso8601String()).toString();
    final String dateCmd = rawDateCmd.length >= 16
        ? rawDateCmd.substring(0, 16).replaceAll('T', ' à ')
        : rawDateCmd;
    final String statut = (t['statutSimulation'] ?? 'CONFIRMED').toString();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête avec Logo MaliExplorer
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/MaliExplorer.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.explore_rounded,
                      color: Color(0xFF075E4D),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MALIEXPLORER',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF075E4D),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Billet & Preuve d\'achat numérique',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6C7C77),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statut == 'CONFIRMED' || statut == 'SIMULATED'
                        ? 'Confirmé (Test)'
                        : statut,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            // Détails du billet
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                titreEvt,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16332D),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildTicketInfoRow(
              'Date & heure de début',
              '$dateDebut à $heureDebut',
            ),
            _buildTicketInfoRow('Lieu', fullLieu),
            _buildTicketInfoRow('Participant', participant),
            _buildTicketInfoRow('Quantité de billets', '$quantite billet(s)'),
            _buildTicketInfoRow('Montant total', '$montant $devise ($canal)'),
            _buildTicketInfoRow('Date de commande', dateCmd),
            _buildTicketInfoRow('Référence unique', refCmd, isBold: true),
            const SizedBox(height: 14),
            // Code QR de vérification lié à la référence unique
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _DeterministicQrWidget(data: refCmd, size: 126),
                  const SizedBox(height: 8),
                  Text(
                    refCmd,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Color(0xFF075E4D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: _verifying
                          ? null
                          : () => _verifyTicket(refCmd),
                      icon: _verifying
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user_outlined, size: 15),
                      label: const Text(
                        'Vérifier la validité du billet',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF075E4D),
                        side: const BorderSide(color: Color(0xFF075E4D)),
                      ),
                    ),
                  ),
                  if (_verificationResult != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _verifiedValid
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _verifiedValid
                                ? Icons.check_circle_rounded
                                : Icons.error_outline_rounded,
                            size: 15,
                            color: _verifiedValid
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _verificationResult!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _verifiedValid
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075E4D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fermer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold
                    ? const Color(0xFF075E4D)
                    : const Color(0xFF16332D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeterministicQrWidget extends StatelessWidget {
  final String data;
  final double size;

  const _DeterministicQrWidget({required this.data, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DeterministicQrPainter(data),
    );
  }
}

class _DeterministicQrPainter extends CustomPainter {
  final String data;
  _DeterministicQrPainter(this.data);

  bool _isFinderPattern(int r, int c, int n) {
    bool topLeft = r < 7 && c < 7;
    bool topRight = r < 7 && c >= n - 7;
    bool bottomLeft = r >= n - 7 && c < 7;
    return topLeft || topRight || bottomLeft;
  }

  bool _finderCellActive(int r, int c) {
    if (r == 0 || r == 6 || c == 0 || c == 6) return true;
    if (r >= 2 && r <= 4 && c >= 2 && c <= 4) return true;
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const int n = 21;
    final double cellSize = size.width / n;
    final Paint darkPaint = Paint()
      ..color = const Color(0xFF16332D)
      ..style = PaintingStyle.fill;
    final Paint bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, bgPaint);

    final List<int> units = data.codeUnits.isEmpty
        ? [77, 65, 76, 73]
        : data.codeUnits;

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        bool fill = false;
        if (_isFinderPattern(r, c, n)) {
          int lr = r < 7 ? r : r - (n - 7);
          int lc = c < 7 ? c : c - (n - 7);
          fill = _finderCellActive(lr, lc);
        } else if (r == 6 || c == 6) {
          fill = (r + c) % 2 == 0;
        } else {
          final int idx = (r * n + c) % units.length;
          final int hash = (units[idx] * 31 + r * 17 + c * 13) & 0xFF;
          fill = (hash % 3 == 0) || ((hash >> 2) % 2 == 1 && (r + c) % 2 == 0);
        }

        if (fill) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
            darkPaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeterministicQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
