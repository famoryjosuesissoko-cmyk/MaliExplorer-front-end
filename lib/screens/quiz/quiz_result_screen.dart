import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/quiz_model.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResultModel result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résultats du Quiz')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: (result.reussi ? AppColors.success : AppColors.warning).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result.reussi ? Icons.emoji_events : Icons.military_tech,
                    size: 50,
                    color: result.reussi ? AppColors.sahelGold : AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                result.reussi ? 'Félicitations !' : 'Bonne tentative !',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
              ),
              const SizedBox(height: 4),
              Text(
                result.nomQuiz,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.lg),

              // Carte de Score
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Score', '${result.scoreTotalObtenu}/${result.scoreMaxPossible}'),
                        _buildStat('Réussite', '${result.pourcentage.toStringAsFixed(0)}%'),
                        _buildStat('Points gagnés', '+${result.pointsGagnesActivite} pts', color: AppColors.sahelGold),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    const Divider(),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Total des points : ${result.totalPointsUtilisateur} pts',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryForest),
                    ),
                    if (result.badgeActuel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Badge actuel : ${result.badgeActuel}',
                        style: const TextStyle(fontSize: 14, color: AppColors.sahelGold, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              AppButton(
                text: 'Voir mes Badges Bambara',
                icon: Icons.military_tech,
                color: AppColors.sahelGold,
                onPressed: () => context.push('/badges'),
              ),
              const SizedBox(height: AppDimensions.sm),

              AppButton(
                text: 'Retour à l\'accueil',
                isOutlined: true,
                color: AppColors.primaryForest,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color color = AppColors.textPrimary}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
