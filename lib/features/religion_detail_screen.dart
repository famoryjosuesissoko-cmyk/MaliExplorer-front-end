import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/religion_model.dart';
import '../providers/favoris_provider.dart';
import '../router/app_router.dart';

class ReligionDetailScreen extends ConsumerWidget {
  final ReligionModel? religion;

  const ReligionDetailScreen({super.key, this.religion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size screenSize = MediaQuery.of(context).size;
    final double heroHeight = (screenSize.height * 0.36).clamp(240.0, 320.0);
    final current = religion ?? ReligionModel.defaultReligions.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Bannière Hero d'en-tête
                _buildHeroHeader(context, ref, current, heroHeight),

                // 2. Fiche blanche détaillée avec coins arrondis
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre & Catégorie
                        Text(
                          current.nom,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (current.categorie != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            current.categorie!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD6A23A),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Section 1 : Données Statistiques RIGOUREUSES & SOURCES
                        _buildStatisticsSection(current),

                        const SizedBox(height: 22),

                        // Section 2 : Présentation & Vue générale
                        _buildSectionCard(
                          icon: Icons.info_outline_rounded,
                          title: 'Présentation générale',
                          content: current.description,
                        ),

                        const SizedBox(height: 16),

                        // Section 3 : Histoire au Mali
                        _buildSectionCard(
                          icon: Icons.history_edu_rounded,
                          title: 'Histoire & Enracinement au Mali',
                          content: current.histoire,
                        ),

                        const SizedBox(height: 16),

                        // Section 4 : Branches, Confréries & Courants
                        if (current.branches != null && current.branches!.trim().isNotEmpty) ...[
                          _buildSectionCard(
                            icon: Icons.alt_route_rounded,
                            title: 'Principaux courants & branches documentés',
                            content: current.branches!,
                            isHighlighted: true,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Section 5 : Pratiques religieuses & Rituels
                        if (current.pratiques.trim().isNotEmpty) ...[
                          _buildSectionCard(
                            icon: Icons.psychology_rounded,
                            title: 'Pratiques & Dévotions',
                            content: current.pratiques,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Section 6 : Grandes Fêtes & Célébrations
                        if (current.fetes.trim().isNotEmpty) ...[
                          _buildSectionCard(
                            icon: Icons.celebration_rounded,
                            title: 'Fêtes & Célébrations sacrées',
                            content: current.fetes,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Section 7 : Lieux emblématiques de culte
                        if (current.lieuxDeCulte.trim().isNotEmpty) ...[
                          _buildSectionCard(
                            icon: Icons.mosque_rounded,
                            title: 'Édifices & Lieux de culte majeurs',
                            content: current.lieuxDeCulte,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Section 8 : Répartition géographique
                        if (current.regionsConcernees.trim().isNotEmpty) ...[
                          _buildSectionCard(
                            icon: Icons.map_rounded,
                            title: 'Régions & Présence géographique',
                            content: current.regionsConcernees,
                          ),
                        ],
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

  Widget _buildHeroHeader(BuildContext context, WidgetRef ref, ReligionModel current, double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildHeroImage(current.imageUrl),
          // Gradient pour visibilité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
          // Boutons navigation et favori
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRouter.religionsList);
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
                  Builder(
                    builder: (ctx) {
                      ref.watch(favorisNotifierProvider);
                      final isFav = ref.read(favorisNotifierProvider.notifier).isFavorite(current.nom);
                      return InkWell(
                        onTap: () async {
                          await ref.read(favorisNotifierProvider.notifier).toggleFavori(
                                titre: current.nom,
                                categorie: 'Religion & Spiritualité',
                                imageUrl: current.imageUrl,
                                route: AppRouter.religionDetail,
                                referenceId: current.id,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF075E4D)),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF075E4D)),
    );
  }

  Widget _buildStatisticsSection(ReligionModel r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6A23A).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.analytics_rounded, color: Color(0xFF075E4D), size: 20),
              SizedBox(width: 8),
              Text(
                'Données statistiques & Démographie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Proportion nationale', r.proportionPopulation),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem('Fidèles estimés', r.nombrePratiquantsEstime),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            'Source : ${r.sourceStatistiques} (${r.anneeStatistiques})',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C7C77),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Méthode : ${r.methodologieStatistiques}',
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF8B9B95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6C7C77)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF075E4D),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    bool isHighlighted = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? const Color(0xFF075E4D).withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.06),
        ),
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
              Icon(icon, color: const Color(0xFF075E4D), size: 19),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF075E4D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E38),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

