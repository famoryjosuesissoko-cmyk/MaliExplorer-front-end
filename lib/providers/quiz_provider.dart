import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';
import 'auth_provider.dart';

final quizServiceProvider = Provider<QuizService>((ref) {
  final apiService = ref.watch(authServiceProvider).apiService;
  return QuizService(apiService: apiService);
});

final quizListProvider = FutureProvider<List<QuizModel>>((ref) async {
  final quizService = ref.watch(quizServiceProvider);
  return await quizService.getAllQuizzes();
});

class QuizPlayState {
  final QuizModel? quiz;
  final int currentQuestionIndex;
  final Map<int, String> reponses;
  final bool isSubmitting;
  final QuizResultModel? result;
  final String? error;

  const QuizPlayState({
    this.quiz,
    this.currentQuestionIndex = 0,
    this.reponses = const {},
    this.isSubmitting = false,
    this.result,
    this.error,
  });

  bool get isCompleted =>
      quiz != null && quiz!.questions.isNotEmpty && currentQuestionIndex >= quiz!.questions.length;

  QuizPlayState copyWith({
    QuizModel? quiz,
    int? currentQuestionIndex,
    Map<int, String>? reponses,
    bool? isSubmitting,
    QuizResultModel? result,
    String? error,
  }) {
    return QuizPlayState(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      reponses: reponses ?? this.reponses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      error: error,
    );
  }
}

final quizPlayProvider = StateNotifierProvider.family<QuizPlayNotifier, QuizPlayState, int>((ref, quizId) {
  final quizService = ref.watch(quizServiceProvider);
  return QuizPlayNotifier(quizService, quizId);
});

class QuizPlayNotifier extends StateNotifier<QuizPlayState> {
  final QuizService _quizService;
  final int _quizId;

  QuizPlayNotifier(this._quizService, this._quizId) : super(const QuizPlayState()) {
    loadQuiz();
  }

  Future<void> loadQuiz() async {
    try {
      final quiz = await _quizService.getQuizForPlay(_quizId);
      state = state.copyWith(quiz: quiz, currentQuestionIndex: 0, reponses: {});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectAnswer(int questionId, String proposition) {
    final updated = Map<int, String>.from(state.reponses);
    updated[questionId] = proposition;
    state = state.copyWith(
      reponses: updated,
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  Future<QuizResultModel?> submitQuiz() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final result = await _quizService.evaluateQuiz(
        quizId: _quizId,
        reponses: state.reponses,
      );
      state = state.copyWith(isSubmitting: false, result: result);
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}
