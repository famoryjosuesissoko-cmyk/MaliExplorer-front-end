import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';

class ReligionModel {
  final int id;
  final String nom;
  final String? categorie;
  final String description;
  final String histoire;
  final String pratiques;
  final String fetes;
  final String lieuxDeCulte;
  final String regionsConcernees;
  final String? branches;
  final String proportionPopulation;
  final String nombrePratiquantsEstime;
  final String sourceStatistiques;
  final String anneeStatistiques;
  final String methodologieStatistiques;
  final String imageUrl;
  final int ordre;
  final bool publie;

  const ReligionModel({
    required this.id,
    required this.nom,
    this.categorie,
    required this.description,
    required this.histoire,
    required this.pratiques,
    required this.fetes,
    required this.lieuxDeCulte,
    required this.regionsConcernees,
    this.branches,
    required this.proportionPopulation,
    required this.nombrePratiquantsEstime,
    required this.sourceStatistiques,
    required this.anneeStatistiques,
    required this.methodologieStatistiques,
    required this.imageUrl,
    this.ordre = 0,
    this.publie = true,
  });

  factory ReligionModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['idReligion'] ?? 0;
    final int resolvedId = idVal is int ? idVal : int.tryParse(idVal.toString()) ?? 0;

    final rawDesc = json['description'] ?? json['descriptionHistorique'] ?? '';
    final rawHistoire = json['histoire'] ?? json['descriptionHistorique'] ?? '';
    final rawPratiques = json['pratiques'] ?? json['pratiquesEtFetes'] ?? '';
    final rawFetes = json['fetes'] ?? json['pratiquesEtFetes'] ?? '';
    final rawLieux = json['lieuxDeCulte'] ?? json['lieuxEmblematiques'] ?? '';

    // Branches / Courants (support String ou List)
    String? resolvedBranches;
    final rawBranches = json['branches'] ?? json['courantsOuBranches'];
    if (rawBranches is List) {
      resolvedBranches = rawBranches.join('\n');
    } else if (rawBranches != null) {
      resolvedBranches = rawBranches.toString();
    }

    // Proportion de la population / Pourcentage
    String resolvedProportion = 'Données non disponibles';
    final rawProp = json['proportionPopulation'] ?? json['pourcentageEstime'];
    if (rawProp != null && rawProp.toString().trim().isNotEmpty) {
      final s = rawProp.toString().trim();
      resolvedProportion = s.endsWith('%') ? s : '$s%';
    }

    // Ordre
    final rawOrdre = json['ordre'] ?? json['ordreAffichage'] ?? 0;
    final int resolvedOrdre = rawOrdre is int ? rawOrdre : int.tryParse(rawOrdre.toString()) ?? 0;

    // Publié
    final dynamic rawPublie = json['publie'] ?? json['estPublie'];
    final bool resolvedPublie = rawPublie is bool
        ? rawPublie
        : (rawPublie != null ? rawPublie.toString().toLowerCase() == 'true' : true);

    // Image URL
    final rawImg = json['imageUrl'] ?? json['photoUrl'];
    final String resolvedImg = (rawImg != null && rawImg.toString().trim().isNotEmpty)
        ? ApiConstants.resolveImageUrl(rawImg.toString().trim())
        : 'assets/images/home_hero.jpeg';

    return ReligionModel(
      id: resolvedId,
      nom: json['nom'] ?? '',
      categorie: json['categorie']?.toString(),
      description: rawDesc.toString(),
      histoire: rawHistoire.toString(),
      pratiques: rawPratiques.toString(),
      fetes: rawFetes.toString(),
      lieuxDeCulte: rawLieux.toString(),
      regionsConcernees: json['regionsConcernees']?.toString() ?? '',
      branches: resolvedBranches,
      proportionPopulation: resolvedProportion,
      nombrePratiquantsEstime: json['nombrePratiquantsEstime']?.toString() ?? 'Données non disponibles',
      sourceStatistiques: json['sourceStatistiques']?.toString() ?? 'INSTAT Mali / Rapports démographiques officiels',
      anneeStatistiques: json['anneeStatistiques']?.toString() ?? '2022',
      methodologieStatistiques: json['methodologieStatistiques']?.toString() ?? 'Recensement RGPH-5',
      imageUrl: resolvedImg,
      ordre: resolvedOrdre,
      publie: resolvedPublie,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
      'description': description,
      'histoire': histoire,
      'pratiques': pratiques,
      'fetes': fetes,
      'lieuxDeCulte': lieuxDeCulte,
      'regionsConcernees': regionsConcernees,
      'branches': branches,
      'proportionPopulation': proportionPopulation,
      'nombrePratiquantsEstime': nombrePratiquantsEstime,
      'sourceStatistiques': sourceStatistiques,
      'anneeStatistiques': anneeStatistiques,
      'methodologieStatistiques': methodologieStatistiques,
      'imageUrl': imageUrl,
      'ordre': ordre,
      'publie': publie,
    };
  }

  /// Données de secours rigoureuses et vérifiées (RGPH-5 INSTAT 2022)
  static List<ReligionModel> get defaultReligions => const [
    ReligionModel(
      id: 1,
      nom: 'Islam',
      categorie: 'Islam sunnite de rite malékite',
      description: 'L\'Islam est la religion pratiquée par l\'immense majorité de la population malienne. Introduit dès le IXe siècle le long des routes caravanières transsahariennes, il est marqué par la concorde, la tolérance et la fraternité confrérique.',
      histoire: 'L\'islamisation du Mali s\'est opérée pacifiquement à travers le commerce transsaharien et l\'enseignement des oulémas dans les empires du Ghana, du Mali et du Songhaï. L\'université de Sankoré à Tombouctou a rayonné mondialement du XIVe au XVIe siècle comme haut lieu théologique et juridique.',
      pratiques: 'Prière rituelle du vendredi (Jumu\'ah), jeûne du Ramadan, aumône légale (Zakat), pèlerinage, célébration du Maouloud, lecture des manuscrits anciens et dévotions confrériques.',
      fetes: 'Aïd al-Fitr (Korité), Aïd al-Adha (Tabaski), Maouloud (naissance du Prophète), Achoura (Tamkharit).',
      lieuxDeCulte: 'Grande Mosquée de Djenné, Mosquée Djingareyber et Sankoré à Tombouctou, Mosquée de Komoguel à Mopti, Grande Mosquée Fayçal de Bamako.',
      regionsConcernees: 'Présent de manière majoritaire dans l\'ensemble des 19 régions administratives du Mali et le District de Bamako.',
      branches: '• Sunnisme malékite (majorité écrasante des croyants)\n• Confrérie Soufie Tijaniyya (branches Omarienne et Hamalliste)\n• Confrérie Soufie Qadiriyya\n• Courant réformiste urbain.',
      proportionPopulation: '~94,8 % de la population',
      nombrePratiquantsEstime: '~20,8 millions de fidèles',
      sourceStatistiques: 'Recensement Général de la Population et de l\'Habitat (RGPH-5, INSTAT Mali 2022) ; US State Dept Report (2023).',
      anneeStatistiques: '2022-2023',
      methodologieStatistiques: 'Recensement national démographique exhaustif.',
      imageUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&w=1200&q=80',
      ordre: 1,
      publie: true,
    ),
    ReligionModel(
      id: 2,
      nom: 'Christianisme',
      categorie: 'Catholicisme et Protestantisme évangélique',
      description: 'Le christianisme au Mali forme une communauté fraternelle et reconnue pour ses œuvres éducatives, ses dispensaires et son engagement exemplaire dans le dialogue interreligieux.',
      histoire: 'La présence chrétienne contemporaine a débuté en 1888 à Kita avec les Pères Blancs. Des personnalités historiques, dont Monseigneur Luc Auguste Sangaré, ont joué un rôle déterminant dans la concorde et la consolidation républicaine.',
      pratiques: 'Messe dominicale, culte évangélique, pèlerinage marial national annuel de Kita (chaque mois de novembre), œuvres de solidarité et d\'entraide (Caritas Mali).',
      fetes: 'Noël (25 décembre, jour férié chômé au Mali), Pâques et Lundi de Pâques, Ascension, Assomption (15 août), Toussaint.',
      lieuxDeCulte: 'Cathédrale du Sacré-Cœur de Bamako, Sanctuaire Marial Notre-Dame de Kita, Cathédrale de Sikasso, Église de Mandiakuy, paroisses de San et Ségou.',
      regionsConcernees: 'Présent particulièrement dans les régions de San, Ségou, Sikasso, Kita, Kayes, Mopti et dans le District de Bamako.',
      branches: '• Église Catholique romaine (environ deux tiers des chrétiens maliens)\n• Églises Protestantes et Évangéliques réunies au sein de l\'AGEMPEM.',
      proportionPopulation: '~2,4 % de la population',
      nombrePratiquantsEstime: '~530 000 fidèles',
      sourceStatistiques: 'Recensement Général RGPH-5 (INSTAT Mali 2022) ; Conférence Épiscopale du Mali (CEM).',
      anneeStatistiques: '2022',
      methodologieStatistiques: 'Recensement officiel national et registres paroissiaux.',
      imageUrl: 'https://images.unsplash.com/photo-1548625361-19597a7e28ea?auto=format&fit=crop&w=1200&q=80',
      ordre: 2,
      publie: true,
    ),
    ReligionModel(
      id: 3,
      nom: 'Religions Traditionnelles Africaines',
      categorie: 'Spiritualités ancestrales et cosmogonies du terroir',
      description: 'Les spiritualités traditionnelles constituent la matrice philosophique ancestrale des peuples du Mali. Fondées sur le Créateur suprême, les ancêtres et les forces sacrées de la nature.',
      histoire: 'Systèmes de pensée millénaires transmis à travers les sociétés initiatiques (Poro sénoufo, Kôrêdugaw et Ciwara bambara, Do bobo, Awa dogon). Ces institutions ont forgé la cohésion sociale et la transmission morale.',
      pratiques: 'Rites agraires de semailles et de moissons, danses rituelles de masques, libations aux autels sacrés et consultations géomantiques par les aînés.',
      fetes: 'Fêtes agraires des récoltes, rituel septennal du Kamabloni de Kangaba, fêtes coutumières du Sigui chez les Dogon.',
      lieuxDeCulte: 'Bois sacrés communautaires, sanctuaire du Kamabloni à Kangaba, autels d\'ancêtres des falaises de Bandiagara (Hogon), sanctuaires de Bwatou.',
      regionsConcernees: 'Pays Dogon (Bandiagara), cercles de San et Tominian (Bwatou), régions de Sikasso et Koutiala (Sénoufo/Minianka), Mandé (Koulikoro/Kita).',
      branches: '• Cosmogonie Dogon (dirigée par le Hogon)\n• Société initiatique du Poro chez les Sénoufo\n• Rites Bambara et Malinké (Kôrêdugaw, Ciwara, Kômô)\n• Culte du Do chez les Bwa et Bobo.',
      proportionPopulation: '~2,0 % exclusivement déclarés (pratique coutumière diffuse plus étendue)',
      nombrePratiquantsEstime: '~440 000 adeptes exclusifs déclarés',
      sourceStatistiques: 'Recensement Général RGPH-5 (INSTAT Mali 2022) ; UNESCO.',
      anneeStatistiques: '2022',
      methodologieStatistiques: 'Recensement démographique officiel de la foi déclarée.',
      imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=1200&q=80',
      ordre: 3,
      publie: true,
    ),
    ReligionModel(
      id: 4,
      nom: 'Dialogue Interreligieux & Concorde',
      categorie: 'Tradition républicaine de vivre-ensemble',
      description: 'Le Mali se distingue par un pacte séculaire de fraternité interreligieuse et de cousinage à plaisanterie (Sinankunya), garantissant la paix civile et l\'harmonie républicaine.',
      histoire: 'Depuis la Charte de Kouroukan Fouga (1236), les maliens cultivent la médiation et la solidarité. Les familles musulmanes et chrétiennes partagent amicalement chaque fête sacrée.',
      pratiques: 'Visites de courtoisie mutuelle des dignitaires religieux lors des fêtes, prières conjointes pour la paix et médiation communautaire unifiée.',
      fetes: 'Célébrations partagées lors de la Tabaski, de Noël et des fêtes républicaines.',
      lieuxDeCulte: 'Haut Conseil Islamique du Mali (HCIM), Archevêché de Bamako, Assemblées chrétiennes et traditionnelles.',
      regionsConcernees: 'Ensemble des localités et régions de la République du Mali.',
      branches: '• Haut Conseil Islamique du Mali (HCIM)\n• Conférence Épiscopale du Mali (CEM)\n• Association AGEMPEM\n• Collectifs de femmes et de jeunes pour la paix.',
      proportionPopulation: 'Principe partagé par l\'ensemble des maliens (~100%)',
      nombrePratiquantsEstime: 'Ensemble des citoyens de la République du Mali',
      sourceStatistiques: 'Constitution de la IVe République du Mali (2023) ; Ministère des Affaires Religieuses et du Culte.',
      anneeStatistiques: '2023',
      methodologieStatistiques: 'Cadre républicain et charte de dialogue civil.',
      imageUrl: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?auto=format&fit=crop&w=1200&q=80',
      ordre: 4,
      publie: true,
    ),
  ];

  /// Sélectionne l'icône de culte appropriée en fonction de la foi ou de la tradition religieuse
  static IconData getAdaptiveIcon(String? nom, [String? categorie]) {
    final text = '${nom ?? ''} ${categorie ?? ''}'.toLowerCase();
    if (text.contains('islam') ||
        text.contains('musulman') ||
        text.contains('mosquée') ||
        text.contains('mosquee')) {
      return Icons.mosque_rounded;
    }
    if (text.contains('christ') ||
        text.contains('chrétien') ||
        text.contains('chretien') ||
        text.contains('eglise') ||
        text.contains('église') ||
        text.contains('catholi') ||
        text.contains('protest')) {
      return Icons.church_rounded;
    }
    if (text.contains('animis') ||
        text.contains('tradition') ||
        text.contains('ancestr') ||
        text.contains('cosmogon') ||
        text.contains('nature') ||
        text.contains('coutum')) {
      return Icons.nature_people_rounded;
    }
    return Icons.account_balance_rounded;
  }
}

