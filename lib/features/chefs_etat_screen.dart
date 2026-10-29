import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/president_model.dart';
import '../providers/presidents_provider.dart';
import '../router/app_router.dart';

class ChefsEtatScreen extends ConsumerStatefulWidget {
  const ChefsEtatScreen({super.key});

  @override
  ConsumerState<ChefsEtatScreen> createState() => _ChefsEtatScreenState();
}

class _ChefsEtatScreenState extends ConsumerState<ChefsEtatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isShortScreen = MediaQuery.sizeOf(context).height < 600;
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
                  padding: EdgeInsets.fromLTRB(
                    16,
                    isShortScreen ? 8 : 12,
                    16,
                    isShortScreen ? 12 : 20,
                  ),
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Chefs d\'État',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'L\'histoire politique à travers les présidents de la République',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Fiche blanche contenant la liste des présidents
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
                      ref.invalidate(presidentsProvider);
                      try {
                        await ref.read(presidentsProvider.future);
                      } catch (_) {}
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                      child: Column(
                        children: [
                          // Barre de recherche
                          _buildSearchBar(),

                          const SizedBox(height: 18),

                          // Liste des cartes de présidents connectée à Riverpod
                          ref
                              .watch(filteredPresidentsProvider)
                              .when(
                                data: (presidents) {
                                  if (presidents.isEmpty) {
                                    final query = ref.watch(presidentSearchQueryProvider).trim();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 40),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.person_off_rounded,
                                              size: 48,
                                              color: Color(0xFF8B9B95),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              query.isEmpty
                                                  ? 'Aucun président disponible pour le moment.'
                                                  : 'Aucun chef d\'état trouvé.',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
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
                                    children: presidents
                                        .map((p) => _buildPresidentCard(p))
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
                                          'Erreur de chargement des présidents',
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
                                              ref.refresh(presidentsProvider),
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
                ref.read(presidentSearchQueryProvider.notifier).state = val;
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher un chef d\'état...',
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

  Widget _buildPresidentCard(PresidentModel president) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.push(AppRouter.presidentDetail, extra: president),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Photo de profil circulaire avec bordure or sahélien #D6A23A et date centrée
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6A23A), // Or sahélien #D6A23A
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD6A23A).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildPresidentImage(president.displayPhoto, president),
                  ),
                ),
                const SizedBox(width: 14),

                // Informations textuelles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        president.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF075E4D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        president.periodeMandat,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD6A23A),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Description biographique
                      Text(
                        president.biographie,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF6C7C77),
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
                  color: Color(0xFF8B9B95),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresidentImage(String pathOrUrl, PresidentModel president) {
    final localAsset = PresidentModel.getLocalPhoto(president.fullName, president.id);

    if (pathOrUrl.isEmpty) {
      if (localAsset.isNotEmpty) {
        return Image.asset(
          localAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
        );
      }
      return _buildImageFallback();
    }

    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return Image.network(
        pathOrUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (localAsset.isNotEmpty) {
            return Image.asset(
              localAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
            );
          }
          return _buildImageFallback();
        },
      );
    }

    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(
        pathOrUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }

    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFF075E4D).withValues(alpha: 0.15),
      child: const Icon(Icons.person, color: Color(0xFF075E4D), size: 30),
    );
  }
}
