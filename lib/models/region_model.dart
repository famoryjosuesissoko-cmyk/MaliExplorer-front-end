class RegionModel {
  final String id;
  final String nom;
  final String chefLieu;
  final double latitude;
  final double longitude;
  final String description;
  final String imageCover;
  final String population;
  final String superficie;
  final bool isPrioritaire;
  final List<String> attraits;
  final List<String> languesLocales;

  const RegionModel({
    required this.id,
    required this.nom,
    required this.chefLieu,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imageCover,
    required this.population,
    required this.superficie,
    this.isPrioritaire = false,
    this.attraits = const [],
    this.languesLocales = const [],
  });

  static String _formatPopulation(dynamic rawPop, String fallback) {
    if (rawPop == null) return fallback;
    final str = rawPop.toString().trim();
    if (str.isEmpty) return fallback;
    final digits = str.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty) {
      final buffer = StringBuffer();
      for (int i = 0; i < digits.length; i++) {
        if (i > 0 && (digits.length - i) % 3 == 0) {
          buffer.write(' ');
        }
        buffer.write(digits[i]);
      }
      return '${buffer.toString()} hab.';
    }
    return str.contains('hab') ? str : '$str hab.';
  }

  static bool _isInvalidRegionImage(String url, String nom) {
    if (url.isEmpty) return true;
    if (url.contains('unsplash.com')) return true;
    final lowerNom = nom.toLowerCase();
    if (!lowerNom.contains('tombouctou') && url.contains('deuxieme_imagehome.jpeg')) {
      return true;
    }
    if (!lowerNom.contains('bandiagara') && !lowerNom.contains('dogon') && url.contains('Africa_-_Mali_-_Banani.jpeg')) {
      return true;
    }
    return false;
  }

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    final rawNom = (json['nom'] ?? json['nomRegion'] ?? '').toString().trim();
    final rawChefLieu = (json['chefLieu'] ?? '').toString().trim();
    final ref = RegionData.findByNameOrChefLieu(rawNom, rawChefLieu);

    final double lat = (json['latitude'] as num?)?.toDouble() ?? ref?.latitude ?? 14.4958;
    final double lng = (json['longitude'] as num?)?.toDouble() ?? ref?.longitude ?? -4.1873;

    final rawImg = (json['imageUrl'] ?? json['imageCover'] ?? '').toString().trim();
    final String resolvedImage = !_isInvalidRegionImage(rawImg, rawNom)
        ? rawImg
        : (ref?.imageCover ?? 'assets/images/mopti_cover.jpg');

    final rawDesc = (json['description'] ?? '').toString().trim();
    final rawSup = (json['superficie'] ?? '').toString().trim();

    return RegionModel(
      id: ref?.id ?? (json['id']?.toString() ?? rawNom.toLowerCase()),
      nom: rawNom.isNotEmpty ? rawNom : (ref?.nom ?? 'Région du Mali'),
      chefLieu: rawChefLieu.isNotEmpty ? rawChefLieu : (ref?.chefLieu ?? rawNom),
      latitude: lat,
      longitude: lng,
      description: rawDesc.isNotEmpty ? rawDesc : (ref?.description ?? ''),
      imageCover: resolvedImage,
      population: _formatPopulation(
        json['population'] ?? json['nbreHbt'],
        ref?.population ?? '—',
      ),
      superficie: rawSup.isNotEmpty ? rawSup : (ref?.superficie ?? '—'),
      isPrioritaire: ref?.isPrioritaire ?? false,
      attraits: ref?.attraits ?? const [],
      languesLocales: ref?.languesLocales ?? const [],
    );
  }
}

/// Liste exhaustive et documentée des régions administratives du Mali
/// selon le découpage territorial officiel (y compris le district de Bamako)
/// avec mise en valeur initiale des 6 régions prioritaires MaliExplorer.
class RegionData {
  static const List<RegionModel> regions = [
    // 1. MOPTI (Prioritaire - 5ème région administrative)
    RegionModel(
      id: 'mopti',
      nom: 'Région de Mopti',
      chefLieu: 'Mopti',
      latitude: 14.4958,
      longitude: -4.1873,
      description:
          'Carrefour fluvial stratégique au confluent du Niger et du Bani. La région abrite la légendaire cité de Djenné, sa majestueuse Grande Mosquée en banco classée au patrimoine mondial de l’UNESCO, et les spectaculaires falaises de Bandiagara au Pays Dogon.',
      imageCover: 'assets/images/mopti_cover.jpg',
      population: '2 037 000 hab.',
      superficie: '79 017 km²',
      isPrioritaire: true,
      attraits: [
        'Grande Mosquée de Djenné (UNESCO)',
        'Port des pinasses de Mopti',
        'Falaises de Bandiagara (Pays Dogon)',
        'Architecture soudano-sahélienne en terre crue',
      ],
      languesLocales: [
        'Fulfulde (Peul)',
        'Dogon',
        'Bozo',
      ],
    ),

    // 2. BAMAKO (Prioritaire - District de la Capitale)
    RegionModel(
      id: 'bamako',
      nom: 'District de Bamako',
      chefLieu: 'Bamako',
      latitude: 12.6392,
      longitude: -8.0029,
      description:
          'Capitale politique, économique et culturelle du Mali, lovée dans la vallée du fleuve Niger au pied des monts Mandingues. Bamako vibre au rythme de ses marchés d’artisanat, de sa vie musicale et de ses musées nationaux.',
      imageCover: 'assets/images/bamako_cover.jpeg',
      population: '3 000 000 hab.',
      superficie: '252 km²',
      isPrioritaire: true,
      attraits: [
        'Musée National du Mali',
        'Parc National de Bamako',
        'Monument de l’Indépendance',
        'Grand Marché artisanal de Bamako',
      ],
      languesLocales: [
        'Bamanankan (Bambara)',
        'Maninkakan (Malinké)',
        'Fulfulde (Peul)',
      ],
    ),

    // 3. SÉGOU (Prioritaire - 4ème région administrative)
    RegionModel(
      id: 'segou',
      nom: 'Région de Ségou',
      chefLieu: 'Ségou',
      latitude: 13.4317,
      longitude: -6.2157,
      description:
          'La prestigieuse « Cité des Balanzans » et berceau du grand royaume Bambara de Biton Coulibaly. Réputée pour ses poteries traditionnelles de Kalabougou, son festival sur le Niger et son architecture coloniale en briques de terre.',
      imageCover: 'assets/images/segou_cover.jpg',
      population: '2 336 000 hab.',
      superficie: '64 821 km²',
      isPrioritaire: true,
      attraits: [
        'Village des potières de Kalabougou',
        'Vestiges de Ségou Koro',
        'Festival sur le Niger',
        'Bordures ombragées du fleuve Niger',
      ],
      languesLocales: [
        'Bamanankan (Bambara)',
        'Bozo',
        'Minianka (Mamara)',
      ],
    ),

    // 4. SIKASSO (Prioritaire - 3ème région administrative)
    RegionModel(
      id: 'sikasso',
      nom: 'Région de Sikasso',
      chefLieu: 'Sikasso',
      latitude: 11.3176,
      longitude: -5.6665,
      description:
          'Le grenier vert et agricole du Mali, capitale de l’héroïque Royaume du Kénédougou des rois Tiéba et Babemba Traoré. Célèbre pour le Tata fortifié, les magnifiques chutes d’eau de Farako et le palais du Mamelon.',
      imageCover: 'assets/images/sikasso_cover.jpeg',
      population: '2 625 000 hab.',
      superficie: '70 280 km²',
      isPrioritaire: true,
      attraits: [
        'Tata fortifié de Sikasso',
        'Chutes d’eau de Farako et du Woroni',
        'Palais du Mamelon',
        'Vergers et plantations fruitières',
      ],
      languesLocales: [
        'Sénoufo (Syenara)',
        'Bamanankan (Bambara)',
        'Minianka (Mamara)',
      ],
    ),

    // 5. TOMBOUCTOU (Prioritaire - 6ème région administrative)
    RegionModel(
      id: 'tombouctou',
      nom: 'Région de Tombouctou',
      chefLieu: 'Tombouctou',
      latitude: 16.7666,
      longitude: -3.0026,
      description:
          'La mystique « Cité des 333 saints » aux portes du Sahara, jadis phare du savoir islamique médiéval mondial. Renommée pour ses précieux manuscrits anciens, ses universités coraniques et ses trois mosquées mythiques (Djingareyber, Sankoré, Sidi Yahia).',
      imageCover: 'assets/images/home_tombouctou.jpeg',
      population: '681 000 hab.',
      superficie: '496 446 km²',
      isPrioritaire: true,
      attraits: [
        'Mosquée Djingareyber (UNESCO)',
        'Université et mosquée de Sankoré',
        'Centres de conservation des Manuscrits anciens',
        'Portes du Sahara et campements nomades',
      ],
      languesLocales: [
        'Songhaï (Koyra Chiini)',
        'Tamasheq',
        'Arabe Hassaniya',
      ],
    ),

    // 6. GAO (Prioritaire - 7ème région administrative)
    RegionModel(
      id: 'gao',
      nom: 'Région de Gao',
      chefLieu: 'Gao',
      latitude: 16.2717,
      longitude: -0.0447,
      description:
          'L’illustre capitale de l’Empire Songhaï au XVe et XVIe siècle sous l’Askia Mohammed. Traversée par le fleuve Niger, Gao fascine par le Tombeau des Askia inscrit au patrimoine mondial de l’UNESCO et la colline légendaire des dunes rouges de Koïma.',
      imageCover: 'assets/images/Gao1.jpg',
      population: '544 000 hab.',
      superficie: '170 572 km²',
      isPrioritaire: true,
      attraits: [
        'Tombeau pyramidal des Askia (UNESCO)',
        'Dune rose de Koïma',
        'Musée du Sahel',
        'Vestiges de Gao Saneye',
      ],
      languesLocales: [
        'Songhaï (Koyraboro Senni)',
        'Tamasheq',
        'Fulfulde (Peul)',
      ],
    ),

    // 7. KAYES (1ère région administrative)
    RegionModel(
      id: 'kayes',
      nom: 'Région de Kayes',
      chefLieu: 'Kayes',
      latitude: 14.4469,
      longitude: -11.4445,
      description:
          'Première région du Mali, bordée par le Sénégal et la Mauritanie. Réputée pour ses chutes majestueuses de Félou et Gouina, ses gisements d’or historiques et le Fort de Médine sur les rives du fleuve Sénégal.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/a74e7a57-4181-4298-b98a-bf3c59702646_Fleuve_S_n_gal_Kayes_Mali.jpeg',
      population: '1 996 000 hab.',
      superficie: '119 743 km²',
      isPrioritaire: false,
      attraits: [
        'Fort historique de Médine',
        'Chutes d’eau de Gouina et du Félou',
        'Lac Magui',
      ],
      languesLocales: [
        'Khassonké (Xasonga)',
        'Soninké',
        'Maninkakan (Malinké)',
      ],
    ),

    // 8. KOULIKORO (2ème région administrative)
    RegionModel(
      id: 'koulikoro',
      nom: 'Région de Koulikoro',
      chefLieu: 'Koulikoro',
      latitude: 12.8627,
      longitude: -7.5599,
      description:
          'Bordant le fleuve Niger et entourant le district de Bamako, Koulikoro est le terminus de la ligne ferroviaire Dakar-Niger et la terre du roi sorcier Soumaoro Kanté et des monts Mandingues.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/910921e0-844f-4af7-b5dd-5aab12fcbaef_vestibule-koulikoro.jpg',
      population: '2 418 000 hab.',
      superficie: '90 120 km²',
      isPrioritaire: false,
      attraits: [
        'Rocher de Soumaoro Kanté',
        'Port fluvial de Koulikoro',
        'Parc du Baoulé',
      ],
      languesLocales: [
        'Bamanankan (Bambara)',
        'Maninkakan (Malinké)',
        'Somono (Bozo)',
      ],
    ),

    // 9. KIDAL (8ème région administrative)
    RegionModel(
      id: 'kidal',
      nom: 'Région de Kidal',
      chefLieu: 'Kidal',
      latitude: 18.4411,
      longitude: 1.4078,
      description:
          'Région montagnarde et désertique de l’Adrar des Ifoghas dans le nord-est malien. Fief de la culture nomade touarègue, réputée pour ses poésies, ses gravures rupestres préhistoriques et ses paysages sahariens grandioses.',
      imageCover: 'assets/images/Kidal1.jpg',
      population: '67 000 hab.',
      superficie: '151 450 km²',
      isPrioritaire: false,
      attraits: [
        'Massif de l’Adrar des Ifoghas',
        'Gravures rupestres préhistoriques',
        'Artisanat traditionnel du cuir et de l’argent',
      ],
      languesLocales: [
        'Tamasheq',
        'Arabe Hassaniya',
        'Songhaï',
      ],
    ),

    // 10. TAOUDÉNI (9ème région administrative)
    RegionModel(
      id: 'taoudenit',
      nom: 'Région de Taoudénit',
      chefLieu: 'Taoudéni',
      latitude: 22.6781,
      longitude: -3.9842,
      description:
          'Vaste étendue désertique du grand nord malien au cœur du désert du Tanezrouft. Historiquement réputée pour ses mines de sel gemme pluriséculaires et le passage des caravanes d’azalaï reliant Tombouctou.',
      imageCover: 'assets/images/Taoudeni1.JPG',
      population: '18 000 hab.',
      superficie: '323 326 km²',
      isPrioritaire: false,
      attraits: [
        'Mines de sel gemme millénaires',
        'Route des caravanes d’azalaï',
        'Désert absolu du Tanezrouft',
      ],
      languesLocales: [
        'Arabe Hassaniya',
        'Tamasheq',
        'Songhaï',
      ],
    ),

    // 11. MÉNÉKA (10ème région administrative)
    RegionModel(
      id: 'menaka',
      nom: 'Région de Ménaka',
      chefLieu: 'Ménaka',
      latitude: 15.9182,
      longitude: 2.4022,
      description:
          'Région pastorale de l’extrême est du Mali frontalière du Niger, traversée par la vallée fossile de l’Azawagh. Connue pour ses traditions d’élevage et son artisanat d’art.',
      imageCover: 'assets/images/Menaka1.jpg',
      population: '54 000 hab.',
      superficie: '81 040 km²',
      isPrioritaire: false,
      attraits: [
        'Vallée de l’Azawagh',
        'Artisanat pastoral',
        'Traditions d’élevage nomade',
      ],
      languesLocales: [
        'Tamasheq',
        'Songhaï',
        'Arabe Hassaniya',
      ],
    ),

    // 12. KOUTIALA (Région administrative - Capitale du coton)
    RegionModel(
      id: 'koutiala',
      nom: 'Région de Koutiala',
      chefLieu: 'Koutiala',
      latitude: 12.3917,
      longitude: -5.4642,
      description:
          'Capitale de l’or blanc (coton) et carrefour agro-industriel majeur du sud malien. Koutiala est un creuset culturel vibrant du peuple Minianka et un carrefour économique dynamique entre Sikasso, San et Ségou.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/2e0e6bf5-0023-494b-9157-f24aa881512b_koutiala.jpeg',
      population: '575 000 hab.',
      superficie: '18 000 km²',
      isPrioritaire: false,
      attraits: [
        'Capitale du coton (l’or blanc du Mali)',
        'Usines d’égrenage de la CMDT',
        'Culture et artisanat Minianka',
        'Marché central agro-pastoral',
      ],
      languesLocales: [
        'Minianka (Mamara)',
        'Bamanankan (Bambara)',
        'Sénoufo (Syenara)',
      ],
    ),

    // 13. SAN (Région administrative - Cité historique du Sanké)
    RegionModel(
      id: 'san',
      nom: 'Région de San',
      chefLieu: 'San',
      latitude: 13.3034,
      longitude: -4.8956,
      description:
          'Carrefour historique et culturel au bord de la rivière Bani. Célèbre pour sa majestueuse église sanctuaire en banco néo-soudanaise et le Sanké Mô, rite de pêche collective séculaire inscrit au patrimoine immatériel de l’UNESCO.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/4aac1e77-f062-4bf8-8d8f-9b8ec39e1df0_san_sanke-mon.jpg',
      population: '330 000 hab.',
      superficie: '7 262 km²',
      isPrioritaire: false,
      attraits: [
        'Rite de pêche collective Sanké Mô (UNESCO)',
        'Grande église en banco de style soudanais',
        'Carrefour fluvial du Bani',
        'Traditions culturelles Bobo et Marka',
      ],
      languesLocales: [
        'Bamanankan (Bambara)',
        'Bobo (Bomu)',
        'Minianka (Mamara)',
      ],
    ),

    // 14. KÉNIÉBA (Cercle historique du Bambouk - Vallée de la Falémé)
    RegionModel(
      id: 'kenieba',
      nom: 'Cercle de Kéniéba',
      chefLieu: 'Kéniéba',
      latitude: 12.8530,
      longitude: -11.2260,
      description:
          'Cœur historique du Bambouk et capitale aurifère du Mali, nichée dans un écrin de collines verdoyantes de la falaise du Tambaoura. Terre de traditions mandingues et de cascades préservées.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/20c147b6-b759-4b58-b974-3c4611f2b1cb_kenieba.jpeg',
      population: '215 000 hab.',
      superficie: '16 800 km²',
      isPrioritaire: false,
      attraits: [
        'Falaises majestueuses du Tambaoura',
        'Sites historiques d’orpaillage du Bambouk',
        'Vallée de la Falémé',
        'Danses et musiques mandingues traditionnelles',
      ],
      languesLocales: [
        'Maninkakan (Malinké)',
        'Khassonké (Xasonga)',
        'Fulfulde (Peul)',
      ],
    ),

    // 15. KITA (Région administrative - Cité de l'arachide et des griots)
    RegionModel(
      id: 'kita',
      nom: 'Région de Kita',
      chefLieu: 'Kita',
      latitude: 13.0349,
      longitude: -9.4895,
      description:
          'Capitale légendaire de l’arachide et berceau vénéré des griots et de la musique mandingue. Dominée par le mont Kita (Kita Kourou), la cité est célèbre pour son grand pèlerinage marial et ses contes épiques.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/8a2b87e9-7ef4-4298-8698-ac341176f1ce_kita.jpeg',
      population: '438 000 hab.',
      superficie: '35 250 km²',
      isPrioritaire: false,
      attraits: [
        'Mont sacré de Kita (Kita Kourou)',
        'Berceau des grands griots du Mandé',
        'Pèlerinage national de Notre-Dame de Kita',
        'Artisanat du kora et balafon mandingue',
      ],
      languesLocales: [
        'Maninkakan (Malinké)',
        'Bamanankan (Bambara)',
        'Fulfulde (Peul)',
      ],
    ),

    // 16. BANDIAGARA (Région administrative - Cœur du Pays Dogon)
    RegionModel(
      id: 'bandiagara',
      nom: 'Région de Bandiagara',
      chefLieu: 'Bandiagara',
      latitude: 14.3501,
      longitude: -3.6104,
      description:
          'Capitale spirituelle et culturelle du Pays Dogon, perchée sur le plateau gréseux. Ville de mémoire de l’écrivain sage Amadou Hampâté Bâ et d’El Hadj Oumar Tall, porte d’entrée vers les spectaculaires falaises classées par l’UNESCO.',
      imageCover: 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/092d8b10-62e7-4254-9e2e-3b97571beb46_badiangara.jpeg',
      population: '320 000 hab.',
      superficie: '10 520 km²',
      isPrioritaire: false,
      attraits: [
        'Falaises de Bandiagara et villages Dogon (UNESCO)',
        'Maison mémoire d’Amadou Hampâté Bâ',
        'Artisanat des masques et tissages Dogon',
        'Architecture traditionnelle de pierre et banco',
      ],
      languesLocales: [
        'Dogon (Toro So / Tomo Kan)',
        'Fulfulde (Peul)',
        'Bamanankan (Bambara)',
      ],
    ),
  ];

  static RegionModel? findById(String id) {
    try {
      return regions.firstWhere((r) => r.id.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  static RegionModel? findByNameOrChefLieu(String nom, [String? chefLieu]) {
    final key = '${nom.toLowerCase()} ${(chefLieu ?? '').toLowerCase()}';
    for (final r in regions) {
      if (key.contains(r.id.toLowerCase()) ||
          key.contains(r.chefLieu.toLowerCase()) ||
          r.nom.toLowerCase() == nom.toLowerCase()) {
        return r;
      }
    }
    return null;
  }

  static List<RegionModel> get priorityRegions =>
      regions.where((r) => r.isPrioritaire).toList();
}
