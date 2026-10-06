import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == AppRouter.home || location == '/') return 0;
    if (location.startsWith(AppRouter.carte)) return 1;
    if (location.startsWith(AppRouter.explorer) || location.startsWith(AppRouter.monParcours)) return 2;
    if (location.startsWith(AppRouter.quizList)) return 3;
    if (location.startsWith(AppRouter.profil)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);
    if (currentIndex == index) return;

    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.carte);
        break;
      case 2:
        context.go(AppRouter.explorer);
        break;
      case 3:
        context.go(AppRouter.quizList);
        break;
      case 4:
        context.go(AppRouter.profil);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          // Contenu principal dynamique de la destination courante
          Positioned.fill(child: child),

          // Barre de navigation flottante unique et persistante
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, bottomPadding + 6.0),
            child: _buildFloatingNavigationBar(context, selectedIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigationBar(BuildContext context, int activeIndex) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Accueil',
            isSelected: activeIndex == 0,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.map_rounded,
            label: 'Carte',
            isSelected: activeIndex == 1,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.travel_explore_rounded,
            label: 'Explorer',
            isSelected: activeIndex == 2,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.help_outline_rounded,
            label: 'Quiz',
            isSelected: activeIndex == 3,
          ),
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            isSelected: activeIndex == 4,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF075E4D) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 24 : 23,
              color: isSelected ? Colors.white : const Color(0xFF6C7C77),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

