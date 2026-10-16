import '../models/president_model.dart';
import '../models/plat_model.dart';
import '../models/ethnie_model.dart';
import '../models/ville_model.dart';
import '../core/constants/api_constants.dart';

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

  /// Résolution intelligente de l'image (URL distante prioritaire, sinon asset local ou déduction)
  String get displayPhoto {
    final trimmed = imageUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return ApiConstants.resolveImageUrl(trimmed);
    }
    if (trimmed.startsWith('assets/')) {
      return trimmed;
    }
    if (trimmed.isNotEmpty && (trimmed.startsWith('/') || trimmed.startsWith('data:') || trimmed.startsWith('uploads/') || trimmed.startsWith('api/'))) {
      return ApiConstants.resolveImageUrl(trimmed);
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
      final local = PresidentModel.getLocalPhoto(titre, referenceId);
      if (local.isNotEmpty) return local;
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

    return trimmed.isNotEmpty
        ? ApiConstants.resolveImageUrl(trimmed)
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
      final rawImg = lieu['imageUrl'] ?? lieu['photoUrl'] ?? lieu['panorama360Url'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : VilleModel.getLocalPhoto(titre);
    } else if (json['lieuHistorique'] != null && json['lieuHistorique'] is Map) {
      final lieu = json['lieuHistorique'] as Map;
      titre = lieu['nomLieuHisto'] ?? lieu['nom'] ?? 'Lieu Historique';
      categorie = 'Lieu traditionnel';
      route = '/cityDetail';
      referenceId = lieu['idLieu'] ?? lieu['id'];
      final rawImg = lieu['imageUrl'] ?? lieu['photoUrl'] ?? lieu['panorama360Url'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : VilleModel.getLocalPhoto(titre);
    } else if (json['article'] != null && json['article'] is Map) {
      final art = json['article'] as Map;
      titre = art['nomArticle'] ?? art['titre'] ?? 'Article culturel';
      categorie = 'Culture & Patrimoine';
      route = '/ethnicityDetail';
      referenceId = art['idArticle'] ?? art['id'];
      final rawImg = art['imageUrl'] ?? art['photoUrl'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : EthnieModel.getLocalPhotoHomme(titre);
    } else if (json['plat'] != null && json['plat'] is Map) {
      final plat = json['plat'] as Map;
      titre = plat['nom'] ?? plat['nomPlat'] ?? 'Plat traditionnel';
      categorie = 'Plat traditionnel';
      route = '/dishDetail';
      referenceId = plat['idPlat'] ?? plat['id'];
      final rawImg = plat['imageUrl'] ?? plat['photoUrl'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : PlatModel.getLocalPhoto(titre);
    } else if (json['president'] != null && json['president'] is Map) {
      final pres = json['president'] as Map;
      final prenom = pres['prenom'] ?? '';
      final nom = pres['nom'] ?? '';
      titre = '$prenom $nom'.trim();
      if (titre.isEmpty) titre = pres['nom'] ?? 'Chef d\'État';
      categorie = 'Chef d\'État';
      route = '/presidentDetail';
      referenceId = pres['idPresident'] ?? pres['id'];
      final rawImg = pres['photoUrl'] ?? pres['imageUrl'] ?? pres['photo'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : PresidentModel.getLocalPhoto(titre, referenceId);
    } else if (json['chefEtat'] != null && json['chefEtat'] is Map) {
      final pres = json['chefEtat'] as Map;
      final prenom = pres['prenom'] ?? '';
      final nom = pres['nom'] ?? '';
      titre = '$prenom $nom'.trim();
      if (titre.isEmpty) titre = pres['nom'] ?? 'Chef d\'État';
      categorie = 'Chef d\'État';
      route = '/presidentDetail';
      referenceId = pres['idPresident'] ?? pres['id'];
      final rawImg = pres['photoUrl'] ?? pres['imageUrl'] ?? pres['photo'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : PresidentModel.getLocalPhoto(titre, referenceId);
    } else if (json['ville'] != null && json['ville'] is Map) {
      final v = json['ville'] as Map;
      titre = v['nom'] ?? v['nomVille'] ?? 'Ville';
      categorie = 'Ville';
      route = '/cityDetail';
      referenceId = v['idVille'] ?? v['id'];
      final rawImg = v['imageUrl'] ?? v['photoUrl'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : VilleModel.getLocalPhoto(titre);
    } else if (json['region'] != null && json['region'] is Map) {
      final reg = json['region'] as Map;
      titre = reg['nom'] ?? reg['nomRegion'] ?? 'Région';
      categorie = 'Région';
      route = '/regionDetail';
      referenceId = reg['idRegion'] ?? reg['id'];
      final rawImg = reg['imageCover'] ?? reg['imageUrl'] ?? reg['photoUrl'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : 'assets/images/mopti_cover.jpg';
    } else if (json['ethnie'] != null && json['ethnie'] is Map) {
      final eth = json['ethnie'] as Map;
      titre = eth['nom'] ?? eth['nomEthnie'] ?? 'Ethnie';
      categorie = 'Ethnie';
      route = '/ethnicityDetail';
      referenceId = eth['idEthnie'] ?? eth['id'];
      final rawImg = eth['imageUrl'] ?? eth['photoHomme'] ?? eth['photoUrl'];
      imageUrl = (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : EthnieModel.getLocalPhotoHomme(titre);
    } else if (json['title'] != null || json['titre'] != null) {
      titre = json['title'] ?? json['titre'] ?? '';
      categorie = json['category'] ?? json['categorie'] ?? '';
      imageUrl = json['imageUrl'] ?? json['photoUrl'] ?? '';
      route = json['route'] ?? route;
      referenceId = json['referenceId'] ?? json['id'];
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
