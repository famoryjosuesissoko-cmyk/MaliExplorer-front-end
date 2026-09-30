/// Modèle représentant une ville du Mali.
class VilleModel {
  final int idVille;
  final String nomVille;
  final String? description;
  final String? cordonnees;
  final double? latitude;
  final double? longitude;
  final int? regionId;
  final String? regionNom;

  const VilleModel({
    required this.idVille,
    required this.nomVille,
    this.description,
    this.cordonnees,
    this.latitude,
    this.longitude,
    this.regionId,
    this.regionNom,
  });

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    return VilleModel(
      idVille: json['idVille'] as int? ?? 0,
      nomVille: json['nomVille'] as String? ?? '',
      description: json['description'] as String?,
      cordonnees: json['cordonnees'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      regionId: json['regionId'] as int?,
      regionNom: json['regionNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVille': idVille,
      'nomVille': nomVille,
      'description': description,
      'cordonnees': cordonnees,
      'latitude': latitude,
      'longitude': longitude,
      'regionId': regionId,
      'regionNom': regionNom,
    };
  }
}
