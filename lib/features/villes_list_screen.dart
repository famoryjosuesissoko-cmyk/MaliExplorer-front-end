import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/ville_model.dart';
import '../providers/villes_provider.dart';
import '../router/app_router.dart';

class VillesListScreen extends ConsumerStatefulWidget {
  const VillesListScreen({super.key});

  @override
  ConsumerState<VillesListScreen> createState() => _VillesListScreenState();
}

class _VillesListScreenState extends ConsumerState<VillesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<CityListItem> _cities = [
    CityListItem(
      name: 'Bamako',
      region: 'District de Bamako',
      description: 'Capitale dynamique, carrefour de culture au bord du Niger.',
      imageUrl: 'assets/images/bamako_cover.jpeg',
    ),
    CityListItem(
      name: 'Tombouctou',
      region: 'Région de Tombouctou',
      description: 'La cité mystérieuse des 333 saints et joyau du commerce caravanier.',
      imageUrl: 'assets/images/tombouctou_hero.jpeg',
    ),
    CityListItem(
      name: 'Djenné',
      region: 'Région de Mopti',
      description: 'Cité millénaire, célèbre pour sa grande architecture en terre crue.',
      imageUrl: 'assets/images/djenne_cover.jpeg',
    ),
    CityListItem(
      name: 'Mopti',
      region: 'Région de Mopti',
      description: 'La "Venise du Mali", grand port fluvial et carrefour des fleuves.',
      imageUrl: 'assets/images/mopti_cover.jpg',
    ),
    CityListItem(
      name: 'Ségou',
      region: 'Région de Ségou',
      description: 'Cité des balanzans, capitale historique du fier royaume Bambara.',
      imageUrl: 'assets/images/segou_cover.jpg',
    ),
    CityListItem(
      name: 'Sikasso',
      region: 'Région de Sikasso',
      description: 'Capitale du Kénédougou, grenier verdoyant et verger du Mali.',
      imageUrl: 'assets/images/sikasso_cover.jpeg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          // Structure globale : En-tête vert + Fiche blanche
          Column(
            children: [
              // En-tête vert
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/home'),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Villes du Mali',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 32.0),
                        child: Text(
                          'Plongez au cœur des cités historiques et des métropoles animées',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fiche blanche contenant la grille des villes
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    child: Column(
                      children: [
                        // Barre de recherche
                        _buildSearchBar(),

                        const SizedBox(height: 18),

                        // Grille 2 colonnes connectée à Riverpod
                        ref.watch(filteredVillesProvider).when(
                              data: (villes) {
                                final displayVilles = villes.isNotEmpty
                                    ? villes
                                    : _cities
                                        .map((c) => VilleModel(
                                              id: 0,
                                              nom: c.name,
                                              region: c.region,
                                              description: c.description,
                                              imageUrl: c.imageUrl,
                                            ))
                                        .toList();
                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.74,
                                  ),
                                  itemCount: displayVilles.length,
                                  itemBuilder: (context, index) {
                                    final v = displayVilles[index];
                                    return _buildCityCardFromModel(v);
                                  },
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 50),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF075E4D),
                                  ),
                                ),
                              ),
                              error: (_, _) {
                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.74,
                                  ),
                                  itemCount: _cities.length,
                                  itemBuilder: (context, index) {
                                    return _buildCityCard(_cities[index]);
                                  },
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
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8B9B95), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(villeSearchQueryProvider.notifier).state = val;
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher une ville...',
                hintStyle: TextStyle(
                  color: Color(0xFF8B9B95),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(CityListItem city) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigation vers la page détail de la ville sélectionnée
            context.push(
              AppRouter.cityDetail,
              extra: VilleModel(
                id: 0,
                nom: city.name,
                region: city.region,
                description: city.description,
                imageUrl: city.imageUrl,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image supérieure de la ville
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: city.imageUrl.startsWith('assets/')
                    ? Image.asset(
                        city.imageUrl,
                        height: 98,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 98,
                          color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Color(0xFF075E4D),
                            size: 32,
                          ),
                        ),
                      )
                    : Image.network(
                        city.imageUrl,
                        height: 98,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 98,
                          color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Color(0xFF075E4D),
                            size: 32,
                          ),
                        ),
                      ),
              ),

              // Informations
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF075E4D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      city.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD6A23A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6C7C77),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityCardFromModel(VilleModel ville) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(AppRouter.cityDetail, extra: ville);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: ville.imageUrl.startsWith('assets/')
                    ? Image.asset(
                        ville.imageUrl,
                        height: 98,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 98,
                          color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Color(0xFF075E4D),
                            size: 32,
                          ),
                        ),
                      )
                    : Image.network(
                        ville.imageUrl,
                        height: 98,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 98,
                          color: const Color(0xFFD6A23A).withValues(alpha: 0.2),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Color(0xFF075E4D),
                            size: 32,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ville.nom,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF075E4D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ville.region,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD6A23A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ville.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6C7C77),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class CityListItem {
  final String name;
  final String region;
  final String description;
  final String imageUrl;

  CityListItem({
    required this.name,
    required this.region,
    required this.description,
    required this.imageUrl,
  });
}
