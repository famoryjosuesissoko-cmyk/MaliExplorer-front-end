import '../models/president_model.dart';
import '../models/plat_model.dart';
import '../models/ethnie_model.dart';
import '../models/ville_model.dart';

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

  /// Résolution intelligente de l'image (asset local ou URL distante)
  String get displayPhoto {
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    final lower = titre.toLowerCase();
    final catLower = categorie.toLowerCase();

    // 1. Président / Chef d'État
    if (catLower.contains('chef') ||
        catLower.contains('président') ||
        lower.contains('keita') ||
        lower.contains('keïta') ||
        lower.contains('traore') ||
        lower.contains('traoré') ||
        lower.contains('konare') ||
        lower.contains('konaré') ||
        lower.contains('toure') ||
        lower.contains('touré') ||
        lower.contains('sanogo') ||
        lower.contains('ibk') ||
        lower.contains('daw') ||
        lower.contains('goita') ||
        lower.contains('goïta') ||
        lower.contains('assimi') ||
        lower.contains('modibo')) {
      return PresidentModel.getLocalPhoto(titre);
    }

    // 2. Plat traditionnel
    if (catLower.contains('plat') ||
        lower.contains('tiga') ||
        lower.contains('arachide') ||
        lower.contains('saka') ||
        lower.contains('fakoye') ||
        lower.contains('tô') ||
        lower.contains('to') ||
        lower.contains('zaamin') ||
        lower.contains('widjila')) {
      return PlatModel.getLocalPhoto(titre);
    }

    // 3. Ethnie / Tradition
    if (catLower.contains('peuple') ||
        catLower.contains('ethnie') ||
        lower.contains('dogon') ||
        lower.contains('peul') ||
        lower.contains('bambara') ||
        lower.contains('soninke') ||
        lower.contains('soninké') ||
        lower.contains('touareg') ||
        lower.contains('malinke') ||
        lower.contains('malinké')) {
      return EthnieModel.getLocalPhotoHomme(titre);
    }

    // 4. Ville / Lieu Historique
    if (catLower.contains('ville') ||
        catLower.contains('région') ||
        catLower.contains('lieu') ||
        lower.contains('bamako') ||
        lower.contains('djenne') ||
        lower.contains('djenné') ||
        lower.contains('mopti') ||
        lower.contains('segou') ||
        lower.contains('ségou') ||
        lower.contains('sikasso') ||
        lower.contains('tombouctou')) {
      return VilleModel.getLocalPhoto(titre);
    }

    return imageUrl.isNotEmpty
        ? imageUrl
        : 'assets/images/bamako_cover.jpeg';
  }

  factory FavoriModel.fromJson(Map<String, dynamic> json) {
    int id = json['idFavori'] ?? json['id'] ?? 0;
    String titre = 'Favori';
    String categorie = 'Découverte';
    String imageUrl = '';
    String route = '/cityDetail';
    int? referenceId;

    if (json['lieu'] != null && json['lieu'] is Map) {
      final lieu = json['lieu'] as Map;
      titre = lieu['nomLieuHisto'] ?? lieu['nom'] ?? 'Lieu Historique';
      categorie = 'Lieu historique';
      route = '/cityDetail';
      referenceId = lieu['idLieu'] ?? lieu['id'];
      imageUrl = lieu['panorama360Url'] ?? VilleModel.getLocalPhoto(titre);
    } else if (json['lieuHistorique'] != null && json['lieuHistorique'] is Map) {
      final lieu = json['lieuHistorique'] as Map;
      titre = lieu['nomLieuHisto'] ?? lieu['nom'] ?? 'Lieu Historique';
      categorie = 'Lieu traditionnel';
      route = '/cityDetail';
      referenceId = lieu['idLieu'] ?? lieu['id'];
      imageUrl = lieu['panorama360Url'] ?? VilleModel.getLocalPhoto(titre);
    } else if (json['article'] != null && json['article'] is Map) {
      final art = json['article'] as Map;
      titre = art['nomArticle'] ?? art['titre'] ?? 'Article culturel';
      categorie = 'Culture & Patrimoine';
      route = '/ethnicityDetail';
      referenceId = art['idArticle'] ?? art['id'];
      imageUrl = art['imageUrl'] ?? EthnieModel.getLocalPhotoHomme(titre);
    } else if (json['plat'] != null && json['plat'] is Map) {
      final plat = json['plat'] as Map;
      titre = plat['nom'] ?? 'Plat traditionnel';
      categorie = 'Plat traditionnel';
      route = '/dishDetail';
      referenceId = plat['idPlat'] ?? plat['id'];
      imageUrl = PlatModel.getLocalPhoto(titre);
    } else if (json['title'] != null || json['titre'] != null) {
      titre = json['title'] ?? json['titre'] ?? '';
      categorie = json['category'] ?? json['categorie'] ?? '';
      imageUrl = json['imageUrl'] ?? '';
      route = json['route'] ?? route;
      referenceId = json['referenceId'];
    }

    final favori = FavoriModel(
      id: id,
      titre: titre,
      categorie: categorie,
      imageUrl: imageUrl,
      route: route,
      referenceId: referenceId,
    );

    // Si imageUrl était vide, on lui assigne directement sa displayPhoto
    if (imageUrl.isEmpty) {
      return FavoriModel(
        id: id,
        titre: titre,
        categorie: categorie,
        imageUrl: favori.displayPhoto,
        route: route,
        referenceId: referenceId,
      );
    }

    return favori;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'categorie': categorie,
      'imageUrl': imageUrl.isNotEmpty ? imageUrl : displayPhoto,
      'route': route,
      'referenceId': referenceId,
    };
  }
}
