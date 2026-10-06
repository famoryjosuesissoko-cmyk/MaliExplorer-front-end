import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ethnie_model.dart';
import '../providers/favoris_provider.dart';

/// Page Détail d'une Ethnie
class EthnicityDetailScreen extends ConsumerStatefulWidget {
  final EthnieModel? ethnie;

  const EthnicityDetailScreen({super.key, this.ethnie});

  @override
  ConsumerState<EthnicityDetailScreen> createState() => _EthnicityDetailScreenState();
}

class _EthnicityDetailScreenState extends ConsumerState<EthnicityDetailScreen> {

  List<String> get _culturePhotos => [
        if (widget.ethnie?.imageUrl != null && widget.ethnie!.imageUrl.isNotEmpty)
          widget.ethnie!.imageUrl,
        'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=600&auto=format&fit=crop',
      ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);

    final String nomEthnie = widget.ethnie?.nom ?? 'Les dogons';
    final String description = widget.ethnie?.description ??
        'Le peuple Dogon est un groupe ethnique emblématique du Mali, réputé pour sa riche cosmogonie, ses masques rituels et son architecture spectaculaire accrochée aux falaises de Bandiagara (classées au patrimoine mondial de l\'UNESCO). Leurs traditions orales, leurs danses masquées et leur savoir astronomique fascinent les chercheurs du monde entier.';
    final String region = widget.ethnie?.region.isNotEmpty == true ? widget.ethnie!.region : 'Mopti';
    final String langue = 'Langue traditionnelle';
    final String population = widget.ethnie?.population.isNotEmpty == true ? widget.ethnie!.population : '+2 millions';

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
                        // Titre
                        Text(
                          nomEthnie,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
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

                        const SizedBox(height: 22),

                        // 3 Badges d'informations clés (Région, Langues, Populations)
                        Row(
                          children: [
                            _buildInfoCard(
                              icon: Icons.location_on_outlined,
                              title: 'Région',
                              value: region,
                              iconColor: const Color(0xFFD6A23A),
                            ),
                            const SizedBox(width: 8),
                            _buildInfoCard(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Langues',
                              value: langue,
                              iconColor: const Color(0xFFD6A23A),
                            ),
                            const SizedBox(width: 8),
                            _buildInfoCard(
                              icon: Icons.people_alt_outlined,
                              title: 'Populations',
                              value: population,
                              iconColor: const Color(0xFFD6A23A),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // Section Culture et traditions
                        const Text(
                          'Culture et traditions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Grille 2x2 des 4 photos culturelles
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.25,
                              ),
                          itemCount: _culturePhotos.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                _culturePhotos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: const Color(
                                        0xFF0E8F76,
                                      ).withValues(alpha: 0.2),
                                      child: const Icon(
                                        Icons.photo_size_select_actual_rounded,
                                        color: Color(0xFF075E4D),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEBEBE5), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF16332D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, double height) {
    return Stack(
      children: [
        // Image de l'ethnie
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E38),
            image: DecorationImage(
              image: NetworkImage(
                widget.ethnie?.imageUrl != null && widget.ethnie!.imageUrl.isNotEmpty
                    ? widget.ethnie!.imageUrl
                    : 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=1000&auto=format&fit=crop',
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
                      color: Color(0xFF16332D),
                      size: 20,
                    ),
                  ),
                ),
                // Bouton Favoris (Cœur rouge réactif)
                Builder(
                  builder: (context) {
                    ref.watch(favorisNotifierProvider);
                    final nomEthnie = widget.ethnie?.nom ?? 'Dogon';
                    final isFav = ref.read(favorisNotifierProvider.notifier).isFavorite(nomEthnie);

                    return InkWell(
                      onTap: () async {
                        await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                          titre: nomEthnie,
                          categorie: 'Peuple & Culture',
                          imageUrl: widget.ethnie?.imageUrl ??
                              'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop',
                          route: '/ethnicityDetail',
                          referenceId: widget.ethnie?.id,
                          isArticle: true,
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
