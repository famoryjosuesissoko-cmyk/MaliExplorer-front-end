import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/app_colors.dart';
import '../models/ville_model.dart';
import '../providers/favoris_provider.dart';
import '../providers/villes_provider.dart';
import '../router/app_router.dart';

/// Page Détail d'une Ville / Lieu historique
class CityDetailScreen extends ConsumerStatefulWidget {
  final VilleModel? ville;

  const CityDetailScreen({super.key, this.ville});

  @override
  ConsumerState<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends ConsumerState<CityDetailScreen> {
  VilleModel? _resolveActiveVille() {
    final initial = widget.ville;
    final asyncVilles = ref.watch(villesProvider);
    return asyncVilles.maybeWhen(
      data: (villes) {
        if (initial == null) return villes.isNotEmpty ? villes.first : null;
        for (final v in villes) {
          if (initial.id > 0 && v.id == initial.id) return v;
          if (v.nom.trim().toLowerCase() == initial.nom.trim().toLowerCase()) return v;
        }
        return initial;
      },
      orElse: () => initial,
    );
  }

  List<String> _buildGalleryPhotos(VilleModel? activeVille) {
    final list = <String>[];
    final nom = (activeVille?.nom ?? 'Tombouctou').trim();

    // 1. Priorité aux images dynamiques de la ville configurées depuis l'administration
    if (activeVille != null && activeVille.images.isNotEmpty) {
      for (final img in activeVille.images) {
        final trimmed = img.trim();
        if (trimmed.isNotEmpty && !list.contains(trimmed)) {
          list.add(trimmed);
        }
      }
    }

    if (activeVille?.imageUrl != null &&
        activeVille!.imageUrl.trim().isNotEmpty &&
        !list.contains(activeVille.imageUrl.trim())) {
      list.insert(0, activeVille.imageUrl.trim());
    }

    // 2. Si aucune galerie multi-photos n'est encore enregistrée en base, compléter avec les photos locales authentiques de la ville
    if (list.length <= 1) {
      for (final localImg in VilleModel.getLocalGallery(nom)) {
        if (!list.contains(localImg)) {
          list.add(localImg);
        }
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double heroHeight = (screenHeight * 0.38).clamp(260.0, 340.0);

    final activeVille = _resolveActiveVille();
    final galleryPhotos = _buildGalleryPhotos(activeVille);

    final String nomVille = activeVille?.nom ?? 'Tombouctou';
    final String badgeVille =
        activeVille?.region != null && activeVille!.region.isNotEmpty
        ? 'Région: ${activeVille.region}'
        : 'Lieu historique';
    final String description =
        activeVille?.description ??
        'Dotée de la prestigieuse université coranique de Sankoré et d\'autres medersa, Tombouctou était aux XVe et XVIe siècles une capitale intellectuelle et spirituelle et un centre de propagation de l\'islam en Afrique. Ses trois grandes mosquées (Djingareyber, Sankoré et Sidi Yahia) témoignent de son âge d\'or. Bien que restaurés au XVIe siècle, ces monuments sont aujourd\'hui menacés par l\'avancée du sable.';
    final String population =
        activeVille?.nbreHbt != null && activeVille!.nbreHbt!.isNotEmpty
        ? (activeVille.nbreHbt!.contains('hab') ? activeVille.nbreHbt! : '${activeVille.nbreHbt} hab.')
        : (nomVille.toLowerCase().contains('bamako')
            ? '3 000 000 hab.'
            : (nomVille.toLowerCase().contains('djenne') || nomVille.toLowerCase().contains('djenné')
                ? '33 000 hab.'
                : (nomVille.toLowerCase().contains('mopti')
                    ? '114 000 hab.'
                    : (nomVille.toLowerCase().contains('segou') || nomVille.toLowerCase().contains('ségou')
                        ? '134 000 hab.'
                        : (nomVille.toLowerCase().contains('sikasso')
                            ? '226 000 hab.'
                            : '54 000 hab.')))));
    final String langue = nomVille.toLowerCase().contains('bamako')
        ? 'Bambara, Français'
        : (nomVille.toLowerCase().contains('djenne') || nomVille.toLowerCase().contains('djenné')
            ? 'Bozo, Peul, Songhaï'
            : (nomVille.toLowerCase().contains('mopti')
                ? 'Bozo, Peul, Bambara'
                : (nomVille.toLowerCase().contains('segou') || nomVille.toLowerCase().contains('ségou')
                    ? 'Bambara, Bozo, Somono'
                    : (nomVille.toLowerCase().contains('sikasso')
                        ? 'Sénoufo, Bambara, Samogo'
                        : (nomVille.toLowerCase().contains('kidal') || nomVille.toLowerCase().contains('menaka') || nomVille.toLowerCase().contains('ménaka')
                            ? 'Tamasheq, Songhaï, Arabe'
                            : (nomVille.toLowerCase().contains('gao') || nomVille.toLowerCase().contains('tombouctou')
                                ? 'Songhaï, Tamasheq, Arabe'
                                : (activeVille?.region.isNotEmpty == true
                                    ? 'Bambara, langues locales'
                                    : 'Songhaï, Tamasheq, Bambara')))))));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Stack(
        children: [
          // 1. Image Hero FIXE en haut de l'écran
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: heroHeight,
            child: SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: _buildHeroImageContent(heroHeight, activeVille),
            ),
          ),

          // 2. Contenu principal déroulant passant par-dessus
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Espace transparent laissant visible l'image hero du haut
                  SizedBox(height: heroHeight - 26),

                  // Fiche descriptive blanche
                  Container(
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

                        // Badge Coordonnées GPS (si disponibles)
                        if ((activeVille?.cordonnees != null && activeVille!.cordonnees!.isNotEmpty) ||
                            (activeVille?.latitude != null && activeVille?.longitude != null)) ...[
                          const SizedBox(height: 10),
                          _buildInfoCard(
                            icon: Icons.my_location_rounded,
                            title: 'Coordonnées GPS',
                            value: activeVille?.latitude != null && activeVille?.longitude != null
                                ? '${activeVille!.latitude!.abs().toStringAsFixed(4)}° ${activeVille.latitude! >= 0 ? 'N' : 'S'}, ${activeVille.longitude!.abs().toStringAsFixed(4)}° ${activeVille.longitude! >= 0 ? 'E' : 'O'}'
                                : activeVille!.cordonnees!,
                            iconColor: const Color(0xFF075E4D),
                          ),
                        ],

                        // Section Spéciale : Grande Mosquée de Djenné & Visite Virtuelle 360°
                        if (nomVille.toLowerCase().contains('djenne') ||
                            nomVille.toLowerCase().contains('djenné')) ...[
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF075E4D), Color(0xFF0E8F76)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF075E4D)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                                        color: const Color(0xFFD6A23A),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.threesixty,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'EXPÉRIENCE IMMERSIVE',
                                            style: TextStyle(
                                              color: Color(0xFFD6A23A),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          Text(
                                            'Grande Mosquée de Djenné',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Explorez le plus grand chef-d\'œuvre en terre crue au monde en visite panoramique 360°. Visualisez les minarets, les torons de palmier rônier et la cour intérieure.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        AppRouter.visiteVirtuelle360,
                                        extra: {
                                          'title': 'Grande Mosquée de Djenné',
                                          'panorama':
                                              'assets/pannellum/djenne_360_panorama.jpg',
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.threesixty, size: 20),
                                    label: const Text(
                                      'Visiter en 360°',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD6A23A),
                                      foregroundColor: const Color(0xFF16332D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),

                        // Galerie photos de la ville (grandes cartes empilées)
                        ...galleryPhotos.map((photoUrl) {
                          final isAsset = photoUrl.startsWith('assets/');
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: isAsset
                                  ? Image.asset(
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
                                    )
                                  : Image.network(
                                      ApiConstants.resolveImageUrl(photoUrl),
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
                ],
              ),
            ),
          ),

          // 3. Boutons Retour & Favoris FIXES en haut de l'écran
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.villesList);
                        }
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

                        final photo = widget.ville?.displayPhoto ?? VilleModel.getLocalPhoto(nomVille);

                        return InkWell(
                          onTap: () async {
                            await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                              titre: nomVille,
                              categorie: widget.ville?.region != null ? 'Région : ${widget.ville!.region}' : 'Lieu historique',
                              imageUrl: photo,
                              route: AppRouter.cityDetail,
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
                                  : AppColors.textPrimary,
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

  Widget _buildHeroImageContent(double height, VilleModel? activeVille) {
    final rawUrl = activeVille?.imageUrl.trim();
    final localFallback = VilleModel.getLocalPhoto(activeVille?.nom ?? 'Tombouctou');

    Widget placeholderWidget() => Container(
          height: height,
          color: AppColors.textPrimary,
          child: const Center(
            child: Icon(Icons.location_city_rounded, color: Colors.white, size: 48),
          ),
        );

    Widget fallbackWidget() {
      if (localFallback.startsWith('http://') || localFallback.startsWith('https://')) {
        return Image.network(
          localFallback,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => placeholderWidget(),
        );
      }
      return Image.asset(
        localFallback,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholderWidget(),
      );
    }

    if (rawUrl != null && rawUrl.isNotEmpty) {
      if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
        return Image.network(
          ApiConstants.resolveImageUrl(rawUrl),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return fallbackWidget();
          },
          errorBuilder: (context, error, stackTrace) => fallbackWidget(),
        );
      }
      if (rawUrl.startsWith('assets/')) {
        return Image.asset(
          rawUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallbackWidget(),
        );
      }
      if (rawUrl.startsWith('/')) {
        return Image.network(
          ApiConstants.resolveImageUrl(rawUrl),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded || frame != null) {
              return child;
            }
            return fallbackWidget();
          },
          errorBuilder: (context, error, stackTrace) => fallbackWidget(),
        );
      }
    }
    return fallbackWidget();
  }
}
