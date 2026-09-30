/// Modèle représentant un article culturel ou historique du Mali.
class ArticleModel {
  final int idArticle;
  String get titre => nomArticle;
  final String nomArticle;
  final String? contenu;
  final DateTime? datePublication;
  final int vues;
  final String? imageArticle;
  final String? auteur;

  const ArticleModel({
    required this.idArticle,
    required this.nomArticle,
    this.contenu,
    this.datePublication,
    this.vues = 0,
    this.imageArticle,
    this.auteur,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['datePublication'] != null) {
      parsedDate = DateTime.tryParse(json['datePublication'].toString());
    }

    return ArticleModel(
      idArticle: (json['idArticle'] as num?)?.toInt() ?? 0,
      nomArticle: json['nomArticle'] as String? ?? json['titre'] as String? ?? '',
      contenu: json['contenu'] as String?,
      datePublication: parsedDate,
      vues: (json['vues'] as num?)?.toInt() ?? 0,
      imageArticle: json['imageArticle'] as String? ?? json['imageUrl'] as String?,
      auteur: json['auteur'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idArticle': idArticle,
      'nomArticle': nomArticle,
      'contenu': contenu,
      'datePublication': datePublication?.toIso8601String(),
      'vues': vues,
      'imageArticle': imageArticle,
      'auteur': auteur,
    };
  }
}
