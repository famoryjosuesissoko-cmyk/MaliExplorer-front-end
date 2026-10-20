import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/religion_model.dart';
import '../providers/home_extended_providers.dart';
import '../router/app_router.dart';

class ReligionsListScreen extends ConsumerStatefulWidget {
  const ReligionsListScreen({super.key});

  @override
  ConsumerState<ReligionsListScreen> createState() =>
      _ReligionsListScreenState();
}

class _ReligionsListScreenState extends ConsumerState<ReligionsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final religionsAsync = ref.watch(religionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // En-tête vert solennel
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
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRouter.explorer);
                              }
                            },
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
                              'Religions & Spiritualités',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          'Panorama encyclopédique, cosmogonies et dialogue interreligieux au Mali',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu blanc déroulant
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: RefreshIndicator(
                    color: const Color(0xFF075E4D),
                    onRefresh: () async {
                      ref.invalidate(religionsProvider);
                      await ref.read(religionsProvider.future);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Barre de recherche locale
                        _buildSearchBar(),

                        const SizedBox(height: 18),

                        // Encadré introductif sur la tolérance malienne
                        _buildIntroBanner(),

                        const SizedBox(height: 18),

                        // Liste des fiches de religions
                        religionsAsync.when(
                          data: (religions) {
                            final filtered = religions.where((r) {
                              if (_searchQuery.isEmpty) return true;
                              final q = _searchQuery.toLowerCase();
                              return r.nom.toLowerCase().contains(q) ||
                                  (r.categorie?.toLowerCase().contains(q) ??
                                      false) ||
                                  r.description.toLowerCase().contains(q) ||
                                  (r.branches?.toLowerCase().contains(q) ??
                                      false);
                            }).toList();

                            if (filtered.isEmpty) {
                              if (_searchQuery.isNotEmpty) {
                                return _buildSearchEmptyState();
                              }
                              return _buildEmptyState();
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final religion = filtered[index];
                                return _buildReligionCard(religion);
                              },
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(
                                color: Color(0xFF075E4D),
                              ),
                            ),
                          ),
                          error: (_, _) => _buildErrorState(),
                        ),
                      ],
                    ),
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
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: const InputDecoration(
                hintText: 'Rechercher une religion, un courant, une fête...',
                hintStyle: TextStyle(
                  color: Color(0xFF8B9B95),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Color(0xFF8B9B95),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF075E4D).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF075E4D).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.handshake_rounded,
              color: Color(0xFF075E4D),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tradition de concorde et vivre-ensemble',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Au Mali, la tolérance séculaire et la parenté à plaisanterie (Sinankunya) créent une harmonie exceptionnelle où les fêtes sacrées sont partagées entre toutes les confessions.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2C3E38),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReligionCard(ReligionModel religion) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push(AppRouter.religionDetail, extra: religion),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Vignette avec bordure soignée
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                        child: _buildThumbnail(religion.imageUrl, religion.nom),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            religion.nom,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF075E4D),
                            ),
                          ),
                          if (religion.categorie != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              religion.categorie!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD6A23A),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          // Badge proportion statistique
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF075E4D,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              religion.proportionPopulation,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF8B9B95),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  religion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C7C77),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sélectionne dynamiquement l'icône de culte appropriée selon la tradition spirituelle
  IconData _getFaithIcon(String nom) {
    final lower = nom.toLowerCase();
    if (lower.contains('islam') || lower.contains('musulm')) {
      return Icons.mosque_rounded;
    } else if (lower.contains('christ') ||
        lower.contains('cathol') ||
        lower.contains('protest') ||
        lower.contains('église')) {
      return Icons.church_rounded;
    } else if (lower.contains('animis') ||
        lower.contains('tradition') ||
        lower.contains('ancêtre') ||
        lower.contains('mandé') ||
        lower.contains('dogon')) {
      return Icons.nature_people_rounded;
    }
    return Icons.account_balance_rounded;
  }

  Widget _buildThumbnail(String url, String religionNom) {
    final fallbackAsset = ReligionModel.getLocalPhoto(religionNom);
    final fallbackIcon = _getFaithIcon(religionNom);

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(fallbackIcon, color: const Color(0xFF075E4D), size: 30),
          );
        },
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            fallbackIcon,
            color: const Color(0xFF075E4D),
            size: 30,
          ),
        ),
      );
    }
    return Image.asset(
      url.isNotEmpty ? url : fallbackAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(fallbackIcon, color: const Color(0xFF075E4D), size: 30),
      ),
    );
  }

  /// État vide informatif officiel lorsqu'aucune religion n'est publiée
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF075E4D).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.temple_buddhist_rounded,
              size: 44,
              color: Color(0xFF075E4D),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Aucune religion répertoriée pour le moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF075E4D),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les données sur les religions et spiritualités du Mali apparaîtront ici dès leur publication administrative.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6C7C77),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(religionsProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E4D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  /// État vide lorsque la recherche locale ne trouve aucun résultat
  Widget _buildSearchEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD6A23A).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 38,
              color: Color(0xFFD6A23A),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat correspondant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF075E4D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aucune tradition ou religion ne correspond à « $_searchQuery ».',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6C7C77),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF075E4D),
              side: const BorderSide(color: Color(0xFF075E4D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('Effacer la recherche'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE53935),
            size: 36,
          ),
          const SizedBox(height: 10),
          const Text('Impossible de charger les données.'),
          TextButton(
            onPressed: () => ref.refresh(religionsProvider),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
