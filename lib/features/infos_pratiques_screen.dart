import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/info_pratique_model.dart';
import '../providers/infos_pratiques_provider.dart';
import '../router/app_router.dart';

/// Écran des informations pratiques pour les voyageurs au Mali.
/// Consomme dynamiquement infosPratiquesProvider avec navigation par onglets fixes.
class InfosPratiquesScreen extends ConsumerStatefulWidget {
  const InfosPratiquesScreen({super.key});

  @override
  ConsumerState<InfosPratiquesScreen> createState() => _InfosPratiquesScreenState();
}

class _InfosPratiquesScreenState extends ConsumerState<InfosPratiquesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'TOUS';

  /// Onglets thématiques officiels fixes
  final List<Map<String, String>> _categoriesTabs = const [
    {'key': 'TOUS', 'label': 'Tous'},
    {'key': 'VISAS', 'label': 'Visas'},
    {'key': 'SANTE', 'label': 'Santé'},
    {'key': 'DEVISES', 'label': 'Devises'},
    {'key': 'CLIMAT', 'label': 'Climat'},
    {'key': 'URGENCES', 'label': 'Urgences'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final infosAsync = ref.watch(infosPratiquesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // En-tête vert MaliExplorer
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
                                'INFORMATIONS PRATIQUES',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Guide essentiel du voyageur au Mali',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFD1E7DD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barre de recherche textuelle
                    Container(
                      height: 42,
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
                          hintText: 'Rechercher un conseil, visa, urgence...',
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Barre horizontale d'onglets fixes thématiques
          Container(
            height: 48,
            color: isDark ? const Color(0xFF1E2825) : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _categoriesTabs.length,
              itemBuilder: (context, index) {
                final tab = _categoriesTabs[index];
                final isSelected = _selectedCategory == tab['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      tab['label']!,
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
                      if (val) setState(() => _selectedCategory = tab['key']!);
                    },
                  ),
                );
              },
            ),
          ),

          // Contenu principal avec RefreshIndicator et gestion des 4 états
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF075E4D),
              onRefresh: () async {
                ref.invalidate(infosPratiquesProvider);
                try {
                  await ref.read(infosPratiquesProvider.future);
                } catch (_) {
                  // L'erreur sera gérée par le provider Riverpod.
                }
              },
              child: infosAsync.when(
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
                data: (infos) {
                  if (infos.isEmpty) {
                    return _buildEmptyState(context, isDark);
                  }
                  return _buildDataContent(context, isDark, infos);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la liste dynamique des sections d'informations pratiques.
  Widget _buildDataContent(BuildContext context, bool isDark, List<InfoPratiqueModel> infos) {
    // Filtrage par catégorie sélectionnée et texte de recherche
    final filteredInfos = infos.where((item) {
      final matchesCategory = _selectedCategory == 'TOUS' ||
          item.categorie.toUpperCase() == _selectedCategory.toUpperCase();
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.titre.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          (item.conseils != null && item.conseils!.toLowerCase().contains(query)) ||
          (item.coordonnees != null && item.coordonnees!.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();

    if (filteredInfos.isEmpty) {
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
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Aucun résultat pour cette catégorie ou recherche.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6C7C77)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filteredInfos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = filteredInfos[index];
        if (item.categorie.toUpperCase() == 'URGENCES') {
          return _buildEmergencySection(context, isDark, item);
        }
        return _buildInfoSection(context, isDark, item);
      },
    );
  }

  /// Construit la section dédiée aux numéros et consignes d'urgence.
  Widget _buildEmergencySection(BuildContext context, bool isDark, InfoPratiqueModel item) {
    final rows = item.emergencyRows;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2825) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone_rounded, color: Color(0xFF075E4D), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.titre.isNotEmpty ? item.titre : "Numéros d'Urgence au Mali",
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.defaultBadgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.displayBadge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: item.defaultBadgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (rows.isNotEmpty) ...[
            for (int i = 0; i < rows.length; i++) ...[
              if (i > 0) const Divider(height: 14),
              _buildEmergencyRow(rows[i].key, rows[i].value, isDark),
            ],
          ] else if (item.itemsList.isNotEmpty) ...[
            for (final line in item.itemsList)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.grey[300] : const Color(0xFF2D3748),
                  ),
                ),
              ),
          ] else if (item.description.isNotEmpty) ...[
            Text(
              item.description,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey[300] : const Color(0xFF2D3748),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit une ligne d'urgence (libellé + numéro de téléphone).
  Widget _buildEmergencyRow(String label, String number, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[200] : const Color(0xFF2D3748),
            ),
          ),
        ),
        if (number.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FFFA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF075E4D),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit une carte thématique classique (Visas, Santé, Devises, Climat, etc.).
  Widget _buildInfoSection(BuildContext context, bool isDark, InfoPratiqueModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2825) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.defaultIcon, color: const Color(0xFF075E4D), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.titre,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.defaultBadgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.displayBadge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: item.defaultBadgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (item.itemsList.isNotEmpty)
            ...item.itemsList.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: Color(0xFF075E4D)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey[300] : const Color(0xFF4A5568),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (item.description.isNotEmpty)
            Text(
              item.description,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey[300] : const Color(0xFF4A5568),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  /// Construit la vue de l'état vide officiel lorsque la base de données ne contient aucune information pratique.
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
                    Icons.info_outline_rounded,
                    size: 48,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Informations Pratiques Voyageurs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aucune information pratique répertoriée pour le moment. Les guides essentiels apparaîtront dès qu\'ils seront renseignés et publiés par l\'administration.',
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

  /// Construit la vue en cas d'erreur de chargement avec bouton de réessai.
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
                  'Impossible de charger les informations pratiques. Veuillez vérifier votre connexion.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF6C7C77)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(infosPratiquesProvider),
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
