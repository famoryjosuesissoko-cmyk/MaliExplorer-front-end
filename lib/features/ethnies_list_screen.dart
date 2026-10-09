import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ethnie_model.dart';
import '../providers/ethnies_provider.dart';

class EthniesListScreen extends ConsumerStatefulWidget {
  const EthniesListScreen({super.key});

  @override
  ConsumerState<EthniesListScreen> createState() => _EthniesListScreenState();
}

class _EthniesListScreenState extends ConsumerState<EthniesListScreen> {
  final TextEditingController _searchController = TextEditingController();

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
              // En-tête vert (Titre & sous-titre)
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
                              'Peuples & Traditions',
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
                          'Riche mosaïque ethnique qui fait la force culturelle du Mali',
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

              // Fiche blanche contenant les grandes cartes d'ethnies
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    child: Column(
                      children: [
                        // Barre de recherche
                        _buildSearchBar(),

                        const SizedBox(height: 18),

                        // Grandes cartes d'ethnies connectées à Riverpod
                        ref
                            .watch(filteredEthniesProvider)
                            .when(
                              data: (ethnies) {
                                if (ethnies.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.theater_comedy_rounded,
                                            size: 48,
                                            color: Color(0xFF8B9B95),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Aucune ethnie trouvée.',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6C7C77),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: ethnies
                                      .map((eth) => _buildEthnicityCard(eth))
                                      .toList(),
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
                              error: (error, stack) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        size: 44,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Erreur de chargement des ethnies',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF075E4D,
                                          ),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            ref.refresh(ethniesProvider),
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                        ),
                                        label: const Text('Réessayer'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                ref.read(ethnieSearchQueryProvider.notifier).state = val;
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher une ethnie...',
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

  Widget _buildEthnicityCard(EthnieModel eth) {
    final photo = eth.displayPhoto;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            context.push(AppRouter.ethnicityDetail, extra: eth);
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image panoramique supérieure
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: photo.startsWith('assets/')
                    ? Image.asset(
                        photo,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildEthniePlaceholder(),
                      )
                    : Image.network(
                        photo,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildEthniePlaceholder(),
                      ),
              ),

              // Contenu textuel en bas
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Peuple ${eth.nom}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6A23A).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            eth.population,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      eth.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6C7C77),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded,
                            size: 14, color: Color(0xFF075E4D)),
                        const SizedBox(width: 4),
                        const Text(
                          'Photos Homme & Femme disponibles',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Color(0xFF075E4D),
                        ),
                      ],
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

  Widget _buildEthniePlaceholder() {
    return Container(
      height: 155,
      color: const Color(0xFF0E8F76).withValues(alpha: 0.2),
      child: const Center(
        child: Icon(
          Icons.theater_comedy_rounded,
          color: Color(0xFF075E4D),
          size: 36,
        ),
      ),
    );
  }
}
