class VilleModel {
  final int id;
  final String nom;
  final String region;
  final String? nbreHbt;
  final String description;
  final String? cordonnees;
  final String imageUrl;
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
    this.misEnAvantHome = false,
    this.ordreHome = 0,
    this.lieuxHistoriques,
  });

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    final nomVille = json['nom'] ?? json['nomVille'] ?? '';
    final rawImg = json['imageUrl'] ?? json['photoUrl'];
    return VilleModel(
      id: json['id'] ?? json['idVille'] ?? 0,
      nom: nomVille,
      region: json['region'] ?? '',
      nbreHbt: json['nbreHbt']?.toString(),
      description: json['description'] ?? '',
      cordonnees: json['cordonnees'] ?? '',
      imageUrl: (rawImg != null && rawImg.toString().trim().isNotEmpty)
          ? rawImg.toString().trim()
          : _getImageForCity(nomVille),
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
}
