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
                  IconButton(
                    tooltip: 'Vider l\'historique',
                    onPressed: () => _confirmerViderHistorique(context, ref, isDark),
                    icon: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
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
                        error: (err, stack) => _buildErrorView(ref, isDark, err),
                        data: (items) {
                          if (items.isEmpty) {
                            return _buildEmptyView(isDark);
                          }
                          final isOffline = ref.watch(historiqueIsOfflineProvider);
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
                              itemCount: items.length + (isOffline ? 1 : 0),
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (isOffline && index == 0) {
                                  return _buildOfflineBanner(context, isDark);
                                }
                                final itemIndex = isOffline ? index - 1 : index;
                                return _buildHistoriqueItem(context, ref, items[itemIndex], isDark);
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

  Widget _buildHistoriqueItem(BuildContext context, WidgetRef ref, HistoriquePointModel item, bool isDark) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final String formattedDate = item.dateGain != null
        ? dateFormat.format(item.dateGain!)
        : 'Récemment';

    final isQuiz = item.action.toUpperCase().contains('QUIZ');
    final IconData iconData = isQuiz ? Icons.military_tech_rounded : Icons.stars_rounded;

    return Dismissible(
      key: ValueKey(item.idHistorique),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Supprimer cette entrée ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Text('Voulez-vous supprimer « ${item.description ?? item.action} » de votre historique ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler', style: TextStyle(color: Color(0xFF6C7C77))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        final success = await ref.read(historiqueServiceProvider).supprimerItem(item.idHistorique);
        ref.invalidate(userHistoriqueProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Entrée supprimée' : 'Erreur lors de la suppression'),
              backgroundColor: success ? const Color(0xFF075E4D) : const Color(0xFFDC2626),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
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
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFF94A3B8)),
              onPressed: () => _confirmerSupprimerItem(context, ref, item),
              padding: const EdgeInsets.only(left: 4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmerSupprimerItem(BuildContext context, WidgetRef ref, HistoriquePointModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer cette entrée ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Voulez-vous supprimer « ${item.description ?? item.action} » de votre historique ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6C7C77))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(historiqueServiceProvider).supprimerItem(item.idHistorique);
      ref.invalidate(userHistoriqueProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Entrée supprimée avec succès' : 'Échec de la suppression'),
            backgroundColor: success ? const Color(0xFF075E4D) : const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _confirmerViderHistorique(BuildContext context, WidgetRef ref, bool isDark) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 26),
            SizedBox(width: 8),
            Text('Vider l\'historique ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir effacer l\'intégralité de votre historique d\'activités ? Cette action est irréversible.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF6C7C77))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tout effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(historiqueServiceProvider).viderToutHistorique();
      ref.invalidate(userHistoriqueProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Historique vidé avec succès' : 'Échec lors de la réinitialisation de l\'historique'),
            backgroundColor: success ? const Color(0xFF075E4D) : const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildOfflineBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3B2F17) : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE047),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: isDark ? const Color(0xFFFACC15) : const Color(0xFFCA8A04),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Mode hors ligne — Affichage des activités récentes locales. Tirez vers le bas pour synchroniser dès la reconnexion.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFFEF08A) : const Color(0xFF854D0E),
                fontWeight: FontWeight.w500,
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

  Widget _buildErrorView(WidgetRef ref, bool isDark, [Object? error]) {
    final String errorText = error != null ? error.toString() : '';
    final bool isNetworkOrConnection = errorText.contains('Connection') ||
        errorText.contains('SocketException') ||
        errorText.contains('TimeoutException') ||
        errorText.contains('ClientException');
    final bool isUnauthorized = errorText.contains('401') || errorText.contains('403');
    final String explanation = isUnauthorized
        ? 'Session expirée ou non reconnue par Spring Boot. Déconnectez-vous puis reconnectez-vous depuis votre profil.'
        : isNetworkOrConnection
            ? 'Impossible de joindre Spring Boot (127.0.0.1:8080). Assurez-vous d\'exécuter dans votre terminal : adb reverse tcp:8080 tcp:8080'
            : 'Erreur lors de la récupération de vos points : ${errorText.replaceAll('Exception:', '').trim()}';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnauthorized ? Icons.lock_clock_rounded : Icons.cloud_off_rounded,
              size: 52,
              color: AppColors.error,
            ),
            const SizedBox(height: 14),
            Text(
              'Impossible de charger l\'historique',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => ref.invalidate(userHistoriqueProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
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

