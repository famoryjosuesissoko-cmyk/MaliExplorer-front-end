import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/quiz_service.dart';
import '../models/quiz_model.dart';

final quizListProvider = FutureProvider<List<QuizModel>>((ref) async {
  final service = ref.watch(quizServiceProvider);
  return await service.getQuizzes();
});

final quizPlayProvider = FutureProvider.family<QuizModel, int>((ref, quizId) async {
  final service = ref.watch(quizServiceProvider);
  return await service.getQuizForPlay(quizId);
});
