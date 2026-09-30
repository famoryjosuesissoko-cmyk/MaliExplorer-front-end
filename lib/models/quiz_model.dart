import 'question_model.dart';

/// Modèle représentant un quiz culturel du Mali.
class QuizModel {
  final int idQuiz;
  final String nomQuiz;
  final String? description;
  final String? imageQuiz;
  final int nombreQuestions;
  final int points;
  final List<QuestionModel> questions;

  const QuizModel({
    required this.idQuiz,
    required this.nomQuiz,
    this.description,
    this.imageQuiz,
    this.nombreQuestions = 0,
    this.points = 0,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    List<QuestionModel> qs = [];
    if (json['questions'] != null && json['questions'] is List) {
      qs = (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    return QuizModel(
      idQuiz: (json['idQuiz'] as num?)?.toInt() ?? 0,
      nomQuiz: json['nomQuiz'] as String? ?? '',
      description: json['description'] as String?,
      imageQuiz: json['imageQuiz'] as String?,
      nombreQuestions: (json['nombreQuestions'] as num?)?.toInt() ?? qs.length,
      points: (json['point'] as num?)?.toInt() ?? (json['points'] as num?)?.toInt() ?? 0,
      questions: qs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuiz': idQuiz,
      'nomQuiz': nomQuiz,
      'description': description,
      'imageQuiz': imageQuiz,
      'nombreQuestions': nombreQuestions,
      'points': points,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Résultat d'évaluation d'un quiz renvoyé par le backend Spring Boot.
class QuizResultModel {
  final int quizId;
  final String nomQuiz;
  final int scoreTotalObtenu;
  final int scoreMaxPossible;
  final double pourcentage;
  final bool reussi;
  final int pointsGagnesActivite;
  final int totalPointsUtilisateur;
  final String? badgeActuel;
  final String? prochainBadge;
  final double progressionProchainBadge;
  final String? messageProgression;
  final List<QuestionResultDetailModel> details;

  const QuizResultModel.empty()
      : quizId = 0,
        nomQuiz = '',
        scoreTotalObtenu = 0,
        scoreMaxPossible = 0,
        pourcentage = 0.0,
        reussi = false,
        pointsGagnesActivite = 0,
        totalPointsUtilisateur = 0,
        badgeActuel = null,
        prochainBadge = null,
        progressionProchainBadge = 0.0,
        messageProgression = null,
        details = const [];

  const QuizResultModel({
    required this.quizId,
    required this.nomQuiz,
    required this.scoreTotalObtenu,
    required this.scoreMaxPossible,
    required this.pourcentage,
    required this.reussi,
    required this.pointsGagnesActivite,
    required this.totalPointsUtilisateur,
    this.badgeActuel,
    this.prochainBadge,
    this.progressionProchainBadge = 0.0,
    this.messageProgression,
    this.details = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    List<QuestionResultDetailModel> detailsList = [];
    final rawDetails = json['detailsQuestions'] ?? json['details'];
    if (rawDetails != null && rawDetails is List) {
      detailsList = rawDetails
          .map((d) => QuestionResultDetailModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return QuizResultModel(
      quizId: (json['quizId'] as num?)?.toInt() ?? (json['idQuiz'] as num?)?.toInt() ?? 0,
      nomQuiz: json['nomQuiz'] as String? ?? '',
      scoreTotalObtenu: (json['scoreTotalObtenu'] as num?)?.toInt() ?? 0,
      scoreMaxPossible: (json['scoreMaxPossible'] as num?)?.toInt() ?? 0,
      pourcentage: (json['pourcentage'] as num?)?.toDouble() ?? 0.0,
      reussi: json['reussi'] as bool? ?? false,
      pointsGagnesActivite: (json['pointsGagnesActivite'] as num?)?.toInt() ?? 0,
      totalPointsUtilisateur: (json['totalPointsUtilisateur'] as num?)?.toInt() ?? 0,
      badgeActuel: json['badgeActuel'] as String?,
      prochainBadge: json['prochainBadge'] as String?,
      progressionProchainBadge: (json['progressionProchainBadge'] as num?)?.toDouble() ?? 0.0,
      messageProgression: json['messageProgression'] as String?,
      details: detailsList,
    );
  }
}

class QuestionResultDetailModel {
  final int idQuestion;
  final String nomQuestion;
  final String? reponseSoumise;
  final String? bonneReponse;
  final bool estCorrect;
  final int pointsGagnes;

  const QuestionResultDetailModel({
    required this.idQuestion,
    required this.nomQuestion,
    this.reponseSoumise,
    this.bonneReponse,
    this.estCorrect = false,
    this.pointsGagnes = 0,
  });

  factory QuestionResultDetailModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultDetailModel(
      idQuestion: (json['idQuestion'] as num?)?.toInt() ?? 0,
      nomQuestion: json['nomQuestion'] as String? ?? '',
      reponseSoumise: json['reponseSoumise'] as String?,
      bonneReponse: json['bonneReponse'] as String?,
      estCorrect: json['estCorrect'] as bool? ?? false,
      pointsGagnes: (json['pointsGagnes'] as num?)?.toInt() ?? 0,
    );
  }
}
