import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../models/ville_model.dart';
import '../providers/favoris_provider.dart';

/// Page Détail d'une Ville / Lieu historique
class CityDetailScreen extends ConsumerStatefulWidget {
  final VilleModel? ville;

  const CityDetailScreen({super.key, this.ville});

  @override
  ConsumerState<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends ConsumerState<CityDetailScreen> {

  List<String> get _galleryPhotos => [
    if (widget.ville?.imageUrl != null && widget.ville!.imageUrl.isNotEmpty)
      widget.ville!.imageUrl,
    'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=1000&auto=format&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);

    final String nomVille = widget.ville?.nom ?? 'Tombouctou';
    final String badgeVille =
        widget.ville?.region != null && widget.ville!.region.isNotEmpty
        ? 'Région: ${widget.ville!.region}'
        : 'Lieu historique';
    final String description =
        widget.ville?.description ??
        'Dotée de la prestigieuse université coranique de Sankoré et d\'autres medersa, Tombouctou était aux XVe et XVIe siècles une capitale intellectuelle et spirituelle et un centre de propagation de l\'islam en Afrique. Ses trois grandes mosquées (Djingareyber, Sankoré et Sidi Yahia) témoignent de son âge d\'or. Bien que restaurés au XVIe siècle, ces monuments sont aujourd\'hui menacés par l\'avancée du sable.';
    final String population =
        widget.ville?.nbreHbt != null && widget.ville!.nbreHbt!.isNotEmpty
        ? '${widget.ville!.nbreHbt} hab.'
        : '85 000';
    final String langue = widget.ville?.region.isNotEmpty == true
        ? 'Bambara, langues locales'
        : 'songhaï, tamasheq, bambara';

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
                // 1. Image Hero avec boutons Retour & Favoris
                _buildHeroImage(context, heroHeight),

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
                        // Titre & Badge
                        Text(
                          nomVille,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF0D5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeVille,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.solarYellow,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Texte de description
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // 2 Grands Badges d'informations clés (Populations & Langues)
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.people_alt_outlined,
                                title: 'Populations',
                                value: population,
                                iconColor: AppColors.solarYellow,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _buildInfoCard(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: 'Langues',
                                value: langue,
                                iconColor: AppColors.solarYellow,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Galerie photos de la ville (grandes cartes empilées)
                        ..._galleryPhotos.map((photoUrl) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                photoUrl,
                                height: 165,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 165,
                                      color: const Color(
                                        0xFFD6A23A,
                                      ).withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.image,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                              ),
                            ),
                          );
                        }),
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEBEBE5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, double height) {
    return Stack(
      children: [
        // Image de la ville
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            image: DecorationImage(
              image: NetworkImage(
                widget.ville?.imageUrl != null &&
                        widget.ville!.imageUrl.isNotEmpty
                    ? widget.ville!.imageUrl
                    : 'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=1000&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Boutons Retour & Favoris
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                // Bouton Favoris (Cœur rouge réactif)
                Builder(
                  builder: (context) {
                    ref.watch(favorisNotifierProvider);
                    final nomVille = widget.ville?.nom ?? 'Djenné';
                    final isFav = ref.read(favorisNotifierProvider.notifier).isFavorite(nomVille);

                    return InkWell(
                      onTap: () async {
                        await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                          titre: nomVille,
                          categorie: widget.ville?.region != null ? 'Région : ${widget.ville!.region}' : 'Lieu historique',
                          imageUrl: widget.ville?.imageUrl ??
                              'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=1000&auto=format&fit=crop',
                          route: '/cityDetail',
                          referenceId: widget.ville?.id,
                          isLieu: true,
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
