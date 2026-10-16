class SearchResultItem {
  final String id;
  final String titre;
  final String? sousTitre;
  final String categorie;
  final String? description;
  final String? imageUrl;
  final String route;
  final dynamic payload;

  const SearchResultItem({
    required this.id,
    required this.titre,
    this.sousTitre,
    required this.categorie,
    this.description,
    this.imageUrl,
    required this.route,
    this.payload,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id']?.toString() ?? '',
      titre: json['titre'] ?? '',
      sousTitre: json['sousTitre'],
      categorie: json['categorie'] ?? 'Général',
      description: json['description'],
      imageUrl: json['imageUrl'],
      route: json['route'] ?? '/home',
      payload: json['payload'],
    );
  }
}

