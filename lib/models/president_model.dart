class PresidentModel {
  final int id;
  final String prenom;
  final String nom;
  final String? dateNaissance;
  final String? dateDeces;
  final String periodeMandat;
  final String biographie;
  final String photoUrl;

  const PresidentModel({
    required this.id,
    required this.prenom,
    required this.nom,
    this.dateNaissance,
    this.dateDeces,
    required this.periodeMandat,
    required this.biographie,
    required this.photoUrl,
  });

  String get fullName => '$prenom $nom'.trim();

  factory PresidentModel.fromJson(Map<String, dynamic> json) {
    return PresidentModel(
      id: json['id'] ?? json['idPresident'] ?? 0,
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      dateNaissance: json['dateNaissance']?.toString(),
      dateDeces: json['dateDeces']?.toString(),
      periodeMandat: json['periodeMandat'] ?? '',
      biographie: json['biographie'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'dateNaissance': dateNaissance,
      'dateDeces': dateDeces,
      'periodeMandat': periodeMandat,
      'biographie': biographie,
      'photoUrl': photoUrl,
    };
  }
}
