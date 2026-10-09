import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plat_model.dart';
import '../providers/favoris_provider.dart';
import '../router/app_router.dart';

/// Page Détail du Plat avec ingrédients complets et photos locales
class DishDetailScreen extends ConsumerStatefulWidget {
  final PlatModel? plat;

  const DishDetailScreen({super.key, this.plat});

  @override
  ConsumerState<DishDetailScreen> createState() => _DishDetailScreenState();
}

class _DishDetailScreenState extends ConsumerState<DishDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);

    // Résolution du plat courant ou premier plat par défaut
    final currentPlat = widget.plat ?? PlatModel.defaultPlats.first;
    final String photoPath = currentPlat.displayPhoto;

    final String nomPlat = currentPlat.nom;
    final String categoriePlat = currentPlat.regions.isNotEmpty
        ? 'Régions : ${currentPlat.regions.join(", ")}'
        : 'Plat traditionnel malien';
    final String ethniesText = currentPlat.ethnies.isNotEmpty
        ? 'Tradition : ${currentPlat.ethnies.join(", ")}'
        : '';
    final String description = currentPlat.description;

    // Autres plats suggérés
    final otherDishes = PlatModel.defaultPlats
        .where((p) => p.nom.toLowerCase() != currentPlat.nom.toLowerCase())
        .take(3)
        .toList();

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
                _buildHeroImage(context, currentPlat, photoPath, heroHeight),

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
                        // Titre & badges
                        Text(
                          nomPlat,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              categoriePlat,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0E8F76),
                              ),
                            ),
                            if (ethniesText.isNotEmpty) ...[
                              const Text(' • ',
                                  style: TextStyle(color: Color(0xFF8B9B95))),
                              Expanded(
                                child: Text(
                                  ethniesText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFD6A23A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Badges indicateurs (Cuisson, Portions, Niveau)
                        Row(
                          children: [
                            _buildFeatureBadge(
                              icon: Icons.timer_outlined,
                              label: currentPlat.tempsCuisson ?? '1h 15 min',
                              color: const Color(0xFF075E4D),
                            ),
                            const SizedBox(width: 8),
                            _buildFeatureBadge(
                              icon: Icons.people_outline_rounded,
                              label: '${currentPlat.nbrePersonnes ?? 5} pers.',
                              color: const Color(0xFFD6A23A),
                            ),
                            const SizedBox(width: 8),
                            _buildFeatureBadge(
                              icon: Icons.restaurant_rounded,
                              label: currentPlat.difficulte ?? 'Tradition',
                              color: const Color(0xFFC62828),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Section Description
                        const Text(
                          'Histoire & Description',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A5568),
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Ingrédients détaillés
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ingrédients nécessaires',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF9EE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFD6A23A)
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                '${currentPlat.ingredients.length} ingrédients',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF8B4513),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Liste / Grille des Ingrédients Détaillés
                        Column(
                          children: currentPlat.ingredients.map((ing) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAF8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.05)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFDF9EE),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFD6A23A)
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      ing.icone ?? '🍲',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ing.nom,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF16332D),
                                      ),
                                    ),
                                  ),
                                  if (ing.quantite != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF075E4D)
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ing.quantite!,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF075E4D),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                        // Secret de préparation / Astuce traditionnelle
                        if (currentPlat.secretPreparation != null &&
                            currentPlat.secretPreparation!.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF9EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFD6A23A).withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Secret de cuisson traditionnel',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF8B4513),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentPlat.secretPreparation!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5D4037),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Section Autres délices maliens
                        const Text(
                          'Autres spécialités à découvrir',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Ligne des plats similaires cliquables
                        Row(
                          children: otherDishes.map((other) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () {
                                      context.pushReplacement(
                                        AppRouter.dishDetail,
                                        extra: other,
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(13),
                                          ),
                                          child: other.displayPhoto
                                                  .startsWith('assets/')
                                              ? Image.asset(
                                                  other.displayPhoto,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      _dishPlaceholder(),
                                                )
                                              : Image.network(
                                                  other.displayPhoto,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) =>
                                                      _dishPlaceholder(),
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: Text(
                                            other.nom,
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
        ],
      ),
    );
  }

  Widget _dishPlaceholder() {
    return Container(
      height: 75,
      color: const Color(0xFFD6A23A).withValues(alpha: 0.25),
      child: const Icon(Icons.restaurant_menu_rounded,
          color: Color(0xFF075E4D), size: 28),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(
    BuildContext context,
    PlatModel plat,
    String photoPath,
    double height,
  ) {
    return Stack(
      children: [
        // Image du plat plein écran hero
        SizedBox(
          height: height,
          width: double.infinity,
          child: photoPath.startsWith('assets/')
              ? Image.asset(
                  photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF2C3E38),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                )
              : Image.network(
                  photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF2C3E38),
                    child: const Center(
                      child: Icon(Icons.restaurant,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                ),
        ),

        // Gradient d'assombrissement pour lisibilité
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.5),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),

        // Bouton Retour & Favoris en haut
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

                // Bouton Favoris (Cœur rouge réactif)
                Builder(
                  builder: (context) {
                    ref.watch(favorisNotifierProvider);
                    final String nomPlat = plat.nom;
                    final String categoriePlat = plat.regions.isNotEmpty
                        ? 'Origine : ${plat.regions.join(", ")}'
                        : 'Plat traditionnel';
                    final isFav = ref
                        .read(favorisNotifierProvider.notifier)
                        .isFavorite(nomPlat);

                    return InkWell(
                      onTap: () async {
                        await ref
                            .read(favorisNotifierProvider.notifier)
                            .toggleFavori(
                              titre: nomPlat,
                              categorie: categoriePlat,
                              imageUrl: plat.displayPhoto,
                              route: AppRouter.dishDetail,
                              referenceId: plat.id,
                            );
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
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav
                              ? const Color(0xFFE53935)
                              : const Color(0xFF6C7C77),
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
