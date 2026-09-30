/// Modèle représentant un président ou une grande figure historique de la République du Mali.
class PresidentModel {
  final int idPresident;
  final String prenom;
  final String nom;
  final String? mandatDebut;
  final String? mandatFin;
  final String? biographie;
  final String? photoUrl;

  const PresidentModel({
    required this.idPresident,
    required this.prenom,
    required this.nom,
    this.mandatDebut,
    this.mandatFin,
    this.biographie,
    this.photoUrl,
  });

  String get nomPresident => nomComplet;
  String get nomComplet => '$prenom $nom'.trim();

  String get periodeMandat {
    if (mandatDebut != null && mandatFin != null) {
      return '$mandatDebut - $mandatFin';
    } else if (mandatDebut != null) {
      return 'Depuis $mandatDebut';
    }
    return '';
  }

  factory PresidentModel.fromJson(Map<String, dynamic> json) {
    return PresidentModel(
      idPresident: (json['idPresident'] as num?)?.toInt() ?? 0,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      mandatDebut: json['mandatDebut'] as String?,
      mandatFin: json['mandatFin'] as String?,
      biographie: json['biographie'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPresident': idPresident,
      'prenom': prenom,
      'nom': nom,
      'mandatDebut': mandatDebut,
      'mandatFin': mandatFin,
      'biographie': biographie,
      'photoUrl': photoUrl,
    };
  }
}
