/// Modèle représentant une question de quiz avec ses choix de réponses.
class QuestionModel {
  final int idQuestion;
  final String nomQuestion;
  final int duree;
  final int points;
  final List<String> propositions;
  final String? reponse;

  const QuestionModel({
    required this.idQuestion,
    required this.nomQuestion,
    this.duree = 30,
    this.points = 10,
    this.propositions = const [],
    this.reponse,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> props = [];
    if (json['propositions'] != null && json['propositions'] is List) {
      props = (json['propositions'] as List).map((e) {
        if (e is Map) return e['nomProposition']?.toString() ?? '';
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return QuestionModel(
      idQuestion: (json['idQuestion'] as num?)?.toInt() ?? 0,
      nomQuestion: json['nomQuestion'] as String? ?? '',
      duree: (json['duree'] as num?)?.toInt() ?? 30,
      points: (json['points'] as num?)?.toInt() ?? 10,
      propositions: props,
      reponse: json['reponse'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuestion': idQuestion,
      'nomQuestion': nomQuestion,
      'duree': duree,
      'points': points,
      'propositions': propositions,
      if (reponse != null) 'reponse': reponse,
    };
  }
}
