import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class EthniesListScreen extends StatefulWidget {
  const EthniesListScreen({super.key});

  @override
  State<EthniesListScreen> createState() => _EthniesListScreenState();
}

class _EthniesListScreenState extends State<EthniesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  final List<EthnicityListItem> _ethnicities = [
    EthnicityListItem(
      title: 'Dogon',
      description:
          'Célèbres pour leur cosmogonie complexe, leurs masques spectaculaires et leur architecture unique.',
      imageUrl:
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=800&auto=format&fit=crop',
    ),
    EthnicityListItem(
      title: 'Bambara',
      description:
          'Majoritaires, historiquement liés au grand empire de Ségou, réputés pour leur art et contes rituels.',
      imageUrl:
          'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=800&auto=format&fit=crop',
    ),
    EthnicityListItem(
      title: 'Peul',
      description:
          'Pasteurs et nomades réputés pour leur élégance, leurs parures et leur riche tradition orale.',
      imageUrl:
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=800&auto=format&fit=crop',
    ),
    EthnicityListItem(
      title: 'Touareg',
      description:
          'Les "hommes bleus du désert", gardiens des oasis sahariennes et maîtres de la musique Tichumaren.',
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

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

                        // Grandes cartes d'ethnies
                        ..._ethnicities.map((eth) => _buildEthnicityCard(eth)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation inférieure
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, MediaQuery.of(context).padding.bottom + 6.0),
            child: _buildBottomNavigationBar(),
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

  Widget _buildEthnicityCard(EthnicityListItem eth) {
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
        child: InkWell(
          onTap: () {
            // Navigation vers la page détail d'ethnie (Les Dogons)
            context.push(AppRouter.ethnicityDetail);
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image panoramique supérieure
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                child: Image.network(
                  eth.imageUrl,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 145,
                    color: const Color(0xFF0E8F76).withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.theater_comedy_rounded,
                      color: Color(0xFF075E4D),
                      size: 36,
                    ),
                  ),
                ),
              ),

              // Contenu textuel en bas
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eth.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF075E4D),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      eth.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6C7C77),
                        height: 1.4,
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Accueil', isSelected: _selectedNavIndex == 0, onTap: () => context.go(AppRouter.home)),
          _buildNavItem(1, Icons.menu_book_rounded, 'Carte', isSelected: _selectedNavIndex == 1),
          _buildNavItem(2, Icons.explore_outlined, 'Découvrir', isSelected: _selectedNavIndex == 2),
          _buildNavItem(3, Icons.help_outline_rounded, 'Quiz', isSelected: _selectedNavIndex == 3),
          _buildNavItem(4, Icons.person_outline_rounded, 'Profil', isSelected: _selectedNavIndex == 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {required bool isSelected, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF075E4D),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              )
            else
              Icon(icon, color: const Color(0xFF6C7C77), size: 22),
            const SizedBox(height: 2.5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF075E4D) : const Color(0xFF6C7C77),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EthnicityListItem {
  final String title;
  final String description;
  final String imageUrl;

  EthnicityListItem({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
