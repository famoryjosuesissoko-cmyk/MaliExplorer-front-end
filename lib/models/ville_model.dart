class VilleModel {
  final int id;
  final String nom;
  final String region;
  final String? nbreHbt;
  final String description;
  final String? cordonnees;
  final double? latitude;
  final double? longitude;
  final String imageUrl;
  final List<String> images;
  final bool misEnAvantHome;
  final int ordreHome;
  final List<dynamic>? lieuxHistoriques;

  const VilleModel({
    required this.id,
    required this.nom,
    required this.region,
    this.nbreHbt,
    required this.description,
    this.cordonnees,
    this.latitude,
    this.longitude,
    required this.imageUrl,
    this.images = const [],
    this.misEnAvantHome = false,
    this.ordreHome = 0,
    this.lieuxHistoriques,
  });

  static bool _isWrongSharedSlideUrl(String url, String cityName) {
    final lowerName = cityName.toLowerCase();
    if (!lowerName.contains('tombouctou') && url.contains('deuxieme_imagehome.jpeg')) {
      return true;
    }
    if (!lowerName.contains('bandiagara') && !lowerName.contains('dogon') && url.contains('Africa_-_Mali_-_Banani.jpeg')) {
      return true;
    }
    if (url.contains('unsplash.com')) {
      return true;
    }
    return false;
  }

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    final nomVille = (json['nom'] ?? json['nomVille'] ?? '').toString();
    final rawImg = json['imageUrl'] ?? json['photoUrl'];

    final List<String> parsedImages = [];
    if (json['images'] is List) {
      for (final item in json['images']) {
        final s = item?.toString().trim() ?? '';
        if (s.isNotEmpty && !_isWrongSharedSlideUrl(s, nomVille)) {
          parsedImages.add(s);
        }
      }
    }

    String mainImg = '';
    if (rawImg != null && rawImg.toString().trim().isNotEmpty) {
      final str = rawImg.toString().trim();
      if (str.contains(',')) {
        final parts = str
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && !_isWrongSharedSlideUrl(s, nomVille))
            .toList();
        if (parts.isNotEmpty) {
          mainImg = parts.first;
          for (final p in parts) {
            if (!parsedImages.contains(p)) {
              parsedImages.add(p);
            }
          }
        }
      } else if (!_isWrongSharedSlideUrl(str, nomVille)) {
        mainImg = str;
      }
    }

    if (mainImg.isEmpty && parsedImages.isNotEmpty) {
      mainImg = parsedImages.first;
    }
    if (mainImg.isEmpty) {
      mainImg = _getImageForCity(nomVille);
    }
    if (parsedImages.isEmpty && mainImg.isNotEmpty) {
      parsedImages.add(mainImg);
    }

    // Extraction robuste des coordonnées géographiques GPS
    double? lat = (json['latitude'] as num?)?.toDouble();
    double? lng = (json['longitude'] as num?)?.toDouble();
    final rawCoords = json['cordonnees']?.toString();
    if ((lat == null || lng == null) && rawCoords != null && rawCoords.contains(',')) {
      final parts = rawCoords.split(',');
      if (parts.length >= 2) {
        lat ??= double.tryParse(parts[0].trim());
        lng ??= double.tryParse(parts[1].trim());
      }
    }

    final rawPop = (json['nbreHbt'] ?? json['population'])?.toString().trim();

    return VilleModel(
      id: json['id'] ?? json['idVille'] ?? 0,
      nom: nomVille,
      region: json['region'] ?? '',
      nbreHbt: (rawPop != null && rawPop.isNotEmpty) ? rawPop : null,
      description: json['description'] ?? '',
      cordonnees: rawCoords ?? (lat != null && lng != null ? '$lat, $lng' : null),
      latitude: lat,
      longitude: lng,
      imageUrl: mainImg,
      images: parsedImages,
      misEnAvantHome: json['misEnAvantHome'] ?? false,
      ordreHome: json['ordreHome'] is int ? json['ordreHome'] : int.tryParse(json['ordreHome']?.toString() ?? '0') ?? 0,
      lieuxHistoriques: json['lieuxHistoriques'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'region': region,
      'nbreHbt': nbreHbt,
      'description': description,
      'cordonnees': cordonnees,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'images': images,
      'lieuxHistoriques': lieuxHistoriques,
    };
  }

  VilleModel copyWith({
    int? id,
    String? nom,
    String? region,
    String? nbreHbt,
    String? description,
    String? cordonnees,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? images,
    bool? misEnAvantHome,
    int? ordreHome,
    List<dynamic>? lieuxHistoriques,
  }) {
    return VilleModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      region: region ?? this.region,
      nbreHbt: nbreHbt ?? this.nbreHbt,
      description: description ?? this.description,
      cordonnees: cordonnees ?? this.cordonnees,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      misEnAvantHome: misEnAvantHome ?? this.misEnAvantHome,
      ordreHome: ordreHome ?? this.ordreHome,
      lieuxHistoriques: lieuxHistoriques ?? this.lieuxHistoriques,
    );
  }

  static String getLocalPhoto(String cityName) {
    return _getImageForCity(cityName);
  }

  String get displayPhoto =>
      imageUrl.isNotEmpty
          ? imageUrl
          : getLocalPhoto(nom);

  static const String _supabaseVillesBase =
      'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes';

  static String _getImageForCity(String cityName) {
    final lower = cityName.toLowerCase();
    if (lower.contains('tombouctou')) {
      return 'assets/images/tombouctou_hero.jpeg';
    } else if (lower.contains('djenné') || lower.contains('djenne')) {
      return 'assets/images/djenne_cover.jpeg';
    } else if (lower.contains('bamako')) {
      return 'assets/images/bamako_cover.jpeg';
    } else if (lower.contains('mopti')) {
      return 'assets/images/mopti_cover.jpg';
    } else if (lower.contains('ségou') || lower.contains('segou')) {
      return 'assets/images/segou_cover.jpg';
    } else if (lower.contains('sikasso')) {
      return 'assets/images/sikasso_cover.jpeg';
    } else if (lower.contains('gao')) {
      return 'assets/images/Gao1.jpg';
    } else if (lower.contains('kidal')) {
      return 'assets/images/Kidal1.jpg';
    } else if (lower.contains('ménaka') || lower.contains('menaka')) {
      return 'assets/images/Menaka1.jpg';
    } else if (lower.contains('taoudéni') || lower.contains('taoudeni') || lower.contains('taoudenit')) {
      return 'assets/images/Taoudeni1.JPG';
    } else if (lower.contains('kayes')) {
      return '$_supabaseVillesBase/a74e7a57-4181-4298-b98a-bf3c59702646_Fleuve_S_n_gal_Kayes_Mali.jpeg';
    } else if (lower.contains('koulikoro')) {
      return '$_supabaseVillesBase/910921e0-844f-4af7-b5dd-5aab12fcbaef_vestibule-koulikoro.jpg';
    } else if (lower.contains('koutiala')) {
      return '$_supabaseVillesBase/2e0e6bf5-0023-494b-9157-f24aa881512b_koutiala.jpeg';
    } else if (lower.contains('san')) {
      return '$_supabaseVillesBase/4aac1e77-f062-4bf8-8d8f-9b8ec39e1df0_san_sanke-mon.jpg';
    } else if (lower.contains('kéniéba') || lower.contains('kenieba')) {
      return '$_supabaseVillesBase/20c147b6-b759-4b58-b974-3c4611f2b1cb_kenieba.jpeg';
    } else if (lower.contains('kita')) {
      return '$_supabaseVillesBase/8a2b87e9-7ef4-4298-8698-ac341176f1ce_kita.jpeg';
    } else if (lower.contains('bandiagara')) {
      return '$_supabaseVillesBase/092d8b10-62e7-4254-9e2e-3b97571beb46_badiangara.jpeg';
    }
    return 'assets/images/bamako_cover.jpeg';
  }

  /// Retourne la galerie locale authentique associée à une ville
  static List<String> getLocalGallery(String cityName) {
    final lower = cityName.toLowerCase();
    if (lower.contains('bamako')) {
      return const [
        'assets/images/bamako_gallery_1.jpeg',
        'assets/images/bamako_gallery_2.jpeg',
        'assets/images/bamako_cover.jpeg',
      ];
    } else if (lower.contains('djenne') || lower.contains('djenné')) {
      return const [
        'assets/pannellum/djenne_vue_aerienne_360.jpg',
        'assets/pannellum/djenne_nef_hypostyle_360.jpg',
        'assets/pannellum/djenne_cour_centrale_360.jpg',
        'assets/pannellum/djenne_minarets_zoom_360.jpg',
        'assets/pannellum/djenne_ruelle_contreforts_360.jpg',
        'assets/images/djenne_gallery_1.jpeg',
        'assets/images/djenne_gallery_2.jpeg',
        'assets/images/djenne_cover.jpeg',
      ];
    } else if (lower.contains('mopti')) {
      return const [
        'assets/images/mopti_gallery_1.jpg',
        'assets/images/mopti_gallery_2.jpeg',
        'assets/images/mopti_gallery_3.webp',
      ];
    } else if (lower.contains('segou') || lower.contains('ségou')) {
      return const [
        'assets/images/segou_gallery_1.jpg',
        'assets/images/segou_gallery_2.jpeg',
        'assets/images/segou_gallery_3.jpeg',
      ];
    } else if (lower.contains('sikasso')) {
      return const [
        'assets/images/sikasso_gallery_1.jpg',
        'assets/images/sikasso_gallery_2.jpg',
        'assets/images/sikasso_gallery_3.jpeg',
      ];
    } else if (lower.contains('tombouctou')) {
      return const [
        'assets/images/Tombouctou2.jpg',
        'assets/images/tombouctou_gallery_1.jpeg',
        'assets/images/tombouctou_gallery_2.jpeg',
        'assets/images/tombouctou_hero.jpeg',
      ];
    } else if (lower.contains('gao')) {
      return const [
        'assets/images/Gao1.jpg',
        'assets/images/Gao2.jpg',
      ];
    } else if (lower.contains('kidal')) {
      return const [
        'assets/images/Kidal1.jpg',
        'assets/images/Kidal2.jpeg',
      ];
    } else if (lower.contains('ménaka') || lower.contains('menaka')) {
      return const [
        'assets/images/Menaka1.jpg',
        'assets/images/Menaka2.jpg',
      ];
    } else if (lower.contains('taoudéni') || lower.contains('taoudeni') || lower.contains('taoudenit')) {
      return const [
        'assets/images/Taoudeni1.JPG',
      ];
    }
    return [_getImageForCity(cityName)];
  }

  static const List<VilleModel> defaultVilles = [
    VilleModel(
      id: 1,
      nom: 'Tombouctou',
      region: 'Région de Tombouctou',
      nbreHbt: '54 000',
      description: 'Cité des 333 saints et carrefour historique des caravanes transsahariennes.',
      imageUrl: 'assets/images/tombouctou_hero.jpeg',
      images: [
        'assets/images/tombouctou_hero.jpeg',
        'assets/images/Tombouctou2.jpg',
        'assets/images/tombouctou_gallery_1.jpeg',
        'assets/images/tombouctou_gallery_2.jpeg',
      ],
      cordonnees: '16.7666, -3.0026',
      latitude: 16.7666,
      longitude: -3.0026,
    ),
    VilleModel(
      id: 2,
      nom: 'Djenné',
      region: 'Région de Mopti',
      nbreHbt: '33 000',
      description: 'Joyau de terre crue classé au patrimoine mondial avec sa majestueuse Grande Mosquée.',
      imageUrl: 'assets/images/djenne_cover.jpeg',
      images: [
        'assets/images/djenne_cover.jpeg',
        'assets/images/djenne_gallery_1.jpeg',
        'assets/images/djenne_gallery_2.jpeg',
      ],
      cordonnees: '13.9056, -4.5533',
      latitude: 13.9056,
      longitude: -4.5533,
    ),
    VilleModel(
      id: 3,
      nom: 'Bamako',
      region: 'District de Bamako',
      nbreHbt: '3 000 000',
      description: 'Capitale vibrante et dynamique au pied des monts Mandingues, traversée par le Djoliba.',
      imageUrl: 'assets/images/bamako_cover.jpeg',
      images: [
        'assets/images/bamako_cover.jpeg',
        'assets/images/bamako_gallery_1.jpeg',
        'assets/images/bamako_gallery_2.jpeg',
      ],
      cordonnees: '12.6392, -8.0029',
      latitude: 12.6392,
      longitude: -8.0029,
    ),
    VilleModel(
      id: 4,
      nom: 'Mopti',
      region: 'Région de Mopti',
      nbreHbt: '114 000',
      description: 'La Venise malienne, confluent bouillonnant du fleuve Niger et du fleuve Bani.',
      imageUrl: 'assets/images/mopti_cover.jpg',
      images: [
        'assets/images/mopti_cover.jpg',
        'assets/images/mopti_gallery_1.jpg',
        'assets/images/mopti_gallery_2.jpeg',
        'assets/images/mopti_gallery_3.webp',
      ],
      cordonnees: '14.4958, -4.1873',
      latitude: 14.4958,
      longitude: -4.1873,
    ),
    VilleModel(
      id: 5,
      nom: 'Ségou',
      region: 'Région de Ségou',
      nbreHbt: '134 000',
      description: 'Ancienne capitale du puissant royaume bambara le long des rives paisibles du Niger.',
      imageUrl: 'assets/images/segou_cover.jpg',
      images: [
        'assets/images/segou_cover.jpg',
        'assets/images/segou_gallery_1.jpg',
        'assets/images/segou_gallery_2.jpeg',
        'assets/images/segou_gallery_3.jpeg',
      ],
      cordonnees: '13.4317, -6.2157',
      latitude: 13.4317,
      longitude: -6.2157,
    ),
    VilleModel(
      id: 6,
      nom: 'Sikasso',
      region: 'Région de Sikasso',
      nbreHbt: '226 000',
      description: 'Capitale du Kénédougou, terre verdoyante d\'abondance agricole et bastion du Tata.',
      imageUrl: 'assets/images/sikasso_cover.jpeg',
      images: [
        'assets/images/sikasso_cover.jpeg',
        'assets/images/sikasso_gallery_1.jpg',
        'assets/images/sikasso_gallery_2.jpg',
        'assets/images/sikasso_gallery_3.jpeg',
      ],
      cordonnees: '11.3176, -5.6665',
      latitude: 11.3176,
      longitude: -5.6665,
    ),
    VilleModel(
      id: 14,
      nom: 'Gao',
      region: 'Région de Gao',
      nbreHbt: '86 000',
      description: 'Cité historique sahélienne au bord du Niger, réputée pour le Tombeau des Askia et sa dune rose de Koïma.',
      imageUrl: 'assets/images/Gao1.jpg',
      images: ['assets/images/Gao1.jpg', 'assets/images/Gao2.jpg'],
      cordonnees: '16.2717, -0.0447',
      latitude: 16.2717,
      longitude: -0.0447,
    ),
    VilleModel(
      id: 15,
      nom: 'Kidal',
      region: 'Région de Kidal',
      nbreHbt: '25 000',
      description: 'Centre urbain niché dans les vallées de l\'Adrar des Ifoghas, carrefour des traditions orales et poétiques du désert.',
      imageUrl: 'assets/images/Kidal1.jpg',
      images: ['assets/images/Kidal1.jpg', 'assets/images/Kidal2.jpeg'],
      cordonnees: '18.4411, 1.4078',
      latitude: 18.4411,
      longitude: 1.4078,
    ),
    VilleModel(
      id: 16,
      nom: 'Taoudéni',
      region: 'Région de Taoudénit',
      nbreHbt: '3 000',
      description: 'Bourgade saharienne légendaire, cœur historique de l\'extraction traditionnelle des barres de sel gemme.',
      imageUrl: 'assets/images/Taoudeni1.JPG',
      images: ['assets/images/Taoudeni1.JPG'],
      cordonnees: '22.6781, -3.9842',
      latitude: 22.6781,
      longitude: -3.9842,
    ),
    VilleModel(
      id: 17,
      nom: 'Ménaka',
      region: 'Région de Ménaka',
      nbreHbt: '20 000',
      description: 'Carrefour pastoral sahélien renommé pour ses foires d\'élevage et son artisanat d\'art nomade.',
      imageUrl: 'assets/images/Menaka1.jpg',
      images: ['assets/images/Menaka1.jpg', 'assets/images/Menaka2.jpg'],
      cordonnees: '15.9182, 2.4022',
      latitude: 15.9182,
      longitude: 2.4022,
    ),
  ];
}
