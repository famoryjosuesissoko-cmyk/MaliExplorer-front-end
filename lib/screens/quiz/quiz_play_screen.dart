import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/quiz/quiz_timer_widget.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final int quizId;

  const QuizPlayScreen({super.key, required this.quizId});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  Timer? _timer;
  int _secondsLeft = 30;
  static const int _totalDuration = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _totalDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        if (mounted) setState(() => _secondsLeft--);
      } else {
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    final playState = ref.read(quizPlayProvider(widget.quizId));
    final quiz = playState.quiz;
    if (quiz != null && playState.currentQuestionIndex < quiz.questions.length) {
      final currentQuestion = quiz.questions[playState.currentQuestionIndex];
      _answerQuestion(currentQuestion.idQuestion, '');
    }
  }

  void _answerQuestion(int questionId, String proposition) async {
    final notifier = ref.read(quizPlayProvider(widget.quizId).notifier);
    notifier.selectAnswer(questionId, proposition);

    final updatedState = ref.read(quizPlayProvider(widget.quizId));
    if (updatedState.isCompleted) {
      _timer?.cancel();
      final result = await notifier.submitQuiz();
      if (result != null && mounted) {
        context.pushReplacement('/quiz/result', extra: result);
      }
    } else {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(quizPlayProvider(widget.quizId));
    final quiz = playState.quiz;

    if (playState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session de Quiz')),
        body: AppError(
          message: playState.error!,
          onRetry: () => ref.read(quizPlayProvider(widget.quizId).notifier).loadQuiz(),
        ),
      );
    }

    if (quiz == null || playState.isSubmitting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session de Quiz')),
        body: AppLoader(
          message: playState.isSubmitting
              ? 'Évaluation de vos réponses et calcul des badges...'
              : 'Préparation du quiz...',
        ),
      );
    }

    if (quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(quiz.nomQuiz)),
        body: const Center(
          child: Text('Ce quiz ne contient aucune question pour l\'instant.'),
        ),
      );
    }

    final currentIndex = playState.currentQuestionIndex.clamp(0, quiz.questions.length - 1);
    final question = quiz.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.nomQuiz),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: QuizTimerWidget(secondsRemaining: _secondsLeft, totalSeconds: _totalDuration),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / quiz.questions.length,
                backgroundColor: AppColors.mistIvory,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sahelGold),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: AppDimensions.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} sur ${quiz.questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  Text(
                    '+${question.points} pts',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.sahelGold),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.lg),

              AppCard(
                color: AppColors.primaryForest.withValues(alpha: 0.05),
                child: Text(
                  question.nomQuestion,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Choix de réponses
              Expanded(
                child: ListView.separated(
                  itemCount: question.propositions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
                  itemBuilder: (context, idx) {
                    final proposition = question.propositions[idx];
                    return AppButton(
                      text: proposition,
                      isOutlined: true,
                      color: AppColors.primaryForest,
                      onPressed: () => _answerQuestion(question.idQuestion, proposition),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
