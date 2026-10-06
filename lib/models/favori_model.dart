class FavoriModel {
  final int id;
  final String titre;
  final String categorie;
  final String imageUrl;
  final String route;
  final int? referenceId;

  const FavoriModel({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.imageUrl,
    required this.route,
    this.referenceId,
  });

  factory FavoriModel.fromJson(Map<String, dynamic> json) {
    int id = json['idFavori'] ?? json['id'] ?? 0;
    String titre = 'Favori';
    String categorie = 'Découverte';
    String imageUrl =
        'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop';
    String route = '/cityDetail';
    int? referenceId;

    if (json['lieu'] != null && json['lieu'] is Map) {
      final lieu = json['lieu'] as Map;
      titre = lieu['nomLieuHisto'] ?? lieu['nom'] ?? 'Lieu Historique';
      categorie = 'Lieu historique';
      route = '/cityDetail';
      referenceId = lieu['idLieu'] ?? lieu['id'];
      imageUrl = lieu['panorama360Url'] ?? imageUrl;
    } else if (json['lieuHistorique'] != null && json['lieuHistorique'] is Map) {
      final lieu = json['lieuHistorique'] as Map;
      titre = lieu['nomLieuHisto'] ?? lieu['nom'] ?? 'Lieu Historique';
      categorie = 'Lieu traditionnel';
      route = '/cityDetail';
      referenceId = lieu['idLieu'] ?? lieu['id'];
      imageUrl = lieu['panorama360Url'] ?? imageUrl;
    } else if (json['article'] != null && json['article'] is Map) {
      final art = json['article'] as Map;
      titre = art['nomArticle'] ?? art['titre'] ?? 'Article culturel';
      categorie = 'Culture & Patrimoine';
      route = '/ethnicityDetail';
      referenceId = art['idArticle'] ?? art['id'];
      imageUrl = art['imageUrl'] ?? imageUrl;
    } else if (json['plat'] != null && json['plat'] is Map) {
      final plat = json['plat'] as Map;
      titre = plat['nom'] ?? 'Plat traditionnel';
      categorie = 'Plat';
      route = '/dishDetail';
      referenceId = plat['idPlat'] ?? plat['id'];
      imageUrl =
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop';
    } else if (json['title'] != null || json['titre'] != null) {
      titre = json['title'] ?? json['titre'] ?? '';
      categorie = json['category'] ?? json['categorie'] ?? '';
      imageUrl = json['imageUrl'] ?? imageUrl;
      route = json['route'] ?? route;
    }

    return FavoriModel(
      id: id,
      titre: titre,
      categorie: categorie,
      imageUrl: imageUrl,
      route: route,
      referenceId: referenceId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'categorie': categorie,
      'imageUrl': imageUrl,
      'route': route,
      'referenceId': referenceId,
    };
  }
}
