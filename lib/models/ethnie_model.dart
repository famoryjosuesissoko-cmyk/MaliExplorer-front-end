class EthnieModel {
  final int id;
  final String nom;
  final String region;
  final String population;
  final String description;
  final String imageUrl;

  const EthnieModel({
    required this.id,
    required this.nom,
    required this.region,
    required this.population,
    required this.description,
    required this.imageUrl,
  });

  factory EthnieModel.fromJson(Map<String, dynamic> json) {
    final nomEthnie = json['nom'] ?? json['nomEthnie'] ?? '';
    return EthnieModel(
      id: json['id'] ?? json['idEthnie'] ?? 0,
      nom: nomEthnie,
      region: json['region'] ?? '',
      population: json['population'] ?? '',
      description: json['description'] ?? '',
      imageUrl: _getImageForEthnie(nomEthnie),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'region': region,
      'population': population,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  static String _getImageForEthnie(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dogon')) {
      return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=800&auto=format&fit=crop';
    } else if (lower.contains('bambara')) {
      return 'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=800&auto=format&fit=crop';
    } else if (lower.contains('peul')) {
      return 'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=800&auto=format&fit=crop';
    } else if (lower.contains('touareg')) {
      return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop';
    } else if (lower.contains('sonink')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop';
    } else if (lower.contains('malink')) {
      return 'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=800&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=800&auto=format&fit=crop';
  }
}
