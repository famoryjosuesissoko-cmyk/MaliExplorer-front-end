class EthnieModel {
  final int id;
  final String nom;
  final String region;
  final String population;
  final String description;
  final String imageUrl;
  final String photoHomme;
  final String photoFemme;
  final String titreHomme;
  final String articleHomme;
  final String titreFemme;
  final String articleFemme;
  final List<String> coutumes;
  final String langue;

  const EthnieModel({
    required this.id,
    required this.nom,
    required this.region,
    required this.population,
    required this.description,
    required this.imageUrl,
    required this.photoHomme,
    required this.photoFemme,
    required this.titreHomme,
    required this.articleHomme,
    required this.titreFemme,
    required this.articleFemme,
    this.coutumes = const [],
    this.langue = 'Langue traditionnelle',
  });

  static String getLocalPhotoHomme(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dogon')) return 'assets/images/ethnies/dogon_homme.jpeg';
    if (lower.contains('peul') || lower.contains('fula')) return 'assets/images/ethnies/peul_homme.jpeg';
    if (lower.contains('sonink')) return 'assets/images/ethnies/soninke_homme.jpeg';
    if (lower.contains('touareg') || lower.contains('tuareg')) return 'assets/images/ethnies/touareg_homme.jpeg';
    if (lower.contains('malink')) return 'assets/images/ethnies/malinke_homme.jpeg';
    if (lower.contains('bambara')) return 'assets/images/ethnies/bambara_homme.jpeg';
    return 'assets/images/ethnies/dogon_homme.jpeg';
  }

  static String getLocalPhotoFemme(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dogon')) return 'assets/images/ethnies/dogon_femme.jpeg';
    if (lower.contains('peul') || lower.contains('fula')) return 'assets/images/ethnies/peul_femme.jpeg';
    if (lower.contains('sonink')) return 'assets/images/ethnies/soninke_femme.jpeg';
    if (lower.contains('touareg') || lower.contains('tuareg')) return 'assets/images/ethnies/touareg_femme.jpeg';
    if (lower.contains('malink')) return 'assets/images/ethnies/malinke_femme.jpeg';
    if (lower.contains('bambara')) return 'assets/images/ethnies/Bambara2.jpeg';
    return 'assets/images/ethnies/dogon_femme.jpeg';
  }

  String get displayPhoto => photoHomme.isNotEmpty ? photoHomme : imageUrl;

  factory EthnieModel.fromJson(Map<String, dynamic> json) {
    final nomEthnie = json['nom'] ?? json['nomEthnie'] ?? '';
    final defaultMatch = defaultEthnies.firstWhere(
      (e) => e.nom.toLowerCase().contains(nomEthnie.toLowerCase()) ||
          nomEthnie.toLowerCase().contains(e.nom.toLowerCase()),
      orElse: () => defaultEthnies.first,
    );

    return EthnieModel(
      id: json['id'] ?? json['idEthnie'] ?? defaultMatch.id,
      nom: nomEthnie.isNotEmpty ? nomEthnie : defaultMatch.nom,
      region: json['region'] ?? defaultMatch.region,
      population: json['population'] ?? defaultMatch.population,
      description: json['description'] ?? defaultMatch.description,
      imageUrl: getLocalPhotoHomme(nomEthnie),
      photoHomme: (json['photoHomme'] != null &&
              json['photoHomme'].toString().trim().isNotEmpty)
          ? json['photoHomme'].toString()
          : getLocalPhotoHomme(nomEthnie),
      photoFemme: (json['photoFemme'] != null &&
              json['photoFemme'].toString().trim().isNotEmpty)
          ? json['photoFemme'].toString()
          : getLocalPhotoFemme(nomEthnie),
      titreHomme: json['titreHomme'] ?? defaultMatch.titreHomme,
      articleHomme: json['articleHomme'] ?? defaultMatch.articleHomme,
      titreFemme: json['titreFemme'] ?? defaultMatch.titreFemme,
      articleFemme: json['articleFemme'] ?? defaultMatch.articleFemme,
      coutumes: (json['coutumes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          defaultMatch.coutumes,
      langue: json['langue'] ?? defaultMatch.langue,
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
      'photoHomme': photoHomme,
      'photoFemme': photoFemme,
      'titreHomme': titreHomme,
      'articleHomme': articleHomme,
      'titreFemme': titreFemme,
      'articleFemme': articleFemme,
      'coutumes': coutumes,
      'langue': langue,
    };
  }

  static const List<EthnieModel> defaultEthnies = [
    EthnieModel(
      id: 1,
      nom: 'Dogon',
      region: 'Mopti, Falaises de Bandiagara',
      population: '~2 millions (9% de la population)',
      langue: 'Dogonso (multiples dialectes)',
      description:
          'Peuple mythique et fascinant établi le long des imposantes falaises de Bandiagara (classées à l\'UNESCO). Célèbres pour leur cosmogonie complexe liée à l\'étoile Sirius, leurs danses masquées du Dama et leur architecture unique en terre accrochée au roc.',
      imageUrl: 'assets/images/ethnies/dogon_homme.jpeg',
      photoHomme: 'assets/images/ethnies/dogon_homme.jpeg',
      photoFemme: 'assets/images/ethnies/dogon_femme.jpeg',
      titreHomme: 'L\'Homme Dogon : Chasseur, cultivateur et gardien des masques',
      articleHomme:
          'L\'homme Dogon incarne la persévérance et le respect des lois sacrées de la nature. Habillé de la tunique de coton écru filé main et coiffé du bonnet traditionnel triangulaire brodé, il porte en bandoulière la besace en cuir ornée de talismans protecteurs. Il est l\'artisan bâtisseur des greniers à mil aux toits de chaume pointus et l\'acteur central de la société secrète des masques Awa. Lors des funérailles rituelles du Dama, perché sur des échasses ou coiffé de l\'immense masque Sirigé mesurant jusqu\'à 5 mètres, il guide l\'âme des défunts vers le monde des ancêtres par des danses acrobatiques saisissantes.',
      titreFemme: 'La Femme Dogon : Parures cosmiques, tresses sacrées et poterie',
      articleFemme:
          'La femme Dogon est la gardienne de la fertilité, de la tradition orale et de la paix du village. Sa coiffure traditionnelle est une œuvre d\'art géométrique : de fines tresses sculptées en crêtes ornées de perles d\'ambre, de cauris et de cuivre, figurant les constellations célestes et la germination des graines primordiales. Elle se pare de pagnes indigo tissés en bandes étroites et de lourds anneaux de chevilles et d\'oreilles. Dépositaire de l\'art ancestral de la poterie cuite à ciel ouvert, elle brasse également la célèbre bière de mil konyo indispensable à toutes les grandes fêtes communautaires.',
      coutumes: [
        'Rituel des masques Awa & Fêtes du Dama',
        'Fête du Sigui célébrée tous les 60 ans',
        'Architecture des greniers mâle et femelle',
        'Cosmogonie astronomique de Nommo et Po Tolo',
      ],
    ),
    EthnieModel(
      id: 2,
      nom: 'Peul (Fulbé)',
      region: 'Mopti, Ségou, Sikasso, Sahel',
      population: '~3 millions (14% de la population)',
      langue: 'Fulfude (Pulaar)',
      description:
          'Éleveurs et poètes du Sahel, réputés pour leur grâce naturelle, leur attachement sacré au bétail et le code moral rigoureux du Pulaaku, prônant la dignité, la pudeur et le courage.',
      imageUrl: 'assets/images/ethnies/peul_homme.jpeg',
      photoHomme: 'assets/images/ethnies/peul_homme.jpeg',
      photoFemme: 'assets/images/ethnies/peul_femme.jpeg',
      titreHomme: 'L\'Homme Peul : L\'élégance pastorale et le grand chapeau conique',
      articleHomme:
          'L\'homme Peul arpente les vastes savanes avec une prestance aristocratique. Son symbole le plus emblématique est le Tengade, un splendide chapeau conique en paille tressée doublé de cuir ouvragé aux motifs géométriques, porté avec fierté. Il arbore un ample boubou pastel et porte sur ses épaules le bâton pastoral poli, instrument de guidage de son troupeau et insigne de son statut. Respectant le Pulaaku, il s\'exprime avec retenue et poésie, vouant à ses zébus une affection transmise de père en fils.',
      titreFemme: 'La Femme Peul : Les anneaux d\'or torsadé et le tatouage indigo',
      articleFemme:
          'La femme Peul rayonne par l\'éclat spectaculaire de ses bijoux et la délicatesse de ses traits. Elle porte avec une majesté incomparable les Kwottenai Kange, de gigantesques boucles d\'oreilles en or jaune pur torsadé et martelé à la main, symboles de statut et de fortune familiale. Sa chevelure est montée en une haute crête centrale sophistiquée parsemée de perles de corail et de pièces d\'argent anciennes. Ses lèvres et ses gencives sont subtilement teintées de noir indigo (le Tchoodi), faisant ressortir l\'éclat de son sourire lors des transhumances et de la fête du Yaaral.',
      coutumes: [
        'Code moral et philosophique du Pulaaku',
        'Traversée des troupeaux de Diafarabé (Yaaral & Degal)',
        'Poésie pastorale et chants polyphoniques',
        'Orfèvrerie d\'or torsadé et ambre sahélien',
      ],
    ),
    EthnieModel(
      id: 3,
      nom: 'Soninké (Sarakholé)',
      region: 'Kayes, Koulikoro, Vallée du Sénégal',
      population: '~1,7 million (8% de la population)',
      langue: 'Soninké',
      description:
          'Bâtisseurs de l\'empire légendaire du Wagadou (Ghana antique), réputés pour leur sens inné du grand commerce transcontinental, leur loyauté et leur organisation sociale hautement structurée.',
      imageUrl: 'assets/images/ethnies/soninke_homme.jpeg',
      photoHomme: 'assets/images/ethnies/soninke_homme.jpeg',
      photoFemme: 'assets/images/ethnies/soninke_femme.jpeg',
      titreHomme: 'L\'Homme Soninké : Noblesse du Wagadou et tenue d\'apparat',
      articleHomme:
          'Héritier de la première grande civilisation impériale d\'Afrique de l\'Ouest, l\'homme Soninké cultive une dignité sans faille. Il revêt pour les grands rassemblements d\'immenses boubous en bazin richement teinté d\'indigo ou damassé, rehaussé de broderies dorées au col et aux manches. Coiffé d\'un bonnet brodé à quatre cornes ou d\'une chéchia, il est respecté pour sa parole donnée et sa maîtrise des réseaux d\'échanges caravaniers et modernes reliant les diasporas du monde entier à la terre natale.',
      titreFemme: 'La Femme Soninké : Teinture à l\'indigo Gara et parures royales',
      articleFemme:
          'La femme Soninké est une reine de l\'art textile et de l\'élégance sahélienne. Elle maîtrise l\'art millénaire de la teinture artisanale à l\'indigo naturel (le Gara), confectionnant des étoffes aux reflets bleus métalliques profonds ornées de motifs noués. Lors des mariages et fêtes coutumières, elle se pare de colliers imposants en perles d\'or pur (Sanu) et d\'ambre volumineux. Ses mains et ses pieds sont magnifiés par de minutieuses dentelles végétales tracées au henné naturel, symboles de joie, d\'amour et de fécondité.',
      coutumes: [
        'Mémoire de l\'empire du Wagadou et du serpent Bida',
        'Artisanat textile de la teinture indigo Gara',
        'Solidarité communautaire et entraide familiale',
        'Cérémonies fastueuses de mariage traditionnel',
      ],
    ),
    EthnieModel(
      id: 4,
      nom: 'Touareg (Kel Tamasheq)',
      region: 'Tombouctou, Gao, Kidal, Sahara',
      population: '~500 000 (2% de la population)',
      langue: 'Tamasheq (écriture Tifinagh)',
      description:
          'Les seigneurs nobles du désert saharien, maîtres incontestés de la navigation stellaire dans les dunes, de l\'orfèvrerie d\'argent filigrané et de la musique takamba.',
      imageUrl: 'assets/images/ethnies/touareg_homme.jpeg',
      photoHomme: 'assets/images/ethnies/touareg_homme.jpeg',
      photoFemme: 'assets/images/ethnies/touareg_femme.jpeg',
      titreHomme: 'L\'Homme Touareg : Le guerrier bleu au Tagelmust et sabre Takoba',
      articleHomme:
          'L\'homme Touareg, surnommé "l\'Homme Bleu", fait corps avec l\'immensité du Sahara. Sa silhouette altère est dominée par le Tagelmust, un ruban de tissu de coton teint à l\'indigo mesurant jusqu\'à 15 mètres, qu\'il enroule autour de sa tête pour ne laisser percer que son regard acéré. Ce voile le protège du vent de sable et des esprits du désert. À son côté pend fièrement la Takoba, longue épée droite à poignée de fer et fourreau de cuir gravé, insigne séculaire des cavaliers nomades et de la bravoure chamelière.',
      titreFemme: 'La Femme Touareg : La souveraine du campement et les bijoux d\'argent',
      articleFemme:
          'Au sein de la société Kel Tamasheq aux fortes traditions matrilinéaires, la femme jouit d\'une liberté et d\'une autorité remarquables. Non voilée, elle arbore de grands voiles sombres ou chatoyants drapés avec aisance. Elle ne porte jamais d\'or mais exclusivement des bijoux d\'argent massif ciselé : la Croix d\'Agadez (protectrice du voyageur), de lourds bracelets gravés d\'idéogrammes et des bagues amulettes (Tcherot). Elle pratique le jeu du monocorde Imzad et transmet l\'écriture millénaire Tifinagh aux nouvelles générations.',
      coutumes: [
        'Cérémonie du thé à la menthe aux trois verres rituels',
        'Poésie d\'amour et musique d\'Imzad',
        'Écriture libyco-berbère Tifinagh',
        'Caravanes de l\'Azalaï reliant Tombouctou aux mines de sel',
      ],
    ),
    EthnieModel(
      id: 5,
      nom: 'Malinké (Mandinka)',
      region: 'Koulikoro, Kayes, Région de Mandé',
      population: '~1,3 million (6% de la population)',
      langue: 'Maninkakan',
      description:
          'Gardiens de la mémoire de Soundiata Keïta et de la charte de Kouroukan Fouga (1236), berceau de la fraternité mandingue, de l\'art des griots et de la confrérie des chasseurs.',
      imageUrl: 'assets/images/ethnies/malinke_homme.jpeg',
      photoHomme: 'assets/images/ethnies/malinke_homme.jpeg',
      photoFemme: 'assets/images/ethnies/malinke_femme.jpeg',
      titreHomme: 'L\'Homme Malinké : La vaillance du chasseur et l\'héritage impérial',
      articleHomme:
          'L\'homme Malinké puise sa force dans l\'épopée fondatrice de l\'Empire du Mali. Il s\'honore de la confrérie des Donso (chasseurs traditionnels), vêtus de tuniques teintes aux écorces sacrées et couvertes d\'amulettes, de miroirs protecteurs et de queues d\'animaux sauvages. Pour les cérémonies de cour, il revêt de somptueux boubous amples mandingues symbolisant la puissance et l\'équilibre. Il est l\'allié indéfectible des griots qui chantent la mémoire des ancêtres au son mélodieux de la Kora et du Balafon.',
      titreFemme: 'La Femme Malinké : L\'élégance mandingue et le diadème de tête',
      articleFemme:
          'La femme Malinké incarne la chaleur et la prestance des reines du Mandé. Elle s\'illustre par le port de boubous royaux en bazin richement plissé et gaufré aux couleurs vibrantes, assortis d\'un mouchoir de tête artistiquement noué en couronne étagée. Ses oreilles s\'illuminent de boucles ciselées et son cou se pare de colliers en perles fines de verre vénitien et d\'or d\'Afrique. Elle joue un rôle fondamental d\'apaisement dans la communauté et de transmission des valeurs de respect et de concorde.',
      coutumes: [
        'Mémoire de la Charte de Kouroukan Fouga (Droits humains 1236)',
        'Confrérie initiatique et écologique des chasseurs Donso',
        'Art oratoire et musique de la Kora à 21 cordes',
        'Parente à plaisanterie (Sinankunya) garantissant la paix',
      ],
    ),
    EthnieModel(
      id: 6,
      nom: 'Bambara (Bamana)',
      region: 'Ségou, Koulikoro, Bamako, Sikasso',
      population: '~7,5 millions (34% de la population)',
      langue: 'Bamanankan (Langue nationale)',
      description:
          'Groupe ethnique majoritaire du Mali, au cœur de la langue nationale bamanankan et de la formidable histoire du royaume de Ségou. Maîtres de la forge, de la terre et du célèbre textile Bogolan.',
      imageUrl: 'assets/images/ethnies/bambara_homme.jpeg',
      photoHomme: 'assets/images/ethnies/bambara_homme.jpeg',
      photoFemme: 'assets/images/ethnies/Bambara2.jpeg',
      titreHomme: 'L\'Homme Bambara : Le maître de la terre et la tunique en Bogolan',
      articleHomme:
          'L\'homme Bambara (ou Bamana, "celui qui refuse d\'être asservi") est intimement lié à la terre nourricière. Sa tenue la plus célèbre est la tunique en véritable Bogolanfini, confectionnée en bandes de cotonnade brute filée main et teinte avec de la boue fermentée du fleuve Niger et des décoctions de feuilles sauvages. Les motifs géométriques noirs et ocres du tissu racontent des récits historiques codés et protègent celui qui le porte. L\'homme Bambara vénère le masque Ciwarâ (l\'antilope mythique), qui récompense le courage du meilleur cultivateur lors des grands concours de labour.',
      titreFemme: 'La Femme Bambara : Potière inspirée et gardienne des traditions',
      articleFemme:
          'La femme Bambara est le pilier indispensable de la famille et de l\'économie villageoise. Elle porte avec fierté des pagnes noués en bogolan traditionnel ou des ensembles éclatants aux motifs wax sahéliens. Ses cheveux sont minutieusement tressés en couronnes régulières selon les étapes de la vie. Experte dans la poterie en terre cuite et la cuisine familiale aux délicieux arômes de soumbala et de pâte d\'arachide, elle transmet chaque soir la morale et la sagesse populaire à travers les contes sous l\'arbre à palabres.',
      coutumes: [
        'Tissu sacré en Bogolan teinté à la boue du Niger',
        'Danses du masque Ciwarâ honorant l\'agriculture',
        'Initiations traditionnelles du Kôrê et du Komo',
        'Fraternité légendaire du royaume de Ségou',
      ],
    ),
  ];
}
