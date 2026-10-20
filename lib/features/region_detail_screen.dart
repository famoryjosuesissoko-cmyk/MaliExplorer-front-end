import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/region_model.dart';
import '../models/ville_model.dart';
import '../providers/favoris_provider.dart';
import '../router/app_router.dart';

/// Écran présentant une région administrative du Mali
/// avec mise en valeur patrimoniale et accès direct aux villes clés (ex: Djenné pour Mopti)
class RegionDetailScreen extends StatelessWidget {
  final RegionModel? region;

  const RegionDetailScreen({super.key, this.region});

  @override
  Widget build(BuildContext context) {
    final r = region ?? RegionData.regions.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final heroHeight = (size.height * 0.36).clamp(240.0, 320.0);

    final isMopti = r.id.toLowerCase() == 'mopti';

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.mistIvory,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de couverture
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            backgroundColor: const Color(0xFF075E4D),
            leading: Center(
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRouter.carte);
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
                    color: Color(0xFF16332D),
                    size: 20,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Consumer(
                    builder: (context, ref, _) {
                      ref.watch(favorisNotifierProvider);
                      final isFav = ref.read(favorisNotifierProvider.notifier).isFavorite(r.nom);
                      return InkWell(
                        onTap: () async {
                          await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                            titre: r.nom,
                            categorie: 'Région du Mali',
                            imageUrl: r.imageCover,
                            route: AppRouter.regionDetail,
                            referenceId: int.tryParse(r.id),
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
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFE53935) : const Color(0xFF16332D),
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                r.nom,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Builder(
                    builder: (context) {
                      final imgUrl = r.imageCover.trim();
                      if (imgUrl.startsWith('http://') || imgUrl.startsWith('https://')) {
                        return Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF075E4D),
                            child: const Center(
                              child: Icon(Icons.map, color: Colors.white54, size: 48),
                            ),
                          ),
                        );
                      }
                      return Image.asset(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF075E4D),
                          child: const Center(
                            child: Icon(Icons.map, color: Colors.white54, size: 48),
                          ),
                        ),
                      );
                    },
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu de la région
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges statistiques (Chef-lieu, Population, Superficie)
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          icon: Icons.location_city,
                          title: 'Chef-lieu',
                          value: r.chefLieu,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          icon: Icons.people_outline,
                          title: 'Population',
                          value: r.population,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          icon: Icons.aspect_ratio,
                          title: 'Superficie',
                          value: r.superficie,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Si c'est Mopti, mise en valeur prestigieuse de Djenné pour le jury
                  if (isMopti) ...[
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
                            color: const Color(0xFF075E4D).withValues(alpha: 0.25),
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
                                  Icons.star,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'JOYAU PATRIMONIAL UNESCO',
                                      style: TextStyle(
                                        color: Color(0xFFD6A23A),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    Text(
                                      'Cité Légendaire de Djenné',
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
                            'La cité de Djenné abrite la plus grande structure en terre crue au monde : la Grande Mosquée de Djenné. Explorez cette merveille avec galerie interactive et visite virtuelle 360° immersive.',
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
                                final djenneVille = VilleModel(
                                  id: 2,
                                  nom: 'Djenné',
                                  region: 'Mopti',
                                  description:
                                      'Djenné est une ville historique située à 130 km au sud-ouest de Mopti. Célèbre dans le monde entier pour sa majestueuse Grande Mosquée en terre crue (banco), chef-d\'œuvre absolu de l\'architecture soudano-sahélienne classé au patrimoine mondial de l\'UNESCO depuis 1988.',
                                  imageUrl: 'assets/images/djenne_cover.jpeg',
                                  nbreHbt: '32 000',
                                );
                                context.push(AppRouter.cityDetail, extra: djenneVille);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text(
                                'Voir la Fiche Détaillée de Djenné',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD6A23A),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleWrapper.rounded(10),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Liste des Sites & Zones Historiques de la Région
                  const Row(
                    children: [
                      Icon(Icons.account_balance_rounded,
                          size: 20, color: Color(0xFF075E4D)),
                      SizedBox(width: 8),
                      Text(
                        'Sites Historiques & Zones Clés',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Touchez un site pour consulter sa fiche détaillée et lancer sa visite immersive.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._buildSitesList(context, r),

                  const SizedBox(height: 24),

                  // Présentation de la région
                  const Text(
                    'Présentation & Histoire',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    r.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attraits majeurs
                  if (r.attraits.isNotEmpty) ...[
                    const Text(
                      'Attraits majeurs & Patrimoine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...r.attraits.map((attrait) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: Color(0xFF0E8F76),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  attrait,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Langues locales les plus parlées
                  _buildLanguesLocalesSection(context, r),

                  const SizedBox(height: 24),

                  // Localisation GPS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Color(0xFFD6A23A),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Coordonnées géographiques',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${r.latitude.toStringAsFixed(4)}° N, ${r.longitude.toStringAsFixed(4)}° O',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0E8F76)),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguesLocalesSection(BuildContext context, RegionModel r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langues = r.languesLocales.isNotEmpty
        ? r.languesLocales
        : const ['Bamanankan (Bambara)', 'Fulfulde (Peul)', 'Autre langue locale'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF075E4D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.record_voice_over_rounded,
                size: 20,
                color: Color(0xFF075E4D),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Langues locales les plus parlées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Top 3 des langues véhiculaires de la région',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Cartes des 3 langues avec icône haut-parleur réutilisable
        ...langues.map((langue) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF075E4D).withValues(alpha: 0.1),
                radius: 18,
                child: const Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: Color(0xFF075E4D),
                ),
              ),
              title: Text(
                langue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              trailing: Tooltip(
                message: 'Écouter la prononciation',
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "L'audio de prononciation pour « $langue » sera disponible prochainement.",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF075E4D),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6A23A).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      size: 20,
                      color: Color(0xFFB78326),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<Widget> _buildSitesList(BuildContext context, RegionModel r) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Définition des sites emblématiques par région
    final List<Map<String, dynamic>> sites;
    if (r.id.toLowerCase() == 'mopti') {
      sites = [
        {
          'nom': 'Grande Mosquée de Djenné',
          'ville': 'Djenné',
          'type': 'Patrimoine Mondial UNESCO',
          'description':
              'La plus grande construction en terre crue au monde. Chef-d\'œuvre de l\'architecture soudano-sahélienne avec visite immersive 360°.',
          'image': 'assets/images/djenne_cover.jpeg',
          'has360': true,
          'villeModel': VilleModel(
            id: 2,
            nom: 'Djenné',
            region: 'Mopti',
            description:
                'Djenné est une ville historique située à 130 km au sud-ouest de Mopti. Célèbre dans le monde entier pour sa majestueuse Grande Mosquée en terre crue (banco), chef-d\'œuvre absolu de l\'architecture soudano-sahélienne classé au patrimoine mondial de l\'UNESCO depuis 1988.',
            imageUrl: 'assets/images/djenne_cover.jpeg',
            nbreHbt: '32 000',
          ),
        },
        {
          'nom': 'Port Fluvial des Pinasses de Mopti',
          'ville': 'Mopti',
          'type': 'Carrefour fluvial & artisanal',
          'description':
              'Confluent animé du fleuve Niger et de la rivière Bani. Point de départ des grandes pinasses marchandes vers Tombouctou.',
          'image': 'assets/images/mopti_gallery_1.jpg',
          'has360': false,
          'villeModel': VilleModel(
            id: 3,
            nom: 'Mopti',
            region: 'Mopti',
            description:
                'Surnommée « la Venise malienne », Mopti s\'étend sur trois îles au confluent du Niger et du Bani. Son port animé de pinasses traditionnelles en fait un carrefour commercial et culturel incontournable.',
            imageUrl: 'assets/images/mopti_cover.jpg',
            nbreHbt: '115 000',
          ),
        },
        {
          'nom': 'Falaises de Bandiagara & Pays Dogon',
          'ville': 'Bandiagara',
          'type': 'Paysage culturel UNESCO',
          'description':
              'Escarpement de grès long de 150 km abritant les célèbres villages à greniers dogons et la culture des masques.',
          'image': 'assets/images/mopti_gallery_2.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 10,
            nom: 'Bandiagara',
            region: 'Mopti',
            description:
                'Haut-lieu de la culture Dogon au cœur des falaises classées au patrimoine mondial de l\'UNESCO.',
            imageUrl: 'assets/images/mopti_gallery_2.jpeg',
            nbreHbt: '45 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'tombouctou') {
      sites = [
        {
          'nom': 'Mosquée Djingareyber',
          'ville': 'Tombouctou',
          'type': 'Patrimoine Mondial UNESCO',
          'description':
              'Édifiée en 1327 par l\'empereur Kankan Moussa à son retour de pèlerinage. Cœur spirituel de la cité des 333 saints.',
          'image': 'assets/images/home_tombouctou.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 1,
            nom: 'Tombouctou',
            region: 'Tombouctou',
            description:
                'Dotée de la prestigieuse université coranique de Sankoré et d\'autres medersa, Tombouctou était aux XVe et XVIe siècles une capitale intellectuelle et spirituelle.',
            imageUrl: 'assets/images/home_tombouctou.jpeg',
            nbreHbt: '85 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'kayes') {
      sites = [
        {
          'nom': 'Fort Historique de Médine & Chutes du Félou',
          'ville': 'Kayes',
          'type': 'Patrimoine Historique & Naturel',
          'description':
              'Fort érigé en 1855 sur les rives du fleuve Sénégal et spectaculaires chutes d’eau du Félou et de Gouina.',
          'image': 'assets/images/explorer_artisans.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 7,
            nom: 'Kayes',
            region: 'Kayes',
            description:
                'Première région administrative du Mali, carrefour frontalier avec le Sénégal et la Mauritanie.',
            imageUrl: 'assets/images/explorer_artisans.jpeg',
            nbreHbt: '1 996 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'koulikoro') {
      sites = [
        {
          'nom': 'Rocher de Soumaoro Kanté & Port Fluvial',
          'ville': 'Koulikoro',
          'type': 'Site Mythique & Fleuve Niger',
          'description':
              'Rocher légendaire de la disparition du roi du Sosso et terminus portuaire navigable sur le fleuve Niger.',
          'image': 'assets/images/explorer_guides.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 8,
            nom: 'Koulikoro',
            region: 'Koulikoro',
            description:
                'Deuxième région administrative du Mali, carrefour des monts Mandingues et du fleuve Niger.',
            imageUrl: 'assets/images/explorer_guides.jpeg',
            nbreHbt: '2 418 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'koutiala') {
      sites = [
        {
          'nom': 'Complexe Cotonier & Marché Central Agro-pastoral',
          'ville': 'Koutiala',
          'type': 'Capitale de l’Or Blanc',
          'description':
              'Centre économique névralgique de production de coton et creuset des traditions culturelles Minianka.',
          'image': 'assets/images/explorer_artisans.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 12,
            nom: 'Koutiala',
            region: 'Koutiala',
            description:
                'Capitale de l’or blanc (coton) et carrefour agro-industriel majeur du sud malien.',
            imageUrl: 'assets/images/explorer_artisans.jpeg',
            nbreHbt: '575 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'san') {
      sites = [
        {
          'nom': 'Sanctuaire de la Mare Sanké Mô & Grande Église',
          'ville': 'San',
          'type': 'Patrimoine Culturel UNESCO',
          'description':
              'Lieu de célébration du rite de pêche collective séculaire Sanké Mô et imposante architecture soudanaise.',
          'image': 'assets/images/segou_cover.jpg',
          'has360': false,
          'villeModel': VilleModel(
            id: 13,
            nom: 'San',
            region: 'San',
            description:
                'Carrefour historique au confluent du Bani, célèbre pour le Sanké Mô et ses traditions Bobo et Marka.',
            imageUrl: 'assets/images/segou_cover.jpg',
            nbreHbt: '330 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'kenieba') {
      sites = [
        {
          'nom': 'Falaises du Tambaoura & Mines du Bambouk',
          'ville': 'Kéniéba',
          'type': 'Paysage Naturel & Géologique',
          'description':
              'Falaises abruptes et vallées aurifères ancestrales du Bambouk dans la haute vallée de la Falémé.',
          'image': 'assets/images/explorer_guides.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 14,
            nom: 'Kéniéba',
            region: 'Kayes',
            description:
                'Cœur historique du Bambouk et capitale aurifère du Mali, lovée au pied des falaises du Tambaoura.',
            imageUrl: 'assets/images/explorer_guides.jpeg',
            nbreHbt: '215 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'kita') {
      sites = [
        {
          'nom': 'Mont Sacré de Kita (Kita Kourou)',
          'ville': 'Kita',
          'type': 'Site Spirituel & Berceau Griotique',
          'description':
              'Montagne mystique protectrice de la cité, haut lieu de pèlerinage et berceau des griots mandingues.',
          'image': 'assets/images/explorer_ethnies_traditions.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 15,
            nom: 'Kita',
            region: 'Kita',
            description:
                'Capitale de l’arachide et berceau vénéré de la musique traditionnelle mandingue.',
            imageUrl: 'assets/images/explorer_ethnies_traditions.jpeg',
            nbreHbt: '438 000',
          ),
        },
      ];
    } else if (r.id.toLowerCase() == 'bandiagara') {
      sites = [
        {
          'nom': 'Falaises de Bandiagara & Villages Dogon',
          'ville': 'Bandiagara',
          'type': 'Patrimoine Mondial UNESCO',
          'description':
              'Falaises millénaires abritant l’architecture Dogon, la mémoire d’Amadou Hampâté Bâ et la culture des masques.',
          'image': 'assets/images/mopti_gallery_2.jpeg',
          'has360': false,
          'villeModel': VilleModel(
            id: 16,
            nom: 'Bandiagara',
            region: 'Bandiagara',
            description:
                'Capitale spirituelle et culturelle du Pays Dogon, classée au patrimoine mondial de l’UNESCO.',
            imageUrl: 'assets/images/mopti_gallery_2.jpeg',
            nbreHbt: '320 000',
          ),
        },
      ];
    } else {
      // Sites par défaut pour les autres régions
      sites = [
        {
          'nom': 'Centre Historique & Artisanal de ${r.chefLieu}',
          'ville': r.chefLieu,
          'type': 'Patrimoine Culturel',
          'description': r.description,
          'image': r.imageCover,
          'has360': false,
          'villeModel': VilleModel(
            id: 99,
            nom: r.chefLieu,
            region: r.nom,
            description: r.description,
            imageUrl: r.imageCover,
            nbreHbt: r.population,
          ),
        },
      ];
    }

    return sites.map((site) {
      final villeModel = site['villeModel'] as VilleModel;
      final has360 = site['has360'] as bool;

      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push(AppRouter.cityDetail, extra: villeModel);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(
                    builder: (context) {
                      final img = (site['image'] as String?)?.trim() ?? '';
                      if (img.startsWith('http://') || img.startsWith('https://')) {
                        return Image.network(
                          img,
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 85,
                            height: 85,
                            color: const Color(0xFF075E4D),
                            child: const Icon(Icons.account_balance,
                                color: Colors.white70),
                          ),
                        );
                      }
                      return Image.asset(
                        img,
                        width: 85,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 85,
                          height: 85,
                          color: const Color(0xFF075E4D),
                          child: const Icon(Icons.account_balance,
                              color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              site['nom'] as String,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (has360)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6A23A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '360°',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site['type'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF0E8F76),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        site['description'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}

class RoundedRectangleWrapper {
  static RoundedRectangleBorder rounded(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}
