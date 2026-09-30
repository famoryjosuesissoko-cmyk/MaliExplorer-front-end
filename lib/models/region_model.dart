/// Modèle représentant une région administrative et culturelle du Mali.
class RegionModel {
  final int idRegion;
  final String nomRegion;
  final String? description;
  final double? superficie;
  final int? population;
  final String? imageRegion;

  const RegionModel({
    required this.idRegion,
    required this.nomRegion,
    this.description,
    this.superficie,
    this.population,
    this.imageRegion,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      idRegion: json['idRegion'] as int? ?? 0,
      nomRegion: json['nomRegion'] as String? ?? '',
      description: json['description'] as String?,
      superficie: (json['superficie'] as num?)?.toDouble(),
      population: json['population'] as int?,
      imageRegion: json['imageRegion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRegion': idRegion,
      'nomRegion': nomRegion,
      'description': description,
      'superficie': superficie,
      'population': population,
      'imageRegion': imageRegion,
    };
  }
}
