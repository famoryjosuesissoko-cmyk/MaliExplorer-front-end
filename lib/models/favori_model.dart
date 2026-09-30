/// Modèle pour les favoris de l'utilisateur.
class FavoriModel {
  final int? id;
  final String? typeElement;
  final int? elementId;
  final String? titre;
  final String? imageUrl;
  final String? description;
  final DateTime? dateAjout;

  const FavoriModel({
    this.id,
    this.typeElement,
    this.elementId,
    this.titre,
    this.imageUrl,
    this.description,
    this.dateAjout,
  });

  factory FavoriModel.fromJson(Map<String, dynamic> json) {
    return FavoriModel(
      id: json['id'] as int? ?? json['idFavori'] as int?,
      typeElement: json['typeElement'] as String? ?? json['type'] as String?,
      elementId: json['elementId'] as int? ?? json['referenceId'] as int?,
      titre: json['titre'] as String? ?? json['nom'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
      description: json['description'] as String?,
      dateAjout: json['dateAjout'] != null ? DateTime.tryParse(json['dateAjout'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (typeElement != null) 'typeElement': typeElement,
      if (elementId != null) 'elementId': elementId,
      if (titre != null) 'titre': titre,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
      if (dateAjout != null) 'dateAjout': dateAjout?.toIso8601String(),
    };
  }
}
