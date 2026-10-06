class VilleModel {
  final int id;
  final String nom;
  final String region;
  final String? nbreHbt;
  final String description;
  final String? cordonnees;
  final String imageUrl;
  final List<dynamic>? lieuxHistoriques;

  const VilleModel({
    required this.id,
    required this.nom,
    required this.region,
    this.nbreHbt,
    required this.description,
    this.cordonnees,
    required this.imageUrl,
    this.lieuxHistoriques,
  });

  factory VilleModel.fromJson(Map<String, dynamic> json) {
    final nomVille = json['nom'] ?? json['nomVille'] ?? '';
    return VilleModel(
      id: json['id'] ?? json['idVille'] ?? 0,
      nom: nomVille,
      region: json['region'] ?? '',
      nbreHbt: json['nbreHbt']?.toString(),
      description: json['description'] ?? '',
      cordonnees: json['cordonnees'] ?? '',
      imageUrl: _getImageForCity(nomVille),
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

  static String _getImageForCity(String cityName) {
    final lower = cityName.toLowerCase();
    if (lower.contains('tombouctou')) {
      return 'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('djenné') || lower.contains('djenne')) {
      return 'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('bamako')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('mopti')) {
      return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('ségou') || lower.contains('segou')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('sikasso')) {
      return 'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=600&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=600&auto=format&fit=crop';
  }
}
