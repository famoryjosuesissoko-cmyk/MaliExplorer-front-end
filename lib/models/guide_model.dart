/// Modèle représentant un guide touristique certifié au Mali.
class GuideModel {
  final int idGuide;
  final String prenom;
  final String nom;
  final String? email;
  final String? adresse;
  final String? photoUrl;
  final String? langueParlee;

  const GuideModel({
    required this.idGuide,
    required this.prenom,
    required this.nom,
    this.email,
    this.adresse,
    this.photoUrl,
    this.langueParlee,
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      idGuide: (json['idUsers'] as num?)?.toInt() ?? (json['idGuide'] as num?)?.toInt() ?? 0,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      photoUrl: json['photoUrl'] as String?,
      langueParlee: json['langueParlee'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idGuide': idGuide,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'adresse': adresse,
      'photoUrl': photoUrl,
      'langueParlee': langueParlee,
    };
  }
}
