import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/user_model.dart';

/// Bandeau de bienvenue personnalisé sur l'écran d'accueil.
class HomeBanner extends StatelessWidget {
  final UserModel? user;

  const HomeBanner({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryForest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                user != null && user!.prenom.isNotEmpty ? user!.prenom[0].toUpperCase() : 'M',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null ? 'I ni ce, ${user!.prenom} !' : 'I ni ce, Voyageur !',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user != null
                        ? '${user!.role.displayName} • ${user!.points} pts'
                        : 'Explorez la culture et l\'histoire du Mali',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
