/// Modèle représentant un événement culturel ou historique au Mali.
class EvenementModel {
  final int idEvenement;
  final String nomEvenement;
  final String? description;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final String? lieu;
  final String? image;
  final int? regionId;

  const EvenementModel({
    required this.idEvenement,
    required this.nomEvenement,
    this.description,
    this.dateDebut,
    this.dateFin,
    this.lieu,
    this.image,
    this.regionId,
  });

  factory EvenementModel.fromJson(Map<String, dynamic> json) {
    return EvenementModel(
      idEvenement: json['idEvenement'] as int? ?? json['id'] as int? ?? 0,
      nomEvenement: json['nomEvenement'] as String? ?? json['nom'] as String? ?? '',
      description: json['description'] as String?,
      dateDebut: json['dateDebut'] != null ? DateTime.tryParse(json['dateDebut'].toString()) : null,
      dateFin: json['dateFin'] != null ? DateTime.tryParse(json['dateFin'].toString()) : null,
      lieu: json['lieu'] as String?,
      image: json['image'] as String? ?? json['imageUrl'] as String?,
      regionId: json['regionId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEvenement': idEvenement,
      'nomEvenement': nomEvenement,
      if (description != null) 'description': description,
      if (dateDebut != null) 'dateDebut': dateDebut?.toIso8601String(),
      if (dateFin != null) 'dateFin': dateFin?.toIso8601String(),
      if (lieu != null) 'lieu': lieu,
      if (image != null) 'image': image,
      if (regionId != null) 'regionId': regionId,
    };
  }
}
