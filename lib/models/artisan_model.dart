/// Modèle représentant un artisan local malien (poterie, bogolan, cuir, bijouterie, etc.).
class ArtisanModel {
  final int idArtisan;
  final String prenom;
  final String nom;
  final String? email;
  final String? adresse;
  final String? photoUrl;
  final String? typeArtisanat;

  const ArtisanModel({
    required this.idArtisan,
    required this.prenom,
    required this.nom,
    this.email,
    this.adresse,
    this.photoUrl,
    this.typeArtisanat,
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory ArtisanModel.fromJson(Map<String, dynamic> json) {
    return ArtisanModel(
      idArtisan: (json['idUsers'] as num?)?.toInt() ?? (json['idArtisan'] as num?)?.toInt() ?? 0,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String?,
      adresse: json['adresse'] as String?,
      photoUrl: json['photoUrl'] as String?,
      typeArtisanat: json['typeArtisanat'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idArtisan': idArtisan,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'adresse': adresse,
      'photoUrl': photoUrl,
      'typeArtisanat': typeArtisanat,
    };
  }
}
