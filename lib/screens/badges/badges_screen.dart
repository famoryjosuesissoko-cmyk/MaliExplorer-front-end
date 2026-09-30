import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/badge_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/badge_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressionAsync = ref.watch(userProgressionProvider);
    final authState = ref.watch(authProvider);
    final userPoints = authState.user?.points ?? 0;
    final badges = BadgeModel.defaultBadges(userPoints);

    return Scaffold(
      appBar: AppBar(title: const Text('Badges Bambara')),
      body: progressionAsync.when(
        data: (progression) {
          final currentPoints = progression?.points ?? userPoints;
          final currentBadge = progression?.badge ?? 'Kalanden';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  color: AppColors.primaryForest,
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium, size: 60, color: AppColors.sahelGold),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'Badge Actuel : $currentBadge',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total de vos points : $currentPoints pts',
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      if (progression?.pointsToNextBadge != null && progression!.pointsToNextBadge! > 0) ...[
                        const SizedBox(height: AppDimensions.md),
                        LinearProgressIndicator(
                          value: progression.progression,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sahelGold),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Encore ${progression.pointsToNextBadge} pts pour atteindre ${progression.nextBadge}',
                          style: const TextStyle(fontSize: 12, color: AppColors.sahelGold),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                const Text(
                  'Ordre des Badges de Savoir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppDimensions.md),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badges.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    final isUnlocked = currentPoints >= badge.seuilPoints;

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        side: BorderSide(
                          color: isUnlocked ? AppColors.sahelGold : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isUnlocked
                              ? AppColors.sahelGold.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                          child: Icon(
                            isUnlocked ? Icons.verified : Icons.lock_outline,
                            color: isUnlocked ? AppColors.sahelGold : Colors.grey,
                          ),
                        ),
                        title: Text(
                          badge.nom,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                          ),
                        ),
                        subtitle: Text(
                          badge.description,
                          style: TextStyle(fontSize: 12, color: isUnlocked ? AppColors.textSecondary : AppColors.textMuted),
                        ),
                        trailing: Text(
                          '${badge.seuilPoints} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? AppColors.primaryForest : AppColors.textMuted,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoader(message: 'Chargement de vos badges...'),
        error: (err, stack) => AppError(
          message: 'Erreur de chargement des badges.',
          onRetry: () => ref.refresh(userProgressionProvider),
        ),
      ),
    );
  }
}
