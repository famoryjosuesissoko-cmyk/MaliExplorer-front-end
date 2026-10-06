class PlatModel {
  final int id;
  final String nom;
  final String description;
  final int? nbrePersonnes;
  final String imageUrl;
  final List<String> regions;
  final List<String> ethnies;
  final bool isFavorite;

  const PlatModel({
    required this.id,
    required this.nom,
    required this.description,
    this.nbrePersonnes,
    required this.imageUrl,
    this.regions = const [],
    this.ethnies = const [],
    this.isFavorite = false,
  });

  factory PlatModel.fromJson(Map<String, dynamic> json) {
    final nomPlat = json['nom'] ?? json['nomPlat'] ?? '';
    
    List<String> regionNames = [];
    if (json['regions'] is List) {
      for (var r in json['regions']) {
        if (r is Map && r['nom'] != null) {
          regionNames.add(r['nom'].toString());
        } else if (r is String) {
          regionNames.add(r);
        }
      }
    }

    List<String> ethnieNames = [];
    if (json['ethnies'] is List) {
      for (var e in json['ethnies']) {
        if (e is Map && e['nom'] != null) {
          ethnieNames.add(e['nom'].toString());
        } else if (e is String) {
          ethnieNames.add(e);
        }
      }
    }

    return PlatModel(
      id: json['id'] ?? json['idPlat'] ?? 0,
      nom: nomPlat,
      description: json['description'] ?? '',
      nbrePersonnes: json['nbrePersonnes'] as int?,
      imageUrl: _getImageForDish(nomPlat),
      regions: regionNames,
      ethnies: ethnieNames,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'nbrePersonnes': nbrePersonnes,
      'imageUrl': imageUrl,
      'regions': regions,
      'ethnies': ethnies,
      'isFavorite': isFavorite,
    };
  }

  static String _getImageForDish(String dishName) {
    final lower = dishName.toLowerCase();
    if (lower.contains('tiga') || lower.contains('arachide')) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('saka')) {
      return 'https://images.unsplash.com/photo-1512058564366-18510be2db19?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('fakoye')) {
      return 'https://images.unsplash.com/photo-1547592180-85f173990554?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('tô') || lower.contains('to')) {
      return 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('zaamin')) {
      return 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=600&auto=format&fit=crop';
    } else if (lower.contains('widjila')) {
      return 'https://images.unsplash.com/photo-1509722747041-616f39b57569?q=80&w=600&auto=format&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop';
  }
}
