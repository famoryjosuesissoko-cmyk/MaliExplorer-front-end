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

  /// Liste de secours synchronisée avec les diapositives hébergées sur Supabase Storage
  static List<HomeSlideModel> get defaultSlides => const [
    HomeSlideModel(
      id: 3,
      titre: 'Le Pays Dogon & la Falaise',
      sousTitre: 'Sanctuaire culturel et cosmogonique',
      legende: 'Villages troglodytiques suspendus à la falaise de Bandiagara et danses traditionnelles rituelles.',
      imageUrl: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/slides/0fbffaa1-70b6-47aa-8120-0e4f44226820_Africa_-_Mali_-_Banani.jpeg',
      lienAction: '/region-detail',
      ordre: 1,
      actif: true,
      prioritaire: true,
    ),
    HomeSlideModel(
      id: 4,
      titre: 'Bamako, Perle du Djoliba',
      sousTitre: 'Capitale dynamique et culturelle',
      legende: 'Cité vivante bordée par le fleuve Niger, berceau des arts et de la musique mandingue.',
      imageUrl: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/slides/d5f7889e-b437-4b62-953e-845b1f7120d6_Bamako.jpg',
      lienAction: '/city-detail',
      ordre: 2,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 2,
      titre: 'Djenné & sa Grande Mosquée',
      sousTitre: 'Chef-d\'œuvre d\'architecture en terre crue',
      legende: 'Le plus imposant édifice au monde en banco, symbole de la civilisation soudano-sahélienne.',
      imageUrl: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/slides/90af1bd4-e4df-45a1-8925-06ce135d4bf1_Great_Mosque_of_Djenn___1907___Mali_s_Mud_Icon___ArchEyes.jpeg',
      lienAction: '/city-detail',
      ordre: 3,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 5,
      titre: 'Ségou, Cité des Balanzans',
      sousTitre: 'Capitale historique du Royaume Bambara',
      legende: 'Terre de traditions, de bogolan et du festival sur le Niger, haut lieu de dignité.',
      imageUrl: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/slides/ebe5b68a-dfc2-46f8-aa33-d6444b1c22eb_La_cit__des_Balanza__w___mally_la_slameuse_Segou_.jpeg',
      lienAction: '/city-detail',
      ordre: 4,
      actif: true,
      prioritaire: false,
    ),
    HomeSlideModel(
      id: 1,
      titre: 'Tombouctou la Mystérieuse',
      sousTitre: 'Patrimoine Mondial de l\'UNESCO',
      legende: 'Cité des 333 saints, joyau du commerce caravanier transsaharien et des manuscrits anciens.',
      imageUrl: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/slides/93c7822b-966e-446c-aab2-04396325e942_deuxieme_imagehome.jpeg',
      lienAction: '/city-detail',
      ordre: 5,
      actif: true,
      prioritaire: false,
    ),
  ];
}

