/// Modèle représentant un plat traditionnel malien.
class PlatModel {
  final int idPlat;
  final String nomPlat;
  final String? description;
  final String? ingredients;
  final String? imagePlat;
  final int? regionId;
  final String? regionNom;

  const PlatModel({
    required this.idPlat,
    required this.nomPlat,
    this.description,
    this.ingredients,
    this.imagePlat,
    this.regionId,
    this.regionNom,
  });

  factory PlatModel.fromJson(Map<String, dynamic> json) {
    return PlatModel(
      idPlat: json['idPlat'] as int? ?? 0,
      nomPlat: json['nomPlat'] as String? ?? '',
      description: json['description'] as String?,
      ingredients: json['ingredients'] as String?,
      imagePlat: json['imagePlat'] as String?,
      regionId: json['regionId'] as int?,
      regionNom: json['regionNom'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPlat': idPlat,
      'nomPlat': nomPlat,
      'description': description,
      'ingredients': ingredients,
      'imagePlat': imagePlat,
      'regionId': regionId,
      'regionNom': regionNom,
    };
  }
}
