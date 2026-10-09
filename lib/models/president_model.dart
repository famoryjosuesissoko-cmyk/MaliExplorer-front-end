class PresidentModel {
  final int id;
  final String prenom;
  final String nom;
  final String? dateNaissance;
  final String? dateDeces;
  final String periodeMandat;
  final String biographie;
  final String photoUrl;
  final String? titre;
  final String? lieuNaissance;
  final String? citation;
  final List<String>? faitsMarquants;

  const PresidentModel({
    required this.id,
    required this.prenom,
    required this.nom,
    this.dateNaissance,
    this.dateDeces,
    required this.periodeMandat,
    required this.biographie,
    required this.photoUrl,
    this.titre,
    this.lieuNaissance,
    this.citation,
    this.faitsMarquants,
  });

  String get fullName => '$prenom $nom'.trim();

  /// Résout l'image locale correspondante dans assets/images/presidents/
  static String getLocalPhoto(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('modibo')) {
      return 'assets/images/presidents/modibo_keita.jpeg';
    } else if (lower.contains('moussa')) {
      return 'assets/images/presidents/moussa_traore.jpeg';
    } else if (lower.contains('alpha') || lower.contains('konaré') || lower.contains('konare')) {
      return 'assets/images/presidents/alpha_oumar_konare.png';
    } else if (lower.contains('toumani') || lower.contains('att')) {
      return 'assets/images/presidents/amadou_toumani_toure.jpeg';
    } else if (lower.contains('haya') || lower.contains('sanogo')) {
      return 'assets/images/presidents/amadou_haya_sanogo.jpeg';
    } else if (lower.contains('dioncounda')) {
      return 'assets/images/presidents/dioncounda_traore.png';
    } else if (lower.contains('ibrahim') || lower.contains('ibk') || lower.contains('boubacar')) {
      return 'assets/images/presidents/ibrahim_boubacar_keita.jpeg';
    } else if (lower.contains('daw') || lower.contains('daou') || lower.contains('bah')) {
      return 'assets/images/presidents/bah_ndaw.jpeg';
    } else if (lower.contains('assimi') || lower.contains('goïta') || lower.contains('goita')) {
      return 'assets/images/presidents/assimi_goita.jpeg';
    }
    return 'assets/images/presidents/modibo_keita.jpeg';
  }

  /// Image prioritaire à afficher (asset local ou image distante si valide)
  String get displayPhoto {
    if (photoUrl.startsWith('assets/')) {
      return photoUrl;
    }
    final local = getLocalPhoto(fullName);
    if (photoUrl.isEmpty) {
      return local;
    }
    // On privilégie l'asset local de haute qualité s'il existe
    return local;
  }

  factory PresidentModel.fromJson(Map<String, dynamic> json) {
    final fullName = '${json['prenom'] ?? ''} ${json['nom'] ?? ''}'.trim();
    final localPhoto = getLocalPhoto(fullName);

    return PresidentModel(
      id: json['id'] ?? json['idPresident'] ?? 0,
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      dateNaissance: json['dateNaissance']?.toString(),
      dateDeces: json['dateDeces']?.toString(),
      periodeMandat: json['periodeMandat'] ?? '',
      biographie: json['biographie'] ?? '',
      photoUrl: json['photoUrl']?.toString().isNotEmpty == true
          ? json['photoUrl'].toString()
          : localPhoto,
      titre: json['titre']?.toString(),
      lieuNaissance: json['lieuNaissance']?.toString(),
      citation: json['citation']?.toString(),
      faitsMarquants: json['faitsMarquants'] is List
          ? List<String>.from(json['faitsMarquants'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'dateNaissance': dateNaissance,
      'dateDeces': dateDeces,
      'periodeMandat': periodeMandat,
      'biographie': biographie,
      'photoUrl': photoUrl,
      'titre': titre,
      'lieuNaissance': lieuNaissance,
      'citation': citation,
      'faitsMarquants': faitsMarquants,
    };
  }

  /// Liste chronologique complète et documentée des 9 chefs d'État de la République du Mali
  static List<PresidentModel> get chronologicalPresidents => const [
    PresidentModel(
      id: 1,
      prenom: 'Modibo',
      nom: 'Keïta',
      periodeMandat: '1960 - 1968',
      dateNaissance: '4 juin 1915',
      dateDeces: '16 mai 1977',
      lieuNaissance: 'Bamako (Soudan français)',
      titre: 'Père de l\'Indépendance & 1er Président de la République',
      biographie:
          'Figure emblématique de la lutte anticoloniale et du panafricanisme, Modibo Keïta a proclamé l\'indépendance de la République du Mali le 22 septembre 1960. Instituteur de formation, syndicaliste et orateur brillant, il a mené une politique de socialisme scientifique et de non-alignement résolu. Il a été l\'un des cofondateurs historiques de l\'Organisation de l\'Unité Africaine (OUA) à Addis-Abeba en 1963.',
      photoUrl: 'assets/images/presidents/modibo_keita.jpeg',
      citation:
          '« Quand nous disons que le Mali est engagé dans la voie du socialisme, cela veut dire que nous entendons bâtir une société de justice, de fraternité et de dignité retrouvée. »',
      faitsMarquants: [
        'Proclamation historique de l\'indépendance nationale le 22 septembre 1960.',
        'Création du Franc Malien le 1er juillet 1962 pour asseoir la souveraineté monétaire.',
        'Cofondation de l\'Organisation de l\'Unité Africaine (OUA) en 1963.',
        'Grande réforme de l\'enseignement public et création des sociétés et entreprises d\'État.',
      ],
    ),
    PresidentModel(
      id: 2,
      prenom: 'Moussa',
      nom: 'Traoré',
      periodeMandat: '1968 - 1991',
      dateNaissance: '25 septembre 1936',
      dateDeces: '15 septembre 2020',
      lieuNaissance: 'Sébétou (Cercle de Kita)',
      titre: 'Général d\'armée, Chef du CMLN & Président de la IIe République',
      biographie:
          'Officier saint-cyrien et instructeur militaire à l\'École militaire interarmes de Kati, le lieutenant Moussa Traoré prend la tête du Comité Militaire de Libération Nationale (CMLN) le 19 novembre 1968. Il dirige le Mali pendant plus de deux décennies, instaure la Constitution de la Deuxième République en 1974 et fonde le parti unique UDPM en 1979. Son régime affronte les rudes sécheresses sahéliennes et les ajustements structurels économiques des années 1980.',
      photoUrl: 'assets/images/presidents/moussa_traore.jpeg',
      citation:
          '« Le dialogue est l\'arme des forts et la concorde nationale est le fondement indestructible de notre stabilité. »',
      faitsMarquants: [
        'Prise de pouvoir le 19 novembre 1968 à la tête du CMLN.',
        'Adoption de la Constitution de 1974 et création de l\'UDPM en 1979.',
        'Réintégration du Mali au sein de l\'Union Monétaire Ouest-Africaine (UMOA) et du Franc CFA en 1984.',
        'Médiation active dans plusieurs crises diplomatiques et frontalières régionales.',
      ],
    ),
    PresidentModel(
      id: 3,
      prenom: 'Alpha Oumar',
      nom: 'Konaré',
      periodeMandat: '1992 - 2002',
      dateNaissance: '2 février 1946',
      dateDeces: null,
      lieuNaissance: 'Kayes',
      titre: 'Historien, 1er Président démocratiquement élu de la IIIe République',
      biographie:
          'Historien, archéologue et intellectuel réputé, Alpha Oumar Konaré est le premier président de la République du Mali élu au suffrage universel pluraliste en 1992, puis réélu en 1997. Artisan de l\'enracinement institutionnel de la démocratie, il impulse la grande réforme de la décentralisation avec la création de 703 communes territoriales. Après son mandat présidentiel de dix ans, il a présidé la Commission de l\'Union africaine de 2003 à 2008.',
      photoUrl: 'assets/images/presidents/alpha_oumar_konare.png',
      citation:
          '« L\'Afrique n\'a pas besoin d\'hommes providentiels, elle a besoin d\'institutions solides et de peuples libres et conscients. »',
      faitsMarquants: [
        'Consécration du multipartisme et alternance démocratique pacifique en 1992.',
        'Réforme majeure de décentralisation territoriale (création des 703 communes maliennes).',
        'Flamme de la Paix de Tombouctou (1996) scellant la réconciliation nationale.',
        'Organisation réussie de la Coupe d\'Afrique des Nations de football (CAN 2002) au Mali.',
      ],
    ),
    PresidentModel(
      id: 4,
      prenom: 'Amadou Toumani',
      nom: 'Touré',
      periodeMandat: '2002 - 2012',
      dateNaissance: '4 novembre 1948',
      dateDeces: '10 novembre 2020',
      lieuNaissance: 'Mopti',
      titre: '« Le Soldat de la Démocratie », Général d\'armée & Président de la République',
      biographie:
          'Affectueusement appelé ATT, parachutiste d\'élite, il s\'illustre en mars 1991 en conduisant la transition démocratique (CTSP) et en cédant volontairement le pouvoir aux civils en 1992 après l\'adoption d\'une constitution pluraliste. Élu président de la République en 2002 sous la bannière du consensus politique, puis réélu en 2007, il lance de vastes chantiers de modernisation (routes, échangeurs, ponts, barrages, logements sociaux).',
      photoUrl: 'assets/images/presidents/amadou_toumani_toure.jpeg',
      citation:
          '« Le consensus n\'est pas la pensée unique, c\'est le rassemblement de toutes les énergies patriotiques au chevet du Mali. »',
      faitsMarquants: [
        'Direction exemplaire du Comité de Transition pour le Salut du Peuple (CTSP) en 1991-1992.',
        'Mise en œuvre du Programme de Développement Économique et Social (PDES).',
        'Construction des grands logements sociaux à travers tout le Mali (cités ATTbougou).',
        'Édification du 3ème pont de Bamako et de l\'échangeur multiple de la paix.',
      ],
    ),
    PresidentModel(
      id: 5,
      prenom: 'Amadou Haya',
      nom: 'Sanogo',
      periodeMandat: '2012 (Transition CNRDRE)',
      dateNaissance: '1972',
      dateDeces: null,
      lieuNaissance: 'Ségou',
      titre: 'Général de corps d\'armée, Président du CNRDRE',
      biographie:
          'Capitaine de l\'armée de terre et instructeur militaire à Kati, Amadou Haya Sanogo prend la tête du Comité National pour le Redressement de la Démocratie et la Restauration de l\'État (CNRDRE) le 22 mars 2012. Face à la grave crise sécuritaire au Nord, il dirige les instances de l\'État avant de signer l\'accord-cadre de sortie de crise sous l\'égide de la CEDEAO le 6 avril 2012, confiant l\'intérim constitutionnel au président de l\'Assemblée nationale.',
      photoUrl: 'assets/images/presidents/amadou_haya_sanogo.jpeg',
      citation:
          '« Notre action a été guidée par l\'impérieuse nécessité de préserver l\'intégrité territoriale et la dignité de nos soldats au front. »',
      faitsMarquants: [
        'Création et présidence du CNRDRE en mars 2012.',
        'Signature de l\'Accord-cadre du 6 avril 2012 rétablissant l\'ordre constitutionnel.',
        'Création du Comité militaire de suivi de la réforme des forces de défense et de sécurité.',
      ],
    ),
    PresidentModel(
      id: 6,
      prenom: 'Dioncounda',
      nom: 'Traoré',
      periodeMandat: '2012 - 2013',
      dateNaissance: '23 février 1942',
      dateDeces: null,
      lieuNaissance: 'Kati',
      titre: 'Professeur de mathématiques, Président de la République par intérim',
      biographie:
          'Universitaire chevronné, docteur en mathématiques et président de l\'Assemblée nationale, Dioncounda Traoré est investi président de la République par intérim le 12 avril 2012 conformément à la Constitution de 1992. Dans un contexte de guerre et d\'occupation des régions du Nord, il a fait preuve d\'un grand courage d\'État, appelant au secours la communauté internationale et organisant l\'élection présidentielle historique et apaisée de 2013.',
      photoUrl: 'assets/images/presidents/dioncounda_traore.png',
      citation:
          '« Il n\'y a pas de sacrifice trop lourd quand il s\'agit de sauver le Mali, notre bien le plus cher et notre héritage commun. »',
      faitsMarquants: [
        'Investiture à la présidence par intérim en pleine crise institutionnelle en avril 2012.',
        'Lancement de la reconquête des régions septentrionales du Mali (Opération Serval / FAMA).',
        'Formation d\'un gouvernement d\'union nationale de transition.',
        'Organisation exemplaire et pacifique de l\'élection présidentielle de l\'été 2013.',
      ],
    ),
    PresidentModel(
      id: 7,
      prenom: 'Ibrahim Boubacar',
      nom: 'Keïta',
      periodeMandat: '2013 - 2020',
      dateNaissance: '29 janvier 1945',
      dateDeces: '16 janvier 2022',
      lieuNaissance: 'Koutiala',
      titre: '« IBK », Homme d\'État, Diplomate & Président de la République',
      biographie:
          'Personnalité politique de premier plan (ancien Premier ministre de 1994 à 2000 et président de l\'Assemblée nationale de 2002 à 2007), Ibrahim Boubacar Keïta, couramment désigné par ses initiales IBK, est élu président de la République en 2013 avec plus de 77 % des voix, puis réélu en 2018. Fondateur du RPM, il a consacré ses mandats à la signature de l\'Accord de paix d\'Alger (2015) et à la montée en puissance de l\'armée via la Loi d\'orientation militaire.',
      photoUrl: 'assets/images/presidents/ibrahim_boubacar_keita.jpeg',
      citation:
          '« Pour le Mali, aucun sacrifice n\'est de trop. Le Mali d\'abord, le Mali toujours. »',
      faitsMarquants: [
        'Élection plébiscitée en août 2013 avec un record de participation populaire.',
        'Adoption de la Loi d\'Orientation et de Programmation Militaire (LOPM) 2015-2019.',
        'Signature de l\'Accord pour la Paix et la Réconciliation issu du processus d\'Alger en 2015.',
        'Organisation du 27ème Sommet Afrique-France à Bamako en janvier 2017.',
      ],
    ),
    PresidentModel(
      id: 8,
      prenom: 'Bah',
      nom: 'N\'Daw',
      periodeMandat: '2020 - 2021',
      dateNaissance: '23 août 1950',
      dateDeces: null,
      lieuNaissance: 'San',
      titre: 'Colonel-major de l\'armée de l\'air, Président de la Transition',
      biographie:
          'Officier supérieur respecté de l\'armée de l\'air formé en Union Soviétique et en France, ancien ministre de la Défense et des Anciens Combattants en 2014, Bah N\'Daw est désigné président de la Transition par le collège désigné par le CNSP. Il prête serment le 25 septembre 2020 pour diriger la feuille de route de la Transition civile et militaire et engager les chantiers de la refondation républicaine.',
      photoUrl: 'assets/images/presidents/bah_ndaw.jpeg',
      citation:
          '« Le Mali ne sera fort que par la discipline républicaine, l\'intégrité morale et le respect scrupuleux de l\'intérêt général. »',
      faitsMarquants: [
        'Prestation de serment comme Chef de l\'État de la Transition le 25 septembre 2020.',
        'Mise en place des organes de la Transition (Conseil National de la Transition - CNT).',
        'Consolidation des partenariats régionaux et bilatéraux de défense.',
      ],
    ),
    PresidentModel(
      id: 9,
      prenom: 'Assimi',
      nom: 'Goïta',
      periodeMandat: '2021 - Présent',
      dateNaissance: '1983',
      dateDeces: null,
      lieuNaissance: 'Bamako',
      titre: 'Général d\'armée, Président de la Transition, Chef de l\'État',
      biographie:
          'Officier des forces spéciales diplômé du Prytanée militaire de Kati et de l\'EMIA de Koulikoro, le Général d\'armée Assimi Goïta prend la tête du Comité National pour le Salut du Peuple (CNSP) en août 2020. Investi Président de la Transition le 7 juin 2021, il impulse une politique de souveraineté nationale totale, dote les FAMA d\'équipements stratégiques modernes et reprend le contrôle de Kidal en novembre 2023. Il est le cofondateur de la Confédération des États du Sahel (AES) et promulgue la nouvelle Constitution de la IVe République en juillet 2023.',
      photoUrl: 'assets/images/presidents/assimi_goita.jpeg',
      citation:
          '« Le destin du Mali nous appartient désormais. La souveraineté de notre peuple, sa sécurité et sa dignité ne se négocient point. »',
      faitsMarquants: [
        'Investiture officielle en tant que Président de la Transition le 7 juin 2021.',
        'Adoption par référendum et promulgation de la nouvelle Constitution de la IVe République en juillet 2023.',
        'Reprise stratégique historique de la ville de Kidal par les FAMA le 14 novembre 2023.',
        'Création et consolidation de la Confédération des États du Sahel (AES) en 2024.',
        'Élévation historique au grade de Général d\'armée en octobre 2024.',
      ],
    ),
  ];
}
