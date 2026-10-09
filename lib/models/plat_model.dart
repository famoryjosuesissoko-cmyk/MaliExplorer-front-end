class PlatIngredient {
  final String nom;
  final String? quantite;
  final String? icone;

  const PlatIngredient({
    required this.nom,
    this.quantite,
    this.icone,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        if (quantite != null) 'quantite': quantite,
        if (icone != null) 'icone': icone,
      };

  factory PlatIngredient.fromJson(Map<String, dynamic> json) => PlatIngredient(
        nom: json['nom'] ?? '',
        quantite: json['quantite'],
        icone: json['icone'],
      );
}

class PlatModel {
  final int id;
  final String nom;
  final String description;
  final int? nbrePersonnes;
  final String? tempsCuisson;
  final String? difficulte;
  final String imageUrl;
  final List<String> regions;
  final List<String> ethnies;
  final List<PlatIngredient> ingredients;
  final String? secretPreparation;
  final bool isFavorite;

  const PlatModel({
    required this.id,
    required this.nom,
    required this.description,
    this.nbrePersonnes,
    this.tempsCuisson,
    this.difficulte,
    required this.imageUrl,
    this.regions = const [],
    this.ethnies = const [],
    this.ingredients = const [],
    this.secretPreparation,
    this.isFavorite = false,
  });

  static String getLocalPhoto(String dishName) {
    final lower = dishName.toLowerCase();
    if (lower.contains('tiga') || lower.contains('arachide')) {
      return 'assets/images/plats/tiguadegue_na.jpeg';
    } else if (lower.contains('saka')) {
      return 'assets/images/plats/sakasaka.jpeg';
    } else if (lower.contains('fakoye')) {
      return 'assets/images/plats/fakoye.jpeg';
    } else if (lower.contains('tô') || lower.contains('to ') || lower == 'to') {
      return 'assets/images/plats/to.jpeg';
    } else if (lower.contains('zaamin') || lower.contains('gras')) {
      return 'assets/images/plats/zaamin.jpeg';
    } else if (lower.contains('widjila')) {
      return 'assets/images/plats/widjila.jpeg';
    }
    return 'assets/images/plats/tiguadegue_na.jpeg';
  }

  String get displayPhoto {
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }
    return getLocalPhoto(nom);
  }

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

    // Récupération ou attribution des ingrédients
    List<PlatIngredient> dishIngredients = [];
    if (json['ingredients'] is List) {
      for (var item in json['ingredients']) {
        if (item is Map<String, dynamic>) {
          dishIngredients.add(PlatIngredient.fromJson(item));
        } else if (item is String) {
          dishIngredients.add(PlatIngredient(nom: item));
        }
      }
    }

    // Si pas d'ingrédients dans le JSON, fallback sur la recette culturelle
    if (dishIngredients.isEmpty) {
      final defaultMatch = defaultPlats.firstWhere(
        (p) => p.nom.toLowerCase().contains(nomPlat.toLowerCase()) ||
            nomPlat.toLowerCase().contains(p.nom.toLowerCase()),
        orElse: () => defaultPlats.first,
      );
      dishIngredients = defaultMatch.ingredients;
    }

    return PlatModel(
      id: json['id'] ?? json['idPlat'] ?? 0,
      nom: nomPlat,
      description: json['description'] ?? '',
      nbrePersonnes: json['nbrePersonnes'] as int? ?? 5,
      tempsCuisson: json['tempsCuisson'] ?? '1h 15 min',
      difficulte: json['difficulte'] ?? 'Traditionnelle',
      imageUrl: getLocalPhoto(nomPlat),
      regions: regionNames,
      ethnies: ethnieNames,
      ingredients: dishIngredients,
      secretPreparation: json['secretPreparation'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'nbrePersonnes': nbrePersonnes,
      'tempsCuisson': tempsCuisson,
      'difficulte': difficulte,
      'imageUrl': imageUrl,
      'regions': regions,
      'ethnies': ethnies,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'secretPreparation': secretPreparation,
      'isFavorite': isFavorite,
    };
  }

  static const List<PlatModel> defaultPlats = [
    PlatModel(
      id: 1,
      nom: 'Tigadèguèna',
      description:
          'Plat national incontournable mijoté dans une onctueuse sauce à base de pâte d’arachide pure torréfiée, relevé aux tomates fraîches et patates douces fondantes.',
      nbrePersonnes: 6,
      tempsCuisson: '1h 15 min',
      difficulte: 'Facile',
      imageUrl: 'assets/images/plats/tiguadegue_na.jpeg',
      regions: ['Ségou', 'Bamako', 'Koulikoro'],
      ethnies: ['Bambara', 'Malinké'],
      ingredients: [
        PlatIngredient(nom: 'Pâte d\'arachide pure (Tigadèguè)', quantite: '250 g', icone: '🥜'),
        PlatIngredient(nom: 'Viande de bœuf ou poulet fermier', quantite: '800 g', icone: '🍗'),
        PlatIngredient(nom: 'Concentré de tomate & tomates fraîches', quantite: '3 cuillères', icone: '🍅'),
        PlatIngredient(nom: 'Patates douces ou morceaux de manioc', quantite: '3 moyennes', icone: '🥔'),
        PlatIngredient(nom: 'Oignons émincés, ail & laurier', quantite: '2 gros', icone: '🧅'),
        PlatIngredient(nom: 'Piments antillais frais entiers', quantite: '2 pièces', icone: '🌶️'),
      ],
      secretPreparation:
          'Laisser mijoter à feu très doux en fin de cuisson jusqu\'à ce que la précieuse huile rouge d\'arachide remonte délicatement en surface.',
    ),
    PlatModel(
      id: 2,
      nom: 'Fakoye',
      description:
          'Mets royal et raffiné du Nord Mali (Tombouctou et Gao), préparé à base de feuilles séchées de corète potagère, d\'épices sahariennes rares et de viande de mouton.',
      nbrePersonnes: 5,
      tempsCuisson: '1h 45 min',
      difficulte: 'Expert',
      imageUrl: 'assets/images/plats/fakoye.jpeg',
      regions: ['Tombouctou', 'Gao'],
      ethnies: ['Songhaï', 'Touareg'],
      ingredients: [
        PlatIngredient(nom: 'Feuilles de corète séchées et pilées (Fakohou)', quantite: '200 g', icone: '🌿'),
        PlatIngredient(nom: 'Viande de mouton gras ou gigot', quantite: '1 kg', icone: '🥩'),
        PlatIngredient(nom: 'Soumbala traditionnel de Tombouctou', quantite: '2 c. à soupe', icone: '🧄'),
        PlatIngredient(nom: 'Beurre de karité pur ou beurre végétal', quantite: '100 g', icone: '🧈'),
        PlatIngredient(nom: 'Épices fakoye (anis, clou de girofle, cannelle)', quantite: '1 sachet', icone: '✨'),
        PlatIngredient(nom: 'Pâte de dattes sauvages (pour adoucir)', quantite: '3 pièces', icone: '🌴'),
      ],
      secretPreparation:
          'Le noircissement des feuilles de corète demande une attention extrême : elles doivent cuire longuement dans le gras de viande sans jamais attacher.',
    ),
    PlatModel(
      id: 3,
      nom: 'Tô à la sauce Gombo',
      description:
          'Pilier nourricier du quotidien malien : une pâte compacte et soyeuse de farine de mil blanc ou maïs, accompagnée d\'une sauce gluante de gombo frais parfumé.',
      nbrePersonnes: 4,
      tempsCuisson: '45 min',
      difficulte: 'Traditionnelle',
      imageUrl: 'assets/images/plats/to.jpeg',
      regions: ['Ségou', 'Mopti', 'Sikasso'],
      ethnies: ['Bambara', 'Dogon', 'Sénoufo'],
      ingredients: [
        PlatIngredient(nom: 'Farine de mil blanc ou sorgho tamisée', quantite: '500 g', icone: '🌾'),
        PlatIngredient(nom: 'Poudre de potasse naturelle d\'arbre', quantite: '1 pincée', icone: '🧂'),
        PlatIngredient(nom: 'Gombos frais pilés ou poudre de gombo', quantite: '250 g', icone: '🥬'),
        PlatIngredient(nom: 'Poisson fumé émietté du fleuve', quantite: '300 g', icone: '🐟'),
        PlatIngredient(nom: 'Poudre de feuilles de baobab (Lalo)', quantite: '2 c. à soupe', icone: '🍃'),
        PlatIngredient(nom: 'Piment écrasé et soumbala fermenté', quantite: 'Au goût', icone: '🌶️'),
      ],
      secretPreparation:
          'Le tour de main vigoureux avec le bâton de tô (meslan) garantit une pâte élastique, brillante et sans aucun grumeau.',
    ),
    PlatModel(
      id: 4,
      nom: 'Zaamin (Riz gras malien)',
      description:
          'Riz festif et généreux des cérémonies : le riz brisé est cuit par absorption directe dans un riche bouillon corsé de viande dorée et de légumes variés.',
      nbrePersonnes: 6,
      tempsCuisson: '1h 10 min',
      difficulte: 'Moyenne',
      imageUrl: 'assets/images/plats/zaamin.jpeg',
      regions: ['Bamako', 'Kayes', 'Koulikoro'],
      ethnies: ['Bambara', 'Peul', 'Soninké'],
      ingredients: [
        PlatIngredient(nom: 'Riz brisé deux fois parfumé', quantite: '800 g', icone: '🍚'),
        PlatIngredient(nom: 'Viande de bœuf bien dorée en cocotte', quantite: '750 g', icone: '🥩'),
        PlatIngredient(nom: 'Concentré de tomate & oignons frits', quantite: '150 g', icone: '🧅'),
        PlatIngredient(nom: 'Carottes entières, chou blanc & diatou', quantite: '400 g', icone: '🥕'),
        PlatIngredient(nom: 'Poisson séché salé (Guédji) pour le parfum', quantite: '50 g', icone: '🐟'),
        PlatIngredient(nom: 'Piments habanero intacts', quantite: '3 pièces', icone: '🌶️'),
      ],
      secretPreparation:
          'Couvrir la marmite d\'un linge propre sous le couvercle pour cuire le riz à l\'étouffée et capturer toutes les vapeurs parfumées.',
    ),
    PlatModel(
      id: 5,
      nom: 'Widjila',
      description:
          'Spécialité légendaire des rives du fleuve au Nord : de savoureuses boules de pain à la pâte levée cuites délicatement à la vapeur au couscoussier, nappées de sauce rouge.',
      nbrePersonnes: 4,
      tempsCuisson: '1h 00 min',
      difficulte: 'Traditionnelle',
      imageUrl: 'assets/images/plats/widjila.jpeg',
      regions: ['Tombouctou', 'Gao'],
      ethnies: ['Songhaï', 'Touareg'],
      ingredients: [
        PlatIngredient(nom: 'Farine de blé fine pour pains vapeur', quantite: '500 g', icone: '🍞'),
        PlatIngredient(nom: 'Levure boulangère active', quantite: '1 sachet', icone: '🥖'),
        PlatIngredient(nom: 'Morceaux de gigot d\'agneau ou chèvre', quantite: '600 g', icone: '🍖'),
        PlatIngredient(nom: 'Sauce tomate aux oignons caramélisés', quantite: '400 ml', icone: '🍅'),
        PlatIngredient(nom: 'Ail sauvage et coriandre moulue', quantite: '1 c. à café', icone: '🧄'),
        PlatIngredient(nom: 'Piment doux sahélien', quantite: '2 pincées', icone: '🌶️'),
      ],
      secretPreparation:
          'Les boules de pâte doivent reposer 30 minutes avant d\'être cuites à la vapeur jusqu\'à devenir aériennes et spongieuses.',
    ),
    PlatModel(
      id: 6,
      nom: 'Sakasaka (Sauce feuilles de manioc)',
      description:
          'Délice végétal et marin à la fois : jeunes feuilles de manioc pilées au mortier, mijotées de longues heures avec de l\'huile de palme rouge et du poisson fumé.',
      nbrePersonnes: 5,
      tempsCuisson: '2h 00 min',
      difficulte: 'Moyenne',
      imageUrl: 'assets/images/plats/sakasaka.jpeg',
      regions: ['Sikasso', 'Kayes'],
      ethnies: ['Soninké', 'Malinké'],
      ingredients: [
        PlatIngredient(nom: 'Jeunes feuilles de manioc fraîches pilées', quantite: '500 g', icone: '🌿'),
        PlatIngredient(nom: 'Huile de palme rouge non raffinée', quantite: '150 ml', icone: '🥥'),
        PlatIngredient(nom: 'Capitaine ou mâchoiron fumé désarêté', quantite: '400 g', icone: '🐟'),
        PlatIngredient(nom: 'Pâte d\'arachide crémeuse', quantite: '2 c. à soupe', icone: '🥜'),
        PlatIngredient(nom: 'Poudre de crevettes séchées', quantite: '50 g', icone: '🦐'),
        PlatIngredient(nom: 'Oignons violets & gousses d\'ail écrasées', quantite: '3 pièces', icone: '🧄'),
      ],
      secretPreparation:
          'Faire bouillir les feuilles de manioc seules pendant au moins 45 minutes pour neutraliser l\'amertume avant d\'incorporer l\'huile de palme rouge.',
    ),
  ];
}
