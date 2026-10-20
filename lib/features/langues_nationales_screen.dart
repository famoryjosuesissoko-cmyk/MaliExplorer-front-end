import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/langue_model.dart';
import '../providers/langues_provider.dart';
import '../router/app_router.dart';

/// Écran présentant les langues nationales du Mali et leur lexique pratique quotidien.
class LanguesNationalesScreen extends ConsumerStatefulWidget {
  const LanguesNationalesScreen({super.key});

  @override
  ConsumerState<LanguesNationalesScreen> createState() => _LanguesNationalesScreenState();
}

class _LanguesNationalesScreenState extends ConsumerState<LanguesNationalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedLangueIndex = 0;
  String _selectedCategorie = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Salutations',
    'Courtoisie',
    'Marché & Commerce',
    'Orientation & Déplacement',
    'Expressions usuelles',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languesAsync = ref.watch(languesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // En-tête vert fixe MaliExplorer avec barre de recherche
          Container(
            color: const Color(0xFF075E4D),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRouter.explorer);
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
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LANGUES NATIONALES DU MALI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Lexique pratique pour voyager et échanger',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFFD1E7DD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Barre de recherche textuelle
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un mot, salutation ou traduction...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8C9B96)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF075E4D), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Zone principale avec RefreshIndicator et gestion des 4 états
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF075E4D),
              onRefresh: () async {
                ref.invalidate(languesProvider);
                try {
                  await ref.read(languesProvider.future);
                } catch (_) {
                  // L'erreur sera capturée et restituée par le provider Riverpod.
                }
              },
              child: languesAsync.when(
                loading: () => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF075E4D)),
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => _buildErrorState(context, ref, isDark),
                data: (langues) {
                  if (langues.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }
                  return _buildDataContent(context, isDark, langues);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la vue complète lorsque les données des langues sont disponibles.
  Widget _buildDataContent(BuildContext context, bool isDark, List<LangueModel> langues) {
    final safeIndex = _selectedLangueIndex.clamp(0, langues.length - 1);
    final currentLangue = langues[safeIndex];

    // Filtrage du lexique selon la recherche et la catégorie active
    final filteredLexique = currentLangue.lexique.where((item) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.mot.toLowerCase().contains(query) ||
          item.traduction.toLowerCase().contains(query) ||
          item.phonetique.toLowerCase().contains(query);
      final matchesCategory = _selectedCategorie == 'Tous' ||
          item.categorie.toLowerCase() == _selectedCategorie.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Sélecteur horizontal de langues
        SliverToBoxAdapter(
          child: Container(
            height: 48,
            color: isDark ? const Color(0xFF1E2825) : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: langues.length,
              itemBuilder: (context, index) {
                final isSelected = safeIndex == index;
                final label = langues[index].nom.contains(' ')
                    ? langues[index].nom.split(' ')[0]
                    : langues[index].nom;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF4A5568),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF075E4D),
                    backgroundColor: isDark ? const Color(0xFF2C3935) : const Color(0xFFF0F4F2),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    onSelected: (val) {
                      if (val) setState(() => _selectedLangueIndex = index);
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // Sélecteur horizontal de catégories thématiques
        SliverToBoxAdapter(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161F1C) : const Color(0xFFFAFBFA),
              border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategorie == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF075E4D) : const Color(0xFF6B7280),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategorie = cat),
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFF075E4D).withValues(alpha: 0.12),
                    checkmarkColor: const Color(0xFF075E4D),
                    shape: RoundedRectangle18(),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                );
              },
            ),
          ),
        ),

        // Carte descriptive de la langue courante
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF24322E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentLangue.imageUrl != null && currentLangue.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        currentLangue.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          currentLangue.nom,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                      ),
                      if (currentLangue.locuteurs.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentLangue.locuteurs,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (currentLangue.regions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6C7C77)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Régions : ${currentLangue.regions}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF6C7C77),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (currentLangue.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      currentLangue.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[300] : const Color(0xFF4A5568),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // En-tête du lexique
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEXIQUE DU QUOTIDIEN (${filteredLexique.length})',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Color(0xFF6C7C77),
                  ),
                ),
                Text(
                  currentLangue.nomLocal,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF075E4D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Liste des cartes de lexique ou message de recherche infructueuse
        if (filteredLexique.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aucune expression trouvée pour cette recherche.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6C7C77)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredLexique[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2825) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.015),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF075E4D).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.record_voice_over_rounded,
                            size: 16,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.mot,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF075E4D),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.categorie,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4A5568),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.phonetique.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '[${item.phonetique}]',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontStyle: FontStyle.italic,
                                    color: isDark ? Colors.grey[400] : const Color(0xFF718096),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                item.traduction,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF1A202C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredLexique.length,
              ),
            ),
          ),
      ],
    );
  }

  /// Construit la vue de l'état vide officiel lorsque la base de données ne contient aucune langue.
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.record_voice_over_outlined,
                    size: 48,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Langues Nationales du Mali',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucune langue répertoriée dans la base de données pour le moment. Les langues apparaîtront dès qu\'elles seront enregistrées et publiées par l\'administrateur.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C7C77),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Construit la vue en cas d'erreur réseau ou serveur, avec bouton de réessai.
  Widget _buildErrorState(BuildContext context, WidgetRef ref, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 60),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Impossible de charger les langues nationales. Veuillez vérifier votre connexion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6C7C77)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(languesProvider),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF075E4D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
}

/// Bordure arrondie pour les puces de filtres.
class RoundedRectangle18 extends RoundedRectangleBorder {
  RoundedRectangle18()
      : super(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        );
}
