class HomeSlideModel {
  final int id;
  final String titre;
  final String? sousTitre;
  final String? legende;
  final String imageUrl;
  final String? lienAction;
  final int ordre;
  final bool actif;
  final bool prioritaire;

  const HomeSlideModel({
    required this.id,
    required this.titre,
    this.sousTitre,
    this.legende,
    required this.imageUrl,
    this.lienAction,
    this.ordre = 0,
    this.actif = true,
    this.prioritaire = false,
  });

  factory HomeSlideModel.fromJson(Map<String, dynamic> json) {
    return HomeSlideModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titre: json['titre'] ?? '',
      sousTitre: json['sousTitre'],
      legende: json['legende'],
      imageUrl: json['imageUrl'] ?? 'assets/images/home_hero.jpeg',
      lienAction: json['lienAction'],
      ordre: json['ordre'] is int ? json['ordre'] : int.tryParse(json['ordre']?.toString() ?? '0') ?? 0,
      actif: json['actif'] ?? true,
      prioritaire: json['prioritaire'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'sousTitre': sousTitre,
      'legende': legende,
      'imageUrl': imageUrl,
      'lienAction': lienAction,
      'ordre': ordre,
      'actif': actif,
      'prioritaire': prioritaire,
    };
  }

  /// Liste de secours offline si le backend est injoignable
  static List<HomeSlideModel> get defaultSlides => const [
    HomeSlideModel(
      id: 1,
      titre: 'Tombouctou la Mystérieuse',
      sousTitre: 'Patrimoine Mondial de l\'UNESCO',
      legende: 'Cité des 333 saints, joyau du commerce caravanier transsaharien et des manuscrits anciens.',
      imageUrl: 'assets/images/home_hero.jpeg',
      lienAction: '/city-detail',
      ordre: 1,
      actif: true,
      prioritaire: true,
    ),
    HomeSlideModel(
      id: 2,
      titre: 'Djenné & sa Grande Mosquée',
      sousTitre: 'Chef-d\'œuvre d\'architecture en terre crue',
      legende: 'Le plus imposant édifice au monde en banco, symbole de la civilisation soudano-sahélienne.',
      imageUrl: 'assets/images/djenne_cover.jpeg',
      lienAction: '/city-detail',
      ordre: 2,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 3,
      titre: 'Le Pays Dogon & la Falaise',
      sousTitre: 'Sanctuaire culturel et cosmogonique',
      legende: 'Villages troglodytiques suspendus à la falaise de Bandiagara et danses traditionnelles rituelles.',
      imageUrl: 'assets/images/explorer_360.jpeg',
      lienAction: '/region-detail',
      ordre: 3,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 4,
      titre: 'Bamako, Perle du Djoliba',
      sousTitre: 'Capitale dynamique et culturelle',
      legende: 'Cité vivante bordée par le fleuve Niger, berceau des arts et de la musique mandingue.',
      imageUrl: 'assets/images/bamako_cover.jpeg',
      lienAction: '/city-detail',
      ordre: 4,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 5,
      titre: 'Ségou, Cité des Balanzans',
      sousTitre: 'Capitale historique du Royaume Bambara',
      legende: 'Terre de traditions, de bogolan et du festival sur le Niger, haut lieu de dignité.',
      imageUrl: 'assets/images/segou_cover.jpg',
      lienAction: '/city-detail',
      ordre: 5,
      actif: true,
      prioritaire: false,
    ),
  ];
}

