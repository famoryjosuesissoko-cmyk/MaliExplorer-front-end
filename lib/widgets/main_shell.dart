import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../features/auth/auth_controller.dart';
import '../router/app_router.dart';

/// Shell persistant de navigation principale (5 destinations flottantes).
/// Réactif : pour un promoteur validé, le 4ème onglet (Quiz) est dynamiquement
/// remplacé par "Espace Promoteur", tandis que les touristes, visiteurs et promoteurs
/// en attente ou rejetés conservent la barre standard avec l'onglet "Quiz".
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  bool _isPromoteurValide(AuthState? authState) {
    final user = authState?.currentUserModel;
    if (user != null) {
      return user.isPromoteurValide;
    }
    final role = (AuthService.cachedRole ?? '').toLowerCase();
    final statut = (AuthService.cachedStatutModeration ?? '').toUpperCase();
    return (role.contains('promoteur') || role.contains('partenaire')) &&
        (statut == 'VALIDE' || statut == 'APPROUVE');
  }

  int _calculateSelectedIndex(BuildContext context, bool isPromoteurValide) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location == AppRouter.home || location == '/') return 0;
    if (location.startsWith(AppRouter.carte)) return 1;
    if (location.startsWith(AppRouter.explorer) || location.startsWith(AppRouter.monParcours)) return 2;
    if (isPromoteurValide) {
      if (location.startsWith(AppRouter.promoteurDashboard)) return 3;
    } else {
      if (location.startsWith(AppRouter.quizList)) return 3;
    }
    if (location.startsWith(AppRouter.profil)) return 4;
    return -1;
  }

  void _onItemTapped(int index, BuildContext context, bool isPromoteurValide) {
    final int currentIndex = _calculateSelectedIndex(context, isPromoteurValide);
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
        if (isPromoteurValide) {
          context.go(AppRouter.promoteurDashboard);
        } else {
          context.go(AppRouter.quizList);
        }
        break;
      case 4:
        context.go(AppRouter.profil);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AuthState? authState;
    try {
      authState = ref.watch(authControllerProvider);
    } catch (_) {
      authState = null;
    }
    final bool isPromoteurValide = _isPromoteurValide(authState);
    final int selectedIndex = _calculateSelectedIndex(context, isPromoteurValide);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFF075E4D),
      body: Stack(
        children: [
          // Contenu principal dynamique de la destination courante
          Positioned.fill(child: child),

          // Barre de navigation flottante unique et persistante
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, bottomPadding + 6.0),
            child: _buildFloatingNavigationBar(context, selectedIndex, isDark, isPromoteurValide),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigationBar(
    BuildContext context,
    int activeIndex,
    bool isDark,
    bool isPromoteurValide,
  ) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
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
            isDark: isDark,
            isPromoteurValide: isPromoteurValide,
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.map_rounded,
            label: 'Carte',
            isSelected: activeIndex == 1,
            isDark: isDark,
            isPromoteurValide: isPromoteurValide,
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.travel_explore_rounded,
            label: 'Explorer',
            isSelected: activeIndex == 2,
            isDark: isDark,
            isPromoteurValide: isPromoteurValide,
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: isPromoteurValide
                ? Icons.business_center_rounded
                : Icons.help_outline_rounded,
            label: isPromoteurValide ? 'Espace Promoteur' : 'Quiz',
            isSelected: activeIndex == 3,
            isDark: isDark,
            isPromoteurValide: isPromoteurValide,
          ),
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            isSelected: activeIndex == 4,
            isDark: isDark,
            isPromoteurValide: isPromoteurValide,
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
    required bool isDark,
    required bool isPromoteurValide,
  }) {
    final activeBg = isDark ? AppColors.primaryInteractive : const Color(0xFF075E4D);
    final inactiveColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77);

    final item = InkWell(
      onTap: () => _onItemTapped(index, context, isPromoteurValide),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? (label.length > 8 ? 8 : 12) : 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isSelected ? 24 : 23,
              color: isSelected ? Colors.white : inactiveColor,
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: label.length > 8 ? 11 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return isSelected ? Flexible(child: item) : item;
  }
}

