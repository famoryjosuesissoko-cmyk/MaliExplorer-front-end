import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../models/president_model.dart';
import '../providers/favoris_provider.dart';
import '../router/app_router.dart';

class PresidentDetailScreen extends ConsumerWidget {
  final PresidentModel? president;

  const PresidentDetailScreen({super.key, this.president});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = president ?? PresidentModel.chronologicalPresidents.first;
    final allPresidents = PresidentModel.chronologicalPresidents;
    final currentIndex = allPresidents.indexWhere((p) => p.id == current.id);

    final PresidentModel? prevPresident =
        currentIndex > 0 ? allPresidents[currentIndex - 1] : null;
    final PresidentModel? nextPresident =
        currentIndex >= 0 && currentIndex < allPresidents.length - 1
            ? allPresidents[currentIndex + 1]
            : null;

    final isAlive = current.dateDeces == null;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          // 1. En-tête vert avec la photo et le titre
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Barre supérieure avec bouton retour
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD6A23A).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          current.periodeMandat,
                          style: const TextStyle(
                            color: Color(0xFFF9DC96),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              ref.watch(favorisNotifierProvider);
                              final isFav = ref
                                  .read(favorisNotifierProvider.notifier)
                                  .isFavorite(current.fullName);
                              return IconButton(
                                onPressed: () async {
                                  await ref
                                      .read(favorisNotifierProvider.notifier)
                                      .toggleFavori(
                                        titre: current.fullName,
                                        categorie:
                                            'Chef d\'État (${current.periodeMandat})',
                                        imageUrl: current.displayPhoto,
                                        route: AppRouter.presidentDetail,
                                        referenceId: current.id,
                                      );
                                },
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFav
                                      ? const Color(0xFFE53935)
                                      : Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${current.fullName} fait partie du patrimoine républicain du Mali.'),
                                  backgroundColor: const Color(0xFF075E4D),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Profil central du président
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: Column(
                    children: [
                      // Photo circulaire avec bordure dorée
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD6A23A),
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildPresidentImage(current.displayPhoto),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nom complet
                      Text(
                        current.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Titre ou rôle officiel
                      if (current.titre != null)
                        Text(
                          current.titre!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.25,
                          ),
                        ),
                    ],
                  ),
                ),

                // 2. Fiche blanche détaillée déroulante
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7F8F5),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Grille des repères clés (Naissance, Lieu, Mandat, Statut)
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.cake_rounded,
                                  title: 'Naissance',
                                  value: current.dateNaissance ?? 'Non renseignée',
                                  color: const Color(0xFF075E4D),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.place_rounded,
                                  title: 'Origine',
                                  value: current.lieuNaissance ?? 'Mali',
                                  color: const Color(0xFFD6A23A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.date_range_rounded,
                                  title: 'Mandat',
                                  value: current.periodeMandat,
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: isAlive ? Icons.favorite_rounded : Icons.history_edu_rounded,
                                  title: 'Statut',
                                  value: isAlive ? 'En vie' : 'Mémoire nationale',
                                  color: isAlive ? const Color(0xFF2E7D32) : const Color(0xFF6C7C77),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 2. Citation emblématique (si présente)
                          if (current.citation != null && current.citation!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF075E4D).withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF075E4D).withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.format_quote_rounded,
                                    color: Color(0xFF075E4D),
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      current.citation!,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF16332D),
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 3. Biographie détaillée
                          const Text(
                            'Biographie & Parcours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF075E4D),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            ),
                            child: Text(
                              current.biographie,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF4A5550),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 4. Faits marquants & Réalisations
                          if (current.faitsMarquants != null && current.faitsMarquants!.isNotEmpty) ...[
                            const Text(
                              'Faits marquants & Réalisations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF075E4D),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(current.faitsMarquants!.length, (index) {
                              final fait = current.faitsMarquants![index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFD6A23A).withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF075E4D),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          fait,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF2C3E37),
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 24),
                          ],

                          // 5. Navigation Chronologique (Précédent / Suivant)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (prevPresident != null)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      side: const BorderSide(color: Color(0xFF075E4D)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.pushReplacement(
                                        AppRouter.presidentDetail,
                                        extra: prevPresident,
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF075E4D)),
                                    label: Text(
                                      prevPresident.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF075E4D),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              const SizedBox(width: 12),
                              if (nextPresident != null)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                      backgroundColor: const Color(0xFF075E4D),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      context.pushReplacement(
                                        AppRouter.presidentDetail,
                                        extra: nextPresident,
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                    label: Text(
                                      nextPresident.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildPresidentImage(String pathOrUrl) {
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFF075E4D).withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: Colors.white, size: 50),
        ),
      );
    }
    return Image.network(
      pathOrUrl,
      width: 110,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF075E4D).withValues(alpha: 0.2),
        child: const Icon(Icons.person, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16332D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

