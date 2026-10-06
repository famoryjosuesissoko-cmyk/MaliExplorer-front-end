import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

/// Barre de navigation inférieure commune réutilisable dans toute l'application.
/// L'onglet actif peut être déterminé automatiquement via la route courante ou spécifié par `currentIndex`.
class AppBottomNav extends StatelessWidget {
  final int? currentIndex;

  const AppBottomNav({super.key, this.currentIndex});

  int _resolveIndex(BuildContext context) {
    if (currentIndex != null) return currentIndex!;
    final location = GoRouterState.of(context).uri.toString();
    if (location == AppRouter.home || location == '/') return 0;
    if (location.startsWith('/carte')) return 1;
    if (location.startsWith(AppRouter.monParcours)) return 2;
    if (location.startsWith(AppRouter.quizList) || location.startsWith('/quiz')) return 3;
    if (location.startsWith(AppRouter.profil)) return 4;
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _resolveIndex(context);

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
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home_rounded,
            label: 'Accueil',
            isSelected: activeIndex == 0,
            onTap: () {
              if (activeIndex != 0) context.go(AppRouter.home);
            },
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.menu_book_rounded,
            label: 'Carte',
            isSelected: activeIndex == 1,
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Carte interactive : bientôt disponible !'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF075E4D),
                ),
              );
            },
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.explore_outlined,
            label: 'Découvrir',
            isSelected: activeIndex == 2,
            onTap: () {
              if (activeIndex != 2) context.go(AppRouter.monParcours);
            },
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.help_outline_rounded,
            label: 'Quiz',
            isSelected: activeIndex == 3,
            onTap: () {
              if (activeIndex != 3) context.go(AppRouter.quizList);
            },
          ),
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            isSelected: activeIndex == 4,
            onTap: () {
              if (activeIndex != 4) context.go(AppRouter.profil);
            },
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
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
                  color: isSelected
                      ? const Color(0xFF075E4D)
                      : const Color(0xFF6C7C77),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
