import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';

/// Modèle représentant une section d'informations pratiques pour les voyageurs au Mali.
class InfoPratiqueModel {
  final int id;
  final String titre;
  final String description;
  final String categorie;
  final String? conseils;
  final String? coordonnees;
  final String? imageUrl;
  final int ordreAffichage;
  final String? badge;

  const InfoPratiqueModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    this.conseils,
    this.coordonnees,
    this.imageUrl,
    this.ordreAffichage = 0,
    this.badge,
  });

  /// Construit un objet InfoPratiqueModel à partir d'une réponse JSON de l'API.
  factory InfoPratiqueModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['idInfoPratique'] ?? 0;
    final int resolvedId = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0;

    final rawTitre = json['titre']?.toString() ?? '';
    final rawDesc = json['description']?.toString() ?? '';
    final rawCat = (json['categorie']?.toString() ?? 'DIVERS').toUpperCase().trim();
    final rawConseils = json['conseils']?.toString();
    final rawCoord = json['coordonnees']?.toString();
    final rawBadge = json['badge']?.toString();

    final rawOrdre = json['ordreAffichage'] ?? json['ordre'] ?? 0;
    final int resolvedOrdre = rawOrdre is int ? rawOrdre : int.tryParse(rawOrdre.toString()) ?? 0;

    final rawImg = json['imageUrl'] ?? json['image_url'];
    final String? resolvedImg = (rawImg != null && rawImg.toString().trim().isNotEmpty)
        ? ApiConstants.resolveImageUrl(rawImg.toString().trim())
        : null;

    return InfoPratiqueModel(
      id: resolvedId,
      titre: rawTitre,
      description: rawDesc,
      categorie: rawCat,
      conseils: rawConseils,
      coordonnees: rawCoord,
      imageUrl: resolvedImg,
      ordreAffichage: resolvedOrdre,
      badge: rawBadge,
    );
  }

  /// Convertit le modèle en map JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'description': description,
    'categorie': categorie,
    if (conseils != null) 'conseils': conseils,
    if (coordonnees != null) 'coordonnees': coordonnees,
    if (imageUrl != null) 'imageUrl': imageUrl,
    'ordreAffichage': ordreAffichage,
    if (badge != null) 'badge': badge,
  };

  /// Liste formatée des points ou conseils pour les rubriques textuelles.
  List<String> get itemsList {
    if (conseils != null && conseils!.trim().isNotEmpty) {
      return conseils!
          .split(RegExp(r'[\r\n]+'))
          .map((s) => s.trim().replaceAll(RegExp(r'^[-•*]\s*'), ''))
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (description.trim().isNotEmpty) {
      return description
          .split(RegExp(r'[\r\n]+'))
          .map((s) => s.trim().replaceAll(RegExp(r'^[-•*]\s*'), ''))
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Paires Libellé/Numéro d'appel pour la rubrique Urgences.
  List<MapEntry<String, String>> get emergencyRows {
    final text = coordonnees ?? description;
    if (text.trim().isEmpty) return [];

    final lines = text.split(RegExp(r'[\r\n]+')).map((s) => s.trim()).where((s) => s.isNotEmpty);
    final list = <MapEntry<String, String>>[];
    for (final line in lines) {
      if (line.contains(':')) {
        final split = line.split(':');
        list.add(MapEntry(split[0].trim(), split.sublist(1).join(':').trim()));
      } else {
        list.add(MapEntry(line, ''));
      }
    }
    return list;
  }

  /// Icône officielle adaptée à la catégorie.
  IconData get defaultIcon {
    switch (categorie) {
      case 'VISAS':
        return Icons.badge_rounded;
      case 'SANTE':
        return Icons.medical_services_rounded;
      case 'DEVISES':
        return Icons.payments_rounded;
      case 'CLIMAT':
        return Icons.wb_sunny_rounded;
      case 'URGENCES':
        return Icons.contact_phone_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  /// Couleur indicative du badge selon la thématique.
  Color get defaultBadgeColor {
    switch (categorie) {
      case 'VISAS':
        return const Color(0xFFC53030);
      case 'SANTE':
        return const Color(0xFFDD6B20);
      case 'DEVISES':
        return const Color(0xFF2E7D32);
      case 'CLIMAT':
        return const Color(0xFF3182CE);
      case 'URGENCES':
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFF075E4D);
    }
  }

  /// Libellé du badge affiché sur la carte.
  String get displayBadge {
    if (badge != null && badge!.trim().isNotEmpty) return badge!;
    switch (categorie) {
      case 'VISAS':
        return 'Obligatoire';
      case 'SANTE':
        return 'Exigé à l\'arrivée';
      case 'DEVISES':
        return 'FCFA (XOF)';
      case 'CLIMAT':
        return 'Saison fraîche : Nov - Fév';
      case 'URGENCES':
        return 'Urgence 24/7';
      default:
        return 'Info Voyageur';
    }
  }
}
