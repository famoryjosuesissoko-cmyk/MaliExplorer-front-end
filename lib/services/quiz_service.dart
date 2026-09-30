import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/quiz_model.dart';

/// Service pour charger les quiz et soumettre les réponses au backend Spring Boot.
class QuizService {
  final ApiService _apiService;

  QuizService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Récupère la liste de tous les quiz disponibles
  Future<List<QuizModel>> getAllQuizzes() async {
    final response = await _apiService.get(ApiConstants.quiz);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      return list.map((item) => QuizModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les quiz');
  }

  /// Charge les données d'un quiz pour une session de jeu (avec choix de réponses)
  Future<QuizModel> getQuizForPlay(int quizId) async {
    final response = await _apiService.get('${ApiConstants.quiz}/$quizId/play');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return QuizModel.fromJson(data);
    }
    throw Exception('Échec du chargement de la session de jeu');
  }

  /// Soumet les réponses au backend pour évaluation anti-triche et calcul des points
  Future<QuizResultModel> evaluateQuiz({
    required int quizId,
    required Map<int, String> reponses,
  }) async {
    // Conversion de la map int -> String en string key pour le JSON
    final stringReponses = reponses.map((k, v) => MapEntry(k.toString(), v));

    final response = await _apiService.post(
      '${ApiConstants.quiz}/evaluate',
      body: {
        'quizId': quizId,
        'reponses': stringReponses,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return QuizResultModel.fromJson(data);
    }
    throw Exception('Erreur lors de l\'évaluation du quiz par le serveur');
  }
}
