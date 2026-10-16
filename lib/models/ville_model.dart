class VilleModel {
  final int id;
  final String nom;
  final String region;
  final String? nbreHbt;
  final String description;
  final String? cordonnees;
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
    required this.imageUrl,
    this.images = const [],
    this.misEnAvantHome = false,
    this.ordreHome = 0,
    this.lieuxHistoriques,
  });

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    final nomVille = json['nom'] ?? json['nomVille'] ?? '';
    final rawImg = json['imageUrl'] ?? json['photoUrl'];

    final List<String> parsedImages = [];
    if (json['images'] is List) {
      for (final item in json['images']) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedImages.add(item.toString().trim());
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
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) {
          mainImg = parts.first;
          for (final p in parts) {
            if (!parsedImages.contains(p)) {
              parsedImages.add(p);
            }
          }
        }
      } else {
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

    return VilleModel(
      id: json['id'] ?? json['idVille'] ?? 0,
      nom: nomVille,
      region: json['region'] ?? '',
      nbreHbt: json['nbreHbt']?.toString(),
      description: json['description'] ?? '',
      cordonnees: json['cordonnees'] ?? '',
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
      'imageUrl': imageUrl,
      'images': images,
      'lieuxHistoriques': lieuxHistoriques,
    };
  }

  static String getLocalPhoto(String cityName) {
    return _getImageForCity(cityName);
  }

  String get displayPhoto =>
      imageUrl.isNotEmpty
          ? imageUrl
          : getLocalPhoto(nom);

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
    }
    return 'assets/images/bamako_cover.jpeg';
  }

  static const List<VilleModel> defaultVilles = [
    VilleModel(
      id: 1,
      nom: 'Tombouctou',
      region: 'Tombouctou',
      nbreHbt: '85 000',
      description: 'Cité des 333 saints et carrefour historique des caravanes transsahariennes.',
      imageUrl: 'assets/images/tombouctou_hero.jpeg',
      images: ['assets/images/tombouctou_hero.jpeg', 'assets/images/tombouctou_gallery_1.jpeg', 'assets/images/tombouctou_gallery_2.jpeg'],
    ),
    VilleModel(
      id: 2,
      nom: 'Djenné',
      region: 'Mopti',
      nbreHbt: '32 000',
      description: 'Joyau de terre crue classé au patrimoine mondial avec sa majestueuse Grande Mosquée.',
      imageUrl: 'assets/images/djenne_cover.jpeg',
      images: ['assets/images/djenne_cover.jpeg', 'assets/images/djenne_gallery_1.jpeg', 'assets/images/djenne_gallery_2.jpeg'],
    ),
    VilleModel(
      id: 3,
      nom: 'Ségou',
      region: 'Ségou',
      nbreHbt: '135 000',
      description: 'Ancienne capitale du puissant royaume bambara le long des rives paisibles du Niger.',
      imageUrl: 'assets/images/segou_cover.jpg',
      images: ['assets/images/segou_cover.jpg', 'assets/images/segou_gallery_1.jpg', 'assets/images/segou_gallery_2.jpeg'],
    ),
    VilleModel(
      id: 4,
      nom: 'Mopti',
      region: 'Mopti',
      nbreHbt: '115 000',
      description: 'La Venise malienne, confluent bouillonnant du fleuve Niger et du fleuve Bani.',
      imageUrl: 'assets/images/mopti_cover.jpg',
      images: ['assets/images/mopti_cover.jpg', 'assets/images/mopti_gallery_1.jpg', 'assets/images/mopti_gallery_2.jpeg'],
    ),
    VilleModel(
      id: 5,
      nom: 'Sikasso',
      region: 'Sikasso',
      nbreHbt: '225 000',
      description: 'Capitale du Kénédougou, terre verdoyante d\'abondance agricole et bastion du Tata.',
      imageUrl: 'assets/images/sikasso_cover.jpeg',
      images: ['assets/images/sikasso_cover.jpeg', 'assets/images/sikasso_gallery_1.jpg', 'assets/images/sikasso_gallery_2.jpg'],
    ),
    VilleModel(
      id: 6,
      nom: 'Bamako',
      region: 'District de Bamako',
      nbreHbt: '3 000 000',
      description: 'Capitale vibrante et dynamique au pied des monts Mandingues, traversée par le Djoliba.',
      imageUrl: 'assets/images/bamako_cover.jpeg',
      images: ['assets/images/bamako_cover.jpeg', 'assets/images/bamako_gallery_1.jpeg', 'assets/images/bamako_gallery_2.jpeg'],
    ),
  ];
}
