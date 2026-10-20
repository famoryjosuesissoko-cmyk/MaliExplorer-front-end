import 'dart:convert';
import '../core/constants/api_constants.dart';

/// Élément de lexique pratique associé à une langue nationale.
class LexiqueItemModel {
  final String mot;
  final String phonetique;
  final String traduction;
  final String categorie;

  const LexiqueItemModel({
    required this.mot,
    required this.phonetique,
    required this.traduction,
    required this.categorie,
  });

  /// Crée un élément de lexique à partir d'une structure JSON.
  factory LexiqueItemModel.fromJson(Map<String, dynamic> json) {
    return LexiqueItemModel(
      mot: json['mot']?.toString() ?? '',
      phonetique: json['phonetique']?.toString() ?? '',
      traduction: json['traduction']?.toString() ?? '',
      categorie: json['categorie']?.toString() ?? 'Expressions usuelles',
    );
  }

  /// Sérialise l'élément de lexique en format JSON.
  Map<String, dynamic> toJson() => {
    'mot': mot,
    'phonetique': phonetique,
    'traduction': traduction,
    'categorie': categorie,
  };
}

/// Modèle représentant une langue nationale du Mali.
class LangueModel {
  final int id;
  final String nom;
  final String nomLocal;
  final String locuteurs;
  final String regions;
  final String description;
  final String? imageUrl;
  final int ordreAffichage;
  final List<LexiqueItemModel> lexique;

  const LangueModel({
    required this.id,
    required this.nom,
    required this.nomLocal,
    required this.locuteurs,
    required this.regions,
    required this.description,
    this.imageUrl,
    this.ordreAffichage = 0,
    this.lexique = const [],
  });

  /// Crée une instance de LangueModel à partir d'un objet JSON reçu de l'API Spring Boot.
  factory LangueModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['idLangue'] ?? 0;
    final int resolvedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawNom = json['nom']?.toString() ?? '';
    final rawNomLocal = json['nomLocal']?.toString() ?? json['nom_local']?.toString() ?? '';
    final rawLocuteurs = json['locuteurs']?.toString() ?? '';
    final rawRegions = json['regions']?.toString() ?? '';
    final rawDesc = json['description']?.toString() ?? '';

    final rawOrdre = json['ordreAffichage'] ?? json['ordre'] ?? 0;
    final int resolvedOrdre = rawOrdre is int ? rawOrdre : int.tryParse(rawOrdre.toString()) ?? 0;

    final rawImg = json['imageUrl'] ?? json['image_url'];
    final String? resolvedImg = (rawImg != null && rawImg.toString().trim().isNotEmpty)
        ? ApiConstants.resolveImageUrl(rawImg.toString().trim())
        : null;

    // Décodage souple du lexique (liste de Maps ou chaîne JSON sérialisée)
    List<LexiqueItemModel> parsedLexique = [];
    final rawLexique = json['lexique'];
    if (rawLexique is List) {
      parsedLexique = rawLexique
          .whereType<Map<String, dynamic>>()
          .map((item) => LexiqueItemModel.fromJson(item))
          .toList();
    } else if (rawLexique is String && rawLexique.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawLexique);
        if (decoded is List) {
          parsedLexique = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => LexiqueItemModel.fromJson(item))
              .toList();
        }
      } catch (_) {
        // En cas d'erreur de décodage JSON, on conserve la liste vide.
      }
    }

    final String fallbackNomLocal = rawNom.isNotEmpty ? rawNom.split(' ').first : '';

    return LangueModel(
      id: resolvedId,
      nom: rawNom,
      nomLocal: rawNomLocal.isNotEmpty ? rawNomLocal : fallbackNomLocal,
      locuteurs: rawLocuteurs,
      regions: rawRegions,
      description: rawDesc,
      imageUrl: resolvedImg,
      ordreAffichage: resolvedOrdre,
      lexique: parsedLexique,
    );
  }

  /// Sérialise l'objet LangueModel en JSON pour transmission ou mise en cache.
  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'nomLocal': nomLocal,
    'locuteurs': locuteurs,
    'regions': regions,
    'description': description,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'ordreAffichage': ordreAffichage,
    'lexique': lexique.map((l) => l.toJson()).toList(),
  };
}
