import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class ChefsEtatScreen extends StatefulWidget {
  const ChefsEtatScreen({super.key});

  @override
  State<ChefsEtatScreen> createState() => _ChefsEtatScreenState();
}

class _ChefsEtatScreenState extends State<ChefsEtatScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedNavIndex = 0;

  final List<PresidentItem> _presidents = [
    PresidentItem(
      name: 'Modibo Keïta',
      period: '1960 - 1968',
      description:
          'Père de l\'indépendance malienne, fervent défenseur du panafricanisme et du socialisme africain.',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
    ),
    PresidentItem(
      name: 'Moussa Traoré',
      period: '1968 - 1991',
      description:
          'Militaire de carrière, au pouvoir durant deux décennies caractérisées par de profondes mutations structurelles.',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
    ),
    PresidentItem(
      name: 'Alpha Oumar Konaré',
      period: '1992 - 2002',
      description:
          'Premier président de la IIIe République, reconnu pour son engagement démocratique et culturel.',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400&auto=format&fit=crop',
    ),
    PresidentItem(
      name: 'Amadou Toumani Touré',
      period: '2002 - 2012',
      description:
          'Surnommé "ATT", artisan de la transition démocratique et grand bâtisseur d\'infrastructures.',
      imageUrl:
          'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=400&auto=format&fit=crop',
    ),
    PresidentItem(
      name: 'Ibrahim Boubacar Keïta',
      period: '2013 - 2020',
      description:
          'Connu sous le nom de "IBK", engagé pour le rayonnement diplomatique et la préservation de l\'unité nationale.',
      imageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop',
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
                            onPressed: () => context.pop(),
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
                              'Chefs d\'État',
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
                          'L\'histoire politique à travers les présidents de la République',
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

              // Fiche blanche contenant la liste des présidents
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

                        // Liste des cartes de présidents
                        ..._presidents.map((p) => _buildPresidentCard(p)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation inférieure flottante
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

  Widget _buildPresidentCard(PresidentItem president) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Photo de profil circulaire
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.2), width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                president.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF075E4D).withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: Color(0xFF075E4D), size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informations textuelles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom & Années de mandat
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        president.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF075E4D),
                        ),
                      ),
                    ),
                    Text(
                      president.period,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828), // Rouge bordeaux
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description biographique
                Text(
                  president.description,
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
        ],
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

class PresidentItem {
  final String name;
  final String period;
  final String description;
  final String imageUrl;

  PresidentItem({
    required this.name,
    required this.period,
    required this.description,
    required this.imageUrl,
  });
}
