import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/auth_service.dart';
import '../features/auth/auth_controller.dart';
import '../models/user_model.dart';
import '../router/app_router.dart';

/// Bannière persistante indiquant le statut de modération du compte promoteur :
/// - EN_ATTENTE (en cours d'examen)
/// - VALIDE (publication directe accordée)
/// - REJETE (non retenu, accès visiteur maintenu)
class PromoteurStatusBanner extends ConsumerWidget {
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const PromoteurStatusBanner({
    super.key,
    required this.isDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userMap = authState.user;
    final userModel = authState.userModel;

    final String rawRole = (userModel?.role.name ??
            userMap?['role'] ??
            userMap?['roleName'] ??
            AuthService.cachedRole ??
            '')
        .toString()
        .toLowerCase();

    final bool isPromoteur = rawRole.contains('promoteur') ||
        (userModel != null && userModel.role == UserRole.promoteur);
    final bool isGuide = rawRole.contains('guide') ||
        (userModel != null && userModel.role == UserRole.guide);

    // Si l'utilisateur n'est ni promoteur ni guide, on n'affiche rien
    if (!isPromoteur && !isGuide) {
      return const SizedBox.shrink();
    }

    final String statutModeration = (userModel?.statutModeration ??
            userMap?['statutModeration'] ??
            AuthService.cachedStatutModeration ??
            'EN_ATTENTE')
        .toString()
        .toUpperCase();

    final bool isValide =
        (userModel?.isPromoteurValide == true || userModel?.isGuideValide == true) ||
        (statutModeration == 'VALIDE' || statutModeration == 'APPROUVE');
    final bool isRejete =
        (userModel?.isPromoteurRejete == true || userModel?.isGuideRejete == true) ||
        (statutModeration == 'REJETE' || statutModeration == 'REFUSE');

    final Color bgColor = isValide
        ? (isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
            : const Color(0xFFECFDF5))
        : isRejete
            ? (isDark
                ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                : const Color(0xFFFEF2F2))
            : (isDark
                ? const Color(0xFF78350F).withValues(alpha: 0.35)
                : const Color(0xFFFFFBEB));

    final Color borderColor = isValide
        ? (isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0))
        : isRejete
            ? (isDark ? const Color(0xFFDC2626) : const Color(0xFFFECACA))
            : (isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A));

    final Color textColor = isValide
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : isRejete
            ? (isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C))
            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309));

    final IconData iconData = isValide
        ? Icons.verified_rounded
        : isRejete
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;

    final String title = isPromoteur
        ? (isValide
            ? 'Compte promoteur validé'
            : isRejete
                ? 'Demande promoteur non retenue'
                : 'Dossier promoteur en cours d\'examen')
        : (isValide
            ? 'Compte guide certifié validé'
            : isRejete
                ? 'Candidature guide non retenue'
                : 'Dossier guide en cours d\'examen');

    final String message = isPromoteur
        ? (isValide
            ? 'Votre compte promoteur est validé. Vous bénéficiez de la publication directe de vos événements culturels.'
            : isRejete
                ? 'Votre demande de statut promoteur n\'a pas été validée. Vous conservez votre accès visiteur complet aux contenus culturels.'
                : 'Votre dossier a bien été soumis. Il sera examiné par notre équipe. En attendant, vous pouvez continuer à utiliser l\'application en tant que visiteur.')
        : (isValide
            ? 'Votre compte guide certifié est validé. Vous bénéficiez désormais de l\'accès à votre espace guide et de la visibilité auprès des visiteurs.'
            : isRejete
                ? 'Votre candidature de guide n\'a pas été retenue. Vous conservez votre accès visiteur complet aux contenus de l\'application.'
                : 'Votre dossier a bien été soumis. Il sera examiné par notre équipe. En attendant, vous pouvez continuer à utiliser l\'application en tant que visiteur.');

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: textColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: isDark ? Colors.white70 : const Color(0xFF374151),
                  ),
                ),
                if (isValide) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => context.push(AppRouter.promoteurDashboard),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Accéder à mon espace',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 14, color: textColor),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
