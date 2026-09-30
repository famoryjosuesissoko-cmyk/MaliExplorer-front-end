import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Culturels du Mali'),
        actions: [
          IconButton(
            icon: const Icon(Icons.military_tech, color: AppColors.sahelGold),
            tooltip: 'Mes Badges Bambara',
            onPressed: () => context.push('/badges'),
          ),
        ],
      ),
      body: quizAsync.when(
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const EmptyView(
              title: 'Aucun quiz disponible pour le moment',
              icon: Icons.quiz_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: quizzes.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return DestinationCard(
                title: quiz.nomQuiz,
                subtitle: quiz.description ?? '${quiz.nombreQuestions} questions à relever',
                imageUrl: quiz.imageQuiz,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.sahelGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.sahelGold),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz.points > 0 ? quiz.points : 100} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.sahelGold,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => context.push('/quiz/${quiz.idQuiz}/play'),
              );
            },
          );
        },
        loading: () => const AppLoader(message: 'Chargement des quiz culturels...'),
        error: (err, stack) => AppError(
          message: 'Erreur lors du chargement des quiz.',
          onRetry: () => ref.refresh(quizListProvider),
        ),
      ),
    );
  }
}
