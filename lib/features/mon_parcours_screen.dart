import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class MonParcoursScreen extends StatefulWidget {
  const MonParcoursScreen({super.key});

  @override
  State<MonParcoursScreen> createState() => _MonParcoursScreenState();
}

class _MonParcoursScreenState extends State<MonParcoursScreen> {
  int _selectedNavIndex = 2; // Découvrir / Parcours actif

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. En-tête vert
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRouter.home);
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
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Mon parcours',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche avec tout le contenu
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte utilisateur & progression
                        _buildUserProfileProgressCard(),

                        const SizedBox(height: 18),

                        // 3 Statistiques
                        _buildStatsRow(),

                        const SizedBox(height: 24),

                        // Section Mes Badges
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mes Badge',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16332D),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Voir tout',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF075E4D),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Liste des 3 Badges de niveau
                        _buildBadgesRow(),

                        const SizedBox(height: 24),

                        // Section Récompense spéciale
                        const Text(
                          'Recompence speciale',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16332D),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 3 Récompenses spéciales
                        _buildSpecialRewardsRow(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation inférieure avec bouton central surélevé
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

  /// Carte utilisateur avec Avatar, Nom, Tags et Jauge de points
  Widget _buildUserProfileProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nom et Badges de statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Famory Sissoko',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildTag('Fasoden'),
                        const SizedBox(width: 8),
                        _buildTag('Niveau 2'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 800 / 1500,
              minHeight: 8,
              backgroundColor: Color(0xFFF1F5F3),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2B544)),
            ),
          ),
          const SizedBox(height: 5),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '800/1500 points',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2B544),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Ligne des 3 statistiques
  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF2B544),
            value: '800',
            label: 'Points',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF075E4D),
            value: '12',
            label: 'Quiz realisés',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFF2B544),
            value: '5',
            label: 'Badges\ndébloqués',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C7C77),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne des 3 Badges de niveau (Kalanden, Fasoden, Fasoden Yirize)
  Widget _buildBadgesRow() {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            title: 'Kalanden',
            level: 'Niveau 1',
            points: '0 - 499 points',
            color: const Color(0xFFD6A23A),
            isUnlocked: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            title: 'Fasoden',
            level: 'Niveau 2',
            points: '500 - 1499 points',
            color: const Color(0xFF94A3B8),
            isUnlocked: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            title: 'Fasoden Yunze',
            level: 'Niveau 3',
            points: '1500+ points',
            color: const Color(0xFFF2B544),
            isUnlocked: false,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String level,
    required String points,
    required Color color,
    required bool isUnlocked,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône médaille / badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.military_tech_rounded,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            level,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C7C77),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            points,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne des 3 Récompenses spéciales
  Widget _buildSpecialRewardsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.history_edu_rounded,
            title: 'Expert en Histoire',
            iconColor: const Color(0xFF6C7C77),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.soup_kitchen_rounded,
            title: 'Ambassadeur\nGastronomie',
            iconColor: const Color(0xFFF2B544),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.explore_outlined,
            title: 'Explorateur du\nMali',
            iconColor: const Color(0xFF6C7C77),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRewardItem({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7F8F5),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16332D),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de navigation inférieure avec bouton central
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
          // Bouton central surélevé "Découvrir"
          _buildCenterNavItem(2, Icons.explore_rounded, 'Découvrir', isSelected: _selectedNavIndex == 2),
          _buildNavItem(3, Icons.help_outline_rounded, 'Quiz', isSelected: _selectedNavIndex == 3, onTap: () => context.push(AppRouter.quizList)),
          _buildNavItem(4, Icons.person_outline_rounded, 'Profil', isSelected: _selectedNavIndex == 4, onTap: () => context.push(AppRouter.profil)),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(int index, IconData icon, String label, {required bool isSelected}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF075E4D),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF075E4D),
              ),
            ),
          ],
        ),
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
