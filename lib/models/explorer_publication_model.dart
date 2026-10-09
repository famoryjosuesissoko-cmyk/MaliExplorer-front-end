enum PublicationType {
  produitArtisan,
  festivalEvenement,
  patrimoine,
}

class ExplorerPublicationModel {
  final String id;
  final PublicationType type;
  final String titre;
  final String description;
  final String imageUrl;
  final String auteur;
  final String localisation;
  final String? prix;
  final String? date;
  final int vues;
  final int commentaires;
  final String statut; // "VALIDE", "EN_ATTENTE", "REJETE"
  final String categorie;
  final List<String> tags;

  const ExplorerPublicationModel({
    required this.id,
    required this.type,
    required this.titre,
    required this.description,
    required this.imageUrl,
    required this.auteur,
    required this.localisation,
    this.prix,
    this.date,
    this.vues = 0,
    this.commentaires = 0,
    this.statut = 'VALIDE',
    required this.categorie,
    this.tags = const [],
  });

  bool get isValide => statut == 'VALIDE' || statut == 'APPROUVE';

  ExplorerPublicationModel copyWith({
    String? id,
    PublicationType? type,
    String? titre,
    String? description,
    String? imageUrl,
    String? auteur,
    String? localisation,
    String? prix,
    String? date,
    int? vues,
    int? commentaires,
    String? statut,
    String? categorie,
    List<String>? tags,
  }) {
    return ExplorerPublicationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      auteur: auteur ?? this.auteur,
      localisation: localisation ?? this.localisation,
      prix: prix ?? this.prix,
      date: date ?? this.date,
      vues: vues ?? this.vues,
      commentaires: commentaires ?? this.commentaires,
      statut: statut ?? this.statut,
      categorie: categorie ?? this.categorie,
      tags: tags ?? this.tags,
    );
  }

  factory ExplorerPublicationModel.fromJson(Map<String, dynamic> json) {
    PublicationType parseType(String? t) {
      if (t == 'produit' || t == 'artisan' || t == 'produitArtisan') {
        return PublicationType.produitArtisan;
      }
      if (t == 'festival' || t == 'evenement' || t == 'festivalEvenement') {
        return PublicationType.festivalEvenement;
      }
      return PublicationType.patrimoine;
    }

    return ExplorerPublicationModel(
      id: (json['id'] ?? '').toString(),
      type: parseType(json['type']),
      titre: json['titre'] ?? json['nom'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['afficheUrl'] ?? '',
      auteur: json['auteur'] ?? json['nomOrganisateur'] ?? json['nomComplet'] ?? 'Artisan / Promoteur',
      localisation: json['localisation'] ?? json['lieu'] ?? json['ville'] ?? 'Mali',
      prix: json['prix']?.toString(),
      date: json['date'] ?? json['dateDebut']?.toString(),
      vues: (json['vues'] as num?)?.toInt() ?? 0,
      commentaires: (json['nombreCommentaires'] as num?)?.toInt() ?? 0,
      statut: (json['statut'] ?? 'VALIDE').toString().toUpperCase(),
      categorie: json['categorie'] ?? 'Culture & Artisanat',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'titre': titre,
      'description': description,
      'imageUrl': imageUrl,
      'auteur': auteur,
      'localisation': localisation,
      'prix': prix,
      'date': date,
      'vues': vues,
      'commentaires': commentaires,
      'statut': statut,
      'categorie': categorie,
      'tags': tags,
    };
  }

  static const List<ExplorerPublicationModel> initialPublications = [
    // Produits d'artisans validés
    ExplorerPublicationModel(
      id: 'art-001',
      type: PublicationType.produitArtisan,
      titre: "Canari d'argile soudanais de luxe",
      description:
          "Pot d'argile façonné main selon les traditions millénaires de Djenné, orné de motifs géométriques et symboles spirituels sahéliens.",
      imageUrl:
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?q=80&w=800&auto=format&fit=crop',
      auteur: 'Mamadou Traoré (Maître potier)',
      localisation: 'Djenné, Région de Mopti',
      prix: '25 000 FCFA',
      vues: 42,
      commentaires: 8,
      statut: 'VALIDE',
      categorie: 'Poterie traditionnelle',
      tags: ['Terre cuite', 'Djenné', 'Décoration'],
    ),
    ExplorerPublicationModel(
      id: 'art-002',
      type: PublicationType.produitArtisan,
      titre: "Bogolan traditionnel teint à la boue du Niger",
      description:
          "Tissu noble en cotonnade brute tissée main, teint aux décoctions d'écorces sauvages et à la boue fermentée sacrée du fleuve Djoliba.",
      imageUrl:
          'https://images.unsplash.com/photo-1606744824163-985d376605aa?q=80&w=800&auto=format&fit=crop',
      auteur: 'Aminata Diarra (Atelier Bogolan)',
      localisation: 'Ségou, Cité des Balanzans',
      prix: '15 000 FCFA',
      vues: 67,
      commentaires: 12,
      statut: 'VALIDE',
      categorie: 'Textile & Teinture naturelle',
      tags: ['Bogolan', 'Ségou', 'Mode africaine'],
    ),
    ExplorerPublicationModel(
      id: 'art-003',
      type: PublicationType.produitArtisan,
      titre: "Croix d'Agadez & Pendentif Touareg en Argent ciselé",
      description:
          "Bijou protecteur ancestral sculpté dans l'argent massif par les artisans nomades du désert, gravé d'idéogrammes Tifinagh sacrés.",
      imageUrl:
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?q=80&w=800&auto=format&fit=crop',
      auteur: 'Alhousseini Ag Rhissa (Orfèvre)',
      localisation: 'Tombouctou, La Cité Mystérieuse',
      prix: '45 000 FCFA',
      vues: 89,
      commentaires: 15,
      statut: 'VALIDE',
      categorie: 'Bijouterie fine d\'argent',
      tags: ['Argent', 'Touareg', 'Protection'],
    ),

    // Festivals et événements culturels validés
    ExplorerPublicationModel(
      id: 'fest-001',
      type: PublicationType.festivalEvenement,
      titre: 'Festival sur le Niger — Ségou Art 2027',
      description:
          'Grand rendez-vous panafricain de musique sur les berges du fleuve Niger, expositions d\'art contemporain, danses de masques et foire artisanale internationale.',
      imageUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=800&auto=format&fit=crop',
      auteur: 'Fondation Festival sur le Niger (Promoteur)',
      localisation: 'Ségou, Berges du fleuve Niger',
      date: '04 - 08 Février 2027',
      prix: 'Entrée libre / Pass VIP',
      vues: 154,
      commentaires: 23,
      statut: 'VALIDE',
      categorie: 'Musique & Arts visuels',
      tags: ['Festival', 'Ségou', 'Panafricain'],
    ),
    ExplorerPublicationModel(
      id: 'fest-002',
      type: PublicationType.festivalEvenement,
      titre: 'Festival des Masques & Traditions Dogon (FESTIMA)',
      description:
          'Sorties rituelles des masques Kanaga et Sirigé, danses sur échasses et contes sous l\'arbre à palabres au cœur des falaises millénaires de Bandiagara.',
      imageUrl:
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?q=80&w=800&auto=format&fit=crop',
      auteur: 'Agence Sahel Roots Événements (Promoteur)',
      localisation: 'Bandiagara & Mopti',
      date: '20 - 25 Mars 2027',
      prix: '5 000 FCFA',
      vues: 112,
      commentaires: 19,
      statut: 'VALIDE',
      categorie: 'Cérémonie & Rituels ancestraux',
      tags: ['Masques', 'Dogon', 'UNESCO'],
    ),
    ExplorerPublicationModel(
      id: 'fest-003',
      type: PublicationType.festivalEvenement,
      titre: 'Biennale Artistique & Culturelle Nationale',
      description:
          'Compétition nationale réunissant les troupes d\'artistes de toutes les régions du Mali : chœurs traditionnels, ballets folkloriques et orchestres modernes.',
      imageUrl:
          'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=800&auto=format&fit=crop',
      auteur: 'Direction Nationale de la Culture',
      localisation: 'Bamako, Palais de la Culture',
      date: '10 - 17 Décembre 2027',
      prix: '2 000 FCFA',
      vues: 205,
      commentaires: 34,
      statut: 'VALIDE',
      categorie: 'Culture & Fraternité nationale',
      tags: ['Biennale', 'Bamako', 'Mali Kura'],
    ),
  ];
}

