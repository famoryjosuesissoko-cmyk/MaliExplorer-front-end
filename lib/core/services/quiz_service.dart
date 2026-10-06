import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService(ref.watch(apiServiceProvider));
});

class QuizService {
  final ApiService _apiService;

  QuizService(this._apiService);

  Future<List<QuizModel>> getQuizzes() async {
    final response = await _apiService.get(ApiConstants.quiz);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((j) => QuizModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de récupérer les quiz.');
    }
  }

  Future<QuizModel> getQuizForPlay(int id) async {
    final response = await _apiService.get('${ApiConstants.quiz}/$id/jouer');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return QuizModel.fromJson(data);
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de charger le quiz pour jouer.');
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required Map<int, String> reponses,
  }) async {
    final response = await _apiService.post(
      '${ApiConstants.quiz}/soumettre',
      body: {
        'quizId': quizId,
        'reponses': reponses.map((k, v) => MapEntry(k.toString(), v)),
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Erreur ${response.statusCode}: Impossible de soumettre le quiz.');
    }
  }
}
