class QuestionModel {
  final int idQuestion;
  final String nomQuestion;
  final int duree;
  final List<String> propositions;
  final String? reponse;
  final int? points;

  const QuestionModel({
    required this.idQuestion,
    required this.nomQuestion,
    required this.duree,
    required this.propositions,
    this.reponse,
    this.points,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> props = [];
    if (json['propositions'] is List) {
      props = (json['propositions'] as List).map((p) => p.toString()).toList();
    }

    return QuestionModel(
      idQuestion: json['idQuestion'] ?? 0,
      nomQuestion: json['nomQuestion'] ?? '',
      duree: json['duree'] ?? 30,
      propositions: props,
      reponse: json['reponse']?.toString(),
      points: json['points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuestion': idQuestion,
      'nomQuestion': nomQuestion,
      'duree': duree,
      'propositions': propositions,
      'reponse': reponse,
      'points': points,
    };
  }
}

class QuizModel {
  final int idQuiz;
  final String nomQuiz;
  final String description;
  final String imageQuiz;
  final int point;
  final String categorie;
  final String difficulte;
  final List<QuestionModel> questions;

  const QuizModel({
    required this.idQuiz,
    required this.nomQuiz,
    required this.description,
    required this.imageQuiz,
    required this.point,
    required this.categorie,
    required this.difficulte,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    List<QuestionModel> questList = [];
    if (json['questions'] is List) {
      questList = (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList();
    }

    return QuizModel(
      idQuiz: json['idQuiz'] ?? 0,
      nomQuiz: json['nomQuiz'] ?? '',
      description: json['description'] ?? '',
      imageQuiz: json['imageQuiz'] ??
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=800&auto=format&fit=crop',
      point: json['point'] ?? 30,
      categorie: json['categorie'] ?? 'Culture',
      difficulte: json['difficulte']?.toString() ?? 'MOYEN',
      questions: questList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuiz': idQuiz,
      'nomQuiz': nomQuiz,
      'description': description,
      'imageQuiz': imageQuiz,
      'point': point,
      'categorie': categorie,
      'difficulte': difficulte,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
