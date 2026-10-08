import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {
      'titre': 'Villes & Régions',
      'sousTitre': '6 cités historiques et leurs merveilles',
      'route': AppRouter.villesList,
      'image': 'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=600&auto=format&fit=crop',
      'badge': '6 Villes',
      'icon': Icons.location_city_rounded,
    },
    {
      'titre': 'Gastronomie Malienne',
      'sousTitre': 'Tigadèguèna, Fakoye, Tô et délices',
      'route': AppRouter.gastronomieList,
      'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=600&auto=format&fit=crop',
      'badge': 'Plats Typiques',
      'icon': Icons.restaurant_menu_rounded,
    },
    {
      'titre': 'Ethnies & Traditions',
      'sousTitre': 'Bambara, Dogon, Peul, Soninké, Touareg',
      'route': AppRouter.ethniesList,
      'image': 'https://images.unsplash.com/photo-1489749798305-4fea3ae63d43?q=80&w=600&auto=format&fit=crop',
      'badge': '6 Peuples',
      'icon': Icons.groups_rounded,
    },
    {
      'titre': 'Chefs d\'État & Histoire',
      'sousTitre': 'Figures républicaines depuis 1960',
      'route': AppRouter.chefsEtat,
      'image': 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Modibo_Keita_1961.jpg',
      'badge': 'Histoire',
      'icon': Icons.history_edu_rounded,
    },
    {
      'titre': 'Artisans du Mali',
      'sousTitre': 'Poterie, cuir, bogolan et bijoux',
      'route': AppRouter.artisans,
      'image': 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=600&auto=format&fit=crop',
      'badge': 'Artisanat',
      'icon': Icons.handyman_rounded,
    },
    {
      'titre': 'Guides Touristiques',
      'sousTitre': 'Professionnels locaux certifiés',
      'route': AppRouter.guides,
      'image': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
      'badge': 'Accompagnement',
      'icon': Icons.person_pin_circle_rounded,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return (cat['titre'] as String).toLowerCase().contains(q) ||
          (cat['sousTitre'] as String).toLowerCase().contains(q);
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFFF2B544), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Patrimoine',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Barre de recherche
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: TextStyle(color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D)),
                      decoration: InputDecoration(
                        hintText: 'Rechercher villes, plats, ethnies, guides...',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.darkTextDisabled : const Color(0xFF8B9B95),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiche blanche contenant les cartes des catégories
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final cat = filtered[index];
                  return _buildCategoryCard(cat, isDark);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, bool isDark) {
    return InkWell(
      onTap: () => context.push(cat['route'] as String),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image de la catégorie
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    cat['image'] as String,
                    width: 115,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, _, __) => Container(
                      width: 115,
                      color: const Color(0xFF075E4D),
                      child: Icon(cat['icon'] as IconData, color: Colors.white70, size: 36),
                    ),
                  ),
                  Container(
                    width: 115,
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ],
              ),
            ),

            // Contenu texte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                              color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      cat['titre'] as String,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat['sousTitre'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Flèche droite
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8B9B95),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

