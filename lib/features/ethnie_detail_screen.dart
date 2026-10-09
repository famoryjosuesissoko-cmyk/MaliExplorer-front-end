import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ethnie_model.dart';
import '../providers/favoris_provider.dart';
import '../router/app_router.dart';

/// Page Détail d'une Ethnie avec article détaillé sur l'Homme (Photo 1) et la Femme (Photo 2)
class EthnicityDetailScreen extends ConsumerStatefulWidget {
  final EthnieModel? ethnie;

  const EthnicityDetailScreen({super.key, this.ethnie});

  @override
  ConsumerState<EthnicityDetailScreen> createState() =>
      _EthnicityDetailScreenState();
}

class _EthnicityDetailScreenState extends ConsumerState<EthnicityDetailScreen> {
  // 0 = Vue Homme, 1 = Vue Femme
  int _selectedGenderIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 350.0);

    final currentEthnie = widget.ethnie ?? EthnieModel.defaultEthnies.first;

    // Photo affichée dans le hero selon la sélection
    final String activePhoto = _selectedGenderIndex == 0
        ? currentEthnie.photoHomme
        : currentEthnie.photoFemme;

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
                // 1. Bannière Hero dynamique (Homme / Femme)
                _buildHeroImage(context, currentEthnie, activePhoto, heroHeight),

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
                        // Titre principal
                        Text(
                          'Peuple ${currentEthnie.nom}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Badges : Région & Population & Langue
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoBadge(
                              icon: Icons.location_on_outlined,
                              label: currentEthnie.region,
                              color: const Color(0xFF075E4D),
                            ),
                            _buildInfoBadge(
                              icon: Icons.groups_outlined,
                              label: currentEthnie.population,
                              color: const Color(0xFFD6A23A),
                            ),
                            _buildInfoBadge(
                              icon: Icons.record_voice_over_outlined,
                              label: currentEthnie.langue,
                              color: const Color(0xFF8B4513),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Sélecteur Homme / Femme interactif
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F3F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildGenderTabButton(
                                  index: 0,
                                  title: '👨 L\'Homme Traditionnel',
                                  subtitle: 'Photo 1 : Vêtement & Rôle',
                                ),
                              ),
                              Expanded(
                                child: _buildGenderTabButton(
                                  index: 1,
                                  title: '👩 La Femme Traditionnelle',
                                  subtitle: 'Photo 2 : Parure & Bijoux',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description générale
                        const Text(
                          'Histoire & Héritage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentEthnie.description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A5568),
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // 3. ARTICLE DÉTAILLÉ 1 : L'HOMME DE L'ETHNIE
                        _buildArticleCard(
                          photoPath: currentEthnie.photoHomme,
                          badgeText: 'IMAGE 1 • TRADITION MASCULINE',
                          badgeColor: const Color(0xFF075E4D),
                          titre: currentEthnie.titreHomme,
                          contenu: currentEthnie.articleHomme,
                          icon: Icons.man_rounded,
                        ),

                        const SizedBox(height: 24),

                        // 4. ARTICLE DÉTAILLÉ 2 : LA FEMME DE L'ETHNIE
                        _buildArticleCard(
                          photoPath: currentEthnie.photoFemme,
                          badgeText: 'IMAGE 2 • TRADITION FÉMININE',
                          badgeColor: const Color(0xFFD6A23A),
                          titre: currentEthnie.titreFemme,
                          contenu: currentEthnie.articleFemme,
                          icon: Icons.woman_rounded,
                        ),

                        const SizedBox(height: 26),

                        // 5. Coutumes & Rites Majeurs
                        if (currentEthnie.coutumes.isNotEmpty) ...[
                          const Text(
                            'Coutumes & Rites Emblématiques',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF075E4D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: currentEthnie.coutumes.map((coutume) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAF8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFD6A23A)
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD6A23A)
                                            .withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 15,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        coutume,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF16332D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // 6. Navigation vers les autres peuples
                        const Text(
                          'Autres peuples du Mali',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Liste horizontale d'autres ethnies
                        SizedBox(
                          height: 115,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: EthnieModel.defaultEthnies
                                .where((e) => e.id != currentEthnie.id)
                                .map((other) {
                              return GestureDetector(
                                onTap: () {
                                  context.pushReplacement(
                                    AppRouter.ethnicityDetail,
                                    extra: other,
                                  );
                                },
                                child: Container(
                                  width: 130,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(13),
                                        ),
                                        child: other.photoHomme
                                                .startsWith('assets/')
                                            ? Image.asset(
                                                other.photoHomme,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    _placeholderSmall(),
                                              )
                                            : Image.network(
                                                other.photoHomme,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    _placeholderSmall(),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 4),
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
                              );
                            }).toList(),
                          ),
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

  Widget _placeholderSmall() {
    return Container(
      height: 70,
      color: const Color(0xFF075E4D).withValues(alpha: 0.15),
      child: const Icon(Icons.people, color: Color(0xFF075E4D)),
    );
  }

  Widget _buildGenderTabButton({
    required int index,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedGenderIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGenderIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF075E4D)
                    : const Color(0xFF6C7C77),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFD6A23A)
                    : const Color(0xFF8B9B95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard({
    required String photoPath,
    required String badgeText,
    required Color badgeColor,
    required String titre,
    required String contenu,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo grand format de l'homme / la femme
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: photoPath.startsWith('assets/')
                ? Image.asset(
                    photoPath,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 210,
                      color: badgeColor.withValues(alpha: 0.15),
                      child: Icon(icon, size: 48, color: badgeColor),
                    ),
                  )
                : Image.network(
                    photoPath,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 210,
                      color: badgeColor.withValues(alpha: 0.15),
                      child: Icon(icon, size: 48, color: badgeColor),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge d'identification
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Titre de l'article
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16332D),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Contenu détaillé de l'article
                Text(
                  contenu,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A5568),
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
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
    EthnieModel ethnie,
    String photoPath,
    double height,
  ) {
    return Stack(
      children: [
        // Image Hero
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
                      child: Icon(Icons.people, color: Colors.white54, size: 48),
                    ),
                  ),
                )
              : Image.network(
                  photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF2C3E38),
                    child: const Center(
                      child: Icon(Icons.people, color: Colors.white54, size: 48),
                    ),
                  ),
                ),
        ),

        // Gradient
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

        // Boutons Retour & Favoris en haut
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

                // Bouton Favoris
                Builder(
                  builder: (context) {
                    ref.watch(favorisNotifierProvider);
                    final String nomEthnie = ethnie.nom;
                    final isFav = ref
                        .read(favorisNotifierProvider.notifier)
                        .isFavorite(nomEthnie);

                    return InkWell(
                      onTap: () async {
                        await ref
                            .read(favorisNotifierProvider.notifier)
                            .toggleFavori(
                              titre: nomEthnie,
                              categorie: 'Peuple traditionnel',
                              imageUrl: ethnie.displayPhoto,
                              route: AppRouter.ethnicityDetail,
                              referenceId: ethnie.id,
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
