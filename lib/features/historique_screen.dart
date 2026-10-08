import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/services/historique_service.dart';
import '../features/auth/auth_controller.dart';
import '../models/historique_point_model.dart';
import '../router/app_router.dart';

class HistoriqueScreen extends ConsumerWidget {
  const HistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isAuthenticated = ref.watch(authServiceProvider).currentUser != null ||
        ref.watch(authControllerProvider).isAuthenticated;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert
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
                        context.go(AppRouter.profil);
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
                        'Historique d\'activités',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
          ),

          // Fiche de contenu
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: !isAuthenticated
                  ? _buildUnauthenticatedView(context, isDark)
                  : ref.watch(userHistoriqueProvider).when(
                        loading: () => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF075E4D)),
                        ),
                        error: (err, stack) => _buildErrorView(ref, isDark),
                        data: (items) {
                          if (items.isEmpty) {
                            return _buildEmptyView(isDark);
                          }
                          return RefreshIndicator(
                            color: const Color(0xFF075E4D),
                            onRefresh: () async {
                              ref.invalidate(userHistoriqueProvider);
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                              itemCount: items.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildHistoriqueItem(items[index], isDark);
                              },
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoriqueItem(HistoriquePointModel item, bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedDate = item.dateGain != null
        ? dateFormat.format(item.dateGain!)
        : 'Récemment';

    final isQuiz = item.action.toUpperCase().contains('QUIZ');
    final IconData iconData = isQuiz ? Icons.military_tech_rounded : Icons.stars_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF332A15) : const Color(0xFFFFF9E6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: const Color(0xFFF2B544),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description ?? (isQuiz ? 'Quiz complété' : 'Activité culturelle'),
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF134E42) : const Color(0xFFE8F5F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${item.pointsGagnes} pts',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 52,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune activité pour le moment',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Participez à des quiz culturels pour cumuler des points et débloquer des badges Bambara !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger l\'historique',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => ref.invalidate(userHistoriqueProvider),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 52,
                color: Color(0xFF075E4D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connexion requise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connectez-vous pour consulter l\'historique de vos points et de vos badges obtenus.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => context.push(AppRouter.login),
              child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

