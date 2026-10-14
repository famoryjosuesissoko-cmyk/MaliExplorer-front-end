import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class LangueItem {
  final String nom;
  final String nomLocal;
  final String locuteurs;
  final String regions;
  final String description;
  final List<LexiqueItem> lexique;

  const LangueItem({
    required this.nom,
    required this.nomLocal,
    required this.locuteurs,
    required this.regions,
    required this.description,
    required this.lexique,
  });
}

class LexiqueItem {
  final String mot;
  final String phonetique;
  final String traduction;
  final String categorie;

  const LexiqueItem({
    required this.mot,
    required this.phonetique,
    required this.traduction,
    required this.categorie,
  });
}

class LanguesNationalesScreen extends StatefulWidget {
  const LanguesNationalesScreen({super.key});

  @override
  State<LanguesNationalesScreen> createState() => _LanguesNationalesScreenState();
}

class _LanguesNationalesScreenState extends State<LanguesNationalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedLangueIndex = 0;
  String _selectedCategorie = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Salutations',
    'Courtoisie',
    'Marché & Commerce',
    'Orientation & Déplacement',
    'Expressions usuelles',
  ];

  final List<LangueItem> _langues = const [
    LangueItem(
      nom: 'Bamanankan (Bambara)',
      nomLocal: 'Bamanankan',
      locuteurs: '~80% de la population malienne',
      regions: 'Bamako, Ségou, Koulikoro, Sikasso',
      description:
          'Langue véhiculaire principale du Mali, membre de la famille des langues mandées. Elle est comprise dans presque toutes les grandes villes et sur les marchés.',
      lexique: [
        LexiqueItem(mot: 'I ni sogoma', phonetique: 'i-ni-so-go-ma', traduction: 'Bonjour (le matin)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni tilé', phonetique: 'i-ni-ti-lé', traduction: 'Bonjour (l\'après-midi)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni sou', phonetique: 'i-ni-sou', traduction: 'Bonsoir', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ka kènè wa ?', phonetique: 'i-ka-kè-nè-wa', traduction: 'Comment vas-tu ? (Es-tu en santé ?)', categorie: 'Salutations'),
        LexiqueItem(mot: 'Toro té', phonetique: 'to-ro-té', traduction: 'Tout va bien (Pas de mal)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni tché', phonetique: 'i-ni-tché', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Aw ni baara', phonetique: 'aw-ni-baa-ra', traduction: 'Bon travail / Bravo', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Hakèto', phonetique: 'ha-kè-to', traduction: 'Pardon / Excusez-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Joli don ?', phonetique: 'djo-li-don', traduction: 'Combien ça coûte ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A ka guèlèn', phonetique: 'a-ka-guè-lèn', traduction: 'C\'est trop cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Dòoni dòoni bò a la', phonetique: 'dò-ni-dò-ni-bò-a-la', traduction: 'Diminue un peu le prix', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Ne b\'a fè', phonetique: 'né-ba-fè', traduction: 'Je le veux / J\'aimerais l\'acheter', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Yòrò jumèn ?', phonetique: 'yò-rò-djou-mèn', traduction: 'Où est cet endroit ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Sira jira ne na', phonetique: 'si-ra-dji-ra-né-na', traduction: 'Montre-moi le chemin', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'An b\'a fò nògònna', phonetique: 'an-ba-fò-nò-gòn-na', traduction: 'À la prochaine / Au revoir', categorie: 'Expressions usuelles'),
        LexiqueItem(mot: 'A tè foyi yé', phonetique: 'a-tè-fo-yi-yé', traduction: 'De rien / Ce n\'est rien', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Fulfulde (Peul)',
      nomLocal: 'Pulaar / Fulfulde',
      locuteurs: '~15% de la population malienne',
      regions: 'Mopti (Delta intérieur du Niger), Gao, Sikasso',
      description:
          'Langue parlée par le peuple Peul à travers toute l\'Afrique de l\'Ouest, célèbre pour sa richesse poétique, ses traditions pastorales et le festival du Yaaral.',
      lexique: [
        LexiqueItem(mot: 'Jam waali', phonetique: 'djam-waa-li', traduction: 'Bonjour (Avez-vous passé une nuit paisible ?)', categorie: 'Salutations'),
        LexiqueItem(mot: 'Jam ñalli', phonetique: 'djam-ñal-li', traduction: 'Bonjour (Avez-vous passé une bonne journée ?)', categorie: 'Salutations'),
        LexiqueItem(mot: 'Jam hiiri', phonetique: 'djam-hii-ri', traduction: 'Bonsoir', categorie: 'Salutations'),
        LexiqueItem(mot: 'No mbaddaa ?', phonetique: 'no-mbad-daa', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Jam tan', phonetique: 'djam-tan', traduction: 'La paix seulement / Tout va bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'A jaaraama', phonetique: 'a-djaa-raa-ma', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Accee hakke', phonetique: 'at-chee-hak-ke', traduction: 'Pardonnez-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Noy coggu maggu ?', phonetique: 'noy-tsog-gou-mag-gou', traduction: 'Quel est le prix ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Ina tiiɗi', phonetique: 'i-na-tii-di', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Ustu seeɗa', phonetique: 'ous-tou-see-da', traduction: 'Baisse un peu', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Hol to woni...', phonetique: 'hol-to-wo-ni', traduction: 'Où se trouve...', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'En jango', phonetique: 'en-djan-go', traduction: 'À demain', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Songhaï (Koyraboro Senni)',
      nomLocal: 'Songhoy Senni',
      locuteurs: '~10% de la population malienne',
      regions: 'Tombouctou, Gao, Ménaka (Boucle du Niger)',
      description:
          'Grande langue de l\'empire Songhaï historique, présente le long des rives sahéliennes de Tombouctou à Ansongo.',
      lexique: [
        LexiqueItem(mot: 'M\'baani', phonetique: 'm-baa-ni', traduction: 'Bonjour / Paix sur vous', categorie: 'Salutations'),
        LexiqueItem(mot: 'Woy matenkene ?', phonetique: 'woy-ma-ten-ke-ne', traduction: 'Comment allez-vous ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Baani samay', phonetique: 'baa-ni-sa-may', traduction: 'Bien, tout va pour le mieux', categorie: 'Salutations'),
        LexiqueItem(mot: 'Fofo', phonetique: 'fo-fo', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Yaaf\'ay', phonetique: 'yaa-fay', traduction: 'Pardonnez-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Marje no ?', phonetique: 'mar-djé-no', traduction: 'C\'est combien ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A gaa caabandi', phonetique: 'a-gaa-tsaa-ban-di', traduction: 'Diminue le prix', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Man no...', phonetique: 'man-no', traduction: 'Où est...', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Kala han foo', phonetique: 'ka-la-han-foo', traduction: 'À bientôt / Au revoir', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Soninké (Maraka)',
      nomLocal: 'Sooninkanxanne',
      locuteurs: '~7% de la population malienne',
      regions: 'Kayes, Nara, Nioro du Sahel',
      description:
          'Langue fondatrice du prestigieux Empire du Wagadou (Ghana antique), renommée pour sa grande diaspora et ses traditions marchandes séculaires.',
      lexique: [
        LexiqueItem(mot: 'An do kenne', phonetique: 'an-do-ken-ne', traduction: 'Bonjour', categorie: 'Salutations'),
        LexiqueItem(mot: 'Tan moxo wa ?', phonetique: 'tan-mo-xo-wa', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Jammu ngi', phonetique: 'djam-mou-ngi', traduction: 'En paix / Tout va bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'N\'jaaraama', phonetique: 'n-djaa-raa-ma', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Yafam', phonetique: 'ya-fam', traduction: 'Pardonne-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Mange ?', phonetique: 'man-guè', traduction: 'Combien ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A jatti', phonetique: 'a-djat-ti', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Mini na...', phonetique: 'mi-ni-na', traduction: 'Où est...', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Soxona', phonetique: 'so-xo-na', traduction: 'À la prochaine', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Tamasheq (Berbère touareg)',
      nomLocal: 'Tamasheq / Tamajeq',
      locuteurs: '~5% de la population malienne',
      regions: 'Kidal, Ménaka, Tombouctou, Gao',
      description:
          'Langue berbère des Touaregs du Sahara (Kel Tamasheq), écrite avec l\'alphabet millénaire Tifinagh et porteuse de poésie du désert.',
      lexique: [
        LexiqueItem(mot: 'Oywan', phonetique: 'oy-wan', traduction: 'Bonjour / Salut', categorie: 'Salutations'),
        LexiqueItem(mot: 'Matoliyt ?', phonetique: 'ma-to-liyt', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Alxeyr ghas', phonetique: 'al-xeyr-rhas', traduction: 'Seulement la paix / Bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'Tanemmirt', phonetique: 'ta-nem-mirt', traduction: 'Merci beaucoup', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Surf-iyi', phonetique: 'sourf-i-yi', traduction: 'Excuse-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Manik a iga ?', phonetique: 'ma-nik-a-i-ga', traduction: 'Combien ça coûte ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Mani...', phonetique: 'ma-ni', traduction: 'Où se trouve...', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Ar tufat', phonetique: 'ar-tou-fat', traduction: 'À demain / Au revoir', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Dogonso (Dogon)',
      nomLocal: 'Toro So / Dogoso',
      locuteurs: '~6% de la population malienne',
      regions: 'Pays Dogon, Bandiagara, Falaise d\'hombori',
      description:
          'Ensemble de dialectes parlés au pied et sur le plateau de la mythique Falaise de Bandiagara (classée UNESCO), riches en cosmovision et rituels.',
      lexique: [
        LexiqueItem(mot: 'Aga po', phonetique: 'a-ga-po', traduction: 'Bonjour (le matin)', categorie: 'Salutations'),
        LexiqueItem(mot: 'De po', phonetique: 'dé-po', traduction: 'Bonjour (en journée)', categorie: 'Salutations'),
        LexiqueItem(mot: 'Ana po', phonetique: 'a-na-po', traduction: 'Bonsoir', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kuru go ?', phonetique: 'kou-rou-go', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kuru', phonetique: 'kou-rou', traduction: 'Bien / Tout va bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'Bir po', phonetique: 'bir-po', traduction: 'Merci / Bon travail', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Anje be...', phonetique: 'an-djé-bé', traduction: 'Où est...', categorie: 'Orientation & Déplacement'),
      ],
    ),
    LangueItem(
      nom: 'Khassonké (Xasonga)',
      nomLocal: 'Xasongaxanne',
      locuteurs: '~5% de la population malienne',
      regions: 'Kayes, Bafoulabé, Vallée du Haut-Sénégal',
      description:
          'Langue mandingue occidentale parlée par les Khassonkés du bassin du fleuve Sénégal, réputée pour ses contes oraux et les chants de griots de Médine.',
      lexique: [
        LexiqueItem(mot: 'I ni sugu', phonetique: 'i-ni-sou-gou', traduction: 'Bonjour (le matin)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni tle', phonetique: 'i-ni-tlé', traduction: 'Bonjour (l\'après-midi)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni su', phonetique: 'i-ni-sou', traduction: 'Bonsoir', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kene wa ?', phonetique: 'ké-né-wa', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Toro te', phonetique: 'to-ro-té', traduction: 'Tout va bien (Pas de mal)', categorie: 'Salutations'),
        LexiqueItem(mot: 'A barika', phonetique: 'a-ba-ri-ka', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Hake to', phonetique: 'ha-ké-to', traduction: 'Excusez-moi / Pardon', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'I ni baara', phonetique: 'i-ni-baa-ra', traduction: 'Bon travail', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Joli le ?', phonetique: 'djo-li-lé', traduction: 'Combien coûte cela ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A ka geleng', phonetique: 'a-ka-gué-lèng', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Dooni boyi a la', phonetique: 'dô-ni-bo-yi-a-la', traduction: 'Diminue un peu le prix', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Sira jiri n\'na', phonetique: 'si-ra-dji-ri-n-na', traduction: 'Montre-moi le chemin', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Yoro mingo ?', phonetique: 'yo-ro-min-go', traduction: 'Où se trouve cet endroit ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Bisimila', phonetique: 'bi-si-mi-la', traduction: 'Bienvenue', categorie: 'Expressions usuelles'),
        LexiqueItem(mot: 'An b\'a fo nyoona', phonetique: 'an-ba-fo-nyoo-na', traduction: 'À la prochaine / Au revoir', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Maninkakan (Malinké)',
      nomLocal: 'Maninkakan',
      locuteurs: '~7% de la population malienne',
      regions: 'Kita, Kangaba, Mandé, Kéniéba, Yanfolila',
      description:
          'Langue de la grande épopée mandingue de Soundiata Keïta et de la Charte de Kouroukan Fouga (patrimoine UNESCO). Berceau des chasseurs dosso et des balafons.',
      lexique: [
        LexiqueItem(mot: 'I ni sogoma', phonetique: 'i-ni-so-go-ma', traduction: 'Bonjour (le matin)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni tile', phonetique: 'i-ni-ti-lé', traduction: 'Bonjour (en journée)', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ka kene wa ?', phonetique: 'i-ka-ké-né-wa', traduction: 'Tu vas bien ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'I ni tche', phonetique: 'i-ni-tché', traduction: 'Merci beaucoup', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Hake to', phonetique: 'ha-ké-to', traduction: 'Pardon / Excusez-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Aw ni baara', phonetique: 'aw-ni-baa-ra', traduction: 'Courage au travail', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Joli do ?', phonetique: 'djo-li-do', traduction: 'Quel est le prix ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A gbara', phonetique: 'a-gba-ra', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Do bo a la', phonetique: 'do-bo-a-la', traduction: 'Baisse le prix s\'il te plaît', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Yoro juman ?', phonetique: 'yo-ro-djou-man', traduction: 'Où est cet endroit ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Sira djira ne la', phonetique: 'si-ra-dji-ra-né-la', traduction: 'Indique-moi la route', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'I bisimila', phonetique: 'i-bi-si-mi-la', traduction: 'Bienvenue chez nous', categorie: 'Expressions usuelles'),
        LexiqueItem(mot: 'K\'an ben', phonetique: 'kan-bèn', traduction: 'Au revoir / À bientôt', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Sénoufo (Syenara)',
      nomLocal: 'Syenara / Senari',
      locuteurs: '~9% de la population malienne',
      regions: 'Sikasso, Kadiolo, Koutiala, Yorosso',
      description:
          'Langue du Kénédougou et du sud agricole, emblématique de la culture agraire, des masques sculptés et de la musique de balafon des maîtres du bois.',
      lexique: [
        LexiqueItem(mot: 'Fotamana', phonetique: 'fo-ta-ma-na', traduction: 'Bonjour / Salutations', categorie: 'Salutations'),
        LexiqueItem(mot: 'Mi yege wa ?', phonetique: 'mi-yé-gué-wa', traduction: 'Comment ça va ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kari gbaa', phonetique: 'ka-ri-gbaa', traduction: 'Ça va bien / En paix', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kaha', phonetique: 'ka-ha', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Kafo', phonetique: 'ka-fo', traduction: 'Excuse-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Kpa megi ?', phonetique: 'kpa-mé-gui', traduction: 'Combien coûte ceci ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Si baha', phonetique: 'si-ba-ha', traduction: 'C\'est trop cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Tolo nyini', phonetique: 'to-lo-nyi-ni', traduction: 'Diminue un peu', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Ka tana ?', phonetique: 'ka-ta-na', traduction: 'Où vas-tu / Où est la voie ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Fotamana', phonetique: 'fo-ta-ma-na', traduction: 'Bienvenue', categorie: 'Expressions usuelles'),
        LexiqueItem(mot: 'Ka nyeen', phonetique: 'ka-nyeen', traduction: 'À plus tard', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Minianka (Mamara)',
      nomLocal: 'Minyanka / Mamara',
      locuteurs: '~4% de la population malienne',
      regions: 'Koutiala, San, Bla, Tominian',
      description:
          'Langue voltaïque proche du sénoufo, parlée dans le grand bassin cotonnier de Koutiala et les plaines fertiles de San.',
      lexique: [
        LexiqueItem(mot: 'N\'fola', phonetique: 'n-fo-la', traduction: 'Bonjour / Salutations', categorie: 'Salutations'),
        LexiqueItem(mot: 'Yege wa ?', phonetique: 'yé-gué-wa', traduction: 'La santé est bonne ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Lafi', phonetique: 'la-fi', traduction: 'Tout va bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kaha', phonetique: 'ka-ha', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Yafa n\'ne', phonetique: 'ya-fa-n-né', traduction: 'Pardonne-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Wari joro ?', phonetique: 'wa-ri-djo-ro', traduction: 'Quel montant ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A taha', phonetique: 'a-ta-ha', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Dogi a na', phonetique: 'do-gui-a-na', traduction: 'Baisse un peu', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Kulo be min ?', phonetique: 'kou-lo-bé-min', traduction: 'Où se trouve la route ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'K\'an ben', phonetique: 'kan-bèn', traduction: 'Au revoir', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Bozo (Boso)',
      nomLocal: 'Bososo / Boso',
      locuteurs: '~3% de la population malienne',
      regions: 'Mopti, Ségou, Djenné, Delta central du Niger',
      description:
          'Langue ancestrale des « Maîtres du Fleuve Niger », pêcheurs et navigateurs en pinasses emblématiques de la boucle du fleuve.',
      lexique: [
        LexiqueItem(mot: 'A ni tie', phonetique: 'a-ni-tié', traduction: 'Bonjour / Salut', categorie: 'Salutations'),
        LexiqueItem(mot: 'Kene wa ?', phonetique: 'ké-né-wa', traduction: 'La forme ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Toro te', phonetique: 'to-ro-té', traduction: 'Pas de problème', categorie: 'Salutations'),
        LexiqueItem(mot: 'A jaaraama', phonetique: 'a-djaa-raa-ma', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Yafa', phonetique: 'ya-fa', traduction: 'Pardon', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Joli le ?', phonetique: 'djo-li-lé', traduction: 'C\'est combien ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Yege wari', phonetique: 'yé-gué-wa-ri', traduction: 'Prix du poisson', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Dogoni bo a la', phonetique: 'do-go-ni-bo-a-la', traduction: 'Fais un rabais', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Kounou be min ?', phonetique: 'kou-nou-bé-min', traduction: 'Où est la pirogue / le port ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'An ben', phonetique: 'an-bèn', traduction: 'À plus tard', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Bobo (Bomu)',
      nomLocal: 'Bomu / Bwamu',
      locuteurs: '~3% de la population malienne',
      regions: 'San, Tominian, Plaine du Bani',
      description:
          'Langue du peuple Bwa, réputée pour ses traditions agraires, les masques de feuilles et la fête du Sanké à San.',
      lexique: [
        LexiqueItem(mot: 'A fowa', phonetique: 'a-fo-wa', traduction: 'Bonjour', categorie: 'Salutations'),
        LexiqueItem(mot: 'Mi zaani ?', phonetique: 'mi-zaa-ni', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Zaani', phonetique: 'zaa-ni', traduction: 'Bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'A barka', phonetique: 'a-bar-ka', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Yafa', phonetique: 'ya-fa', traduction: 'Excusez-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Kpa djo ?', phonetique: 'kpa-djo', traduction: 'Combien ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'A tian', phonetique: 'a-tian', traduction: 'C\'est cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Wa be min ?', phonetique: 'wa-bé-min', traduction: 'Où se trouve la voie ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'K\'an ben', phonetique: 'kan-bèn', traduction: 'Au revoir', categorie: 'Expressions usuelles'),
      ],
    ),
    LangueItem(
      nom: 'Arabe Hassaniya',
      nomLocal: 'Kallam Hassaniya',
      locuteurs: '~2% de la population malienne',
      regions: 'Tombouctou, Taoudénit, Bassikounou, Nord malien',
      description:
          'Dialecte arabe bédouin des Maures et commerçants transsahariens, au cœur des routes de caravanes d\'azalaï de sel.',
      lexique: [
        LexiqueItem(mot: 'Salam aleikoum', phonetique: 'sa-lam-a-ley-koum', traduction: 'Que la paix soit sur vous', categorie: 'Salutations'),
        LexiqueItem(mot: 'Mettariki ?', phonetique: 'met-ta-ri-ki', traduction: 'Comment vas-tu ?', categorie: 'Salutations'),
        LexiqueItem(mot: 'Labass', phonetique: 'la-bass', traduction: 'Rien de grave / Tout va bien', categorie: 'Salutations'),
        LexiqueItem(mot: 'Choukran', phonetique: 'chou-kran', traduction: 'Merci', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Smahli', phonetique: 'smah-li', traduction: 'Pardonne-moi', categorie: 'Courtoisie'),
        LexiqueItem(mot: 'Bkem tha ?', phonetique: 'b-kem-tha', traduction: 'Combien coûte cela ?', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Ghaali yasser', phonetique: 'ghaa-li-yas-ser', traduction: 'C\'est très cher', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Nagass chwaya', phonetique: 'na-gass-chwa-ya', traduction: 'Baisse un peu', categorie: 'Marché & Commerce'),
        LexiqueItem(mot: 'Vayn et-triq ?', phonetique: 'vayn-et-triq', traduction: 'Où est la route ?', categorie: 'Orientation & Déplacement'),
        LexiqueItem(mot: 'Marhaban', phonetique: 'mar-ha-ban', traduction: 'Bienvenue', categorie: 'Expressions usuelles'),
        LexiqueItem(mot: 'Maa salama', phonetique: 'maa-sa-la-ma', traduction: 'Au revoir / Que la paix t\'accompagne', categorie: 'Expressions usuelles'),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLangue = _langues[_selectedLangueIndex];

    // Filtrer le lexique selon catégorie et recherche
    final filteredLexique = currentLangue.lexique.where((item) {
      final matchesCat =
          _selectedCategorie == 'Tous' || item.categorie == _selectedCategorie;
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.mot.toLowerCase().contains(q) ||
          item.traduction.toLowerCase().contains(q) ||
          item.phonetique.toLowerCase().contains(q);
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // En-tête vert MaliExplorer
          Container(
            color: const Color(0xFF075E4D),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRouter.explorer);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LANGUES NATIONALES DU MALI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Lexique pratique pour voyager et échanger (F16)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFFD1E7DD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Barre de recherche de mots
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un mot, salutation ou traduction...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8C9B96)),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF075E4D), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sélecteur horizontal de langues
          Container(
            height: 48,
            color: isDark ? const Color(0xFF1E2825) : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _langues.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedLangueIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      _langues[index].nom.split(' ')[0],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF4A5568),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF075E4D),
                    backgroundColor: isDark ? const Color(0xFF2C3935) : const Color(0xFFF0F4F2),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    onSelected: (val) {
                      if (val) setState(() => _selectedLangueIndex = index);
                    },
                  ),
                );
              },
            ),
          ),

          // Sélecteur horizontal de catégories thématiques
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161F1C) : const Color(0xFFFAFBFA),
              border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.15))),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategorie == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF075E4D) : const Color(0xFF6B7280),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategorie = cat),
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFF075E4D).withValues(alpha: 0.12),
                    checkmarkColor: const Color(0xFF075E4D),
                    shape: RoundedRectangle18(),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                );
              },
            ),
          ),

          // Carte descriptive de la langue courante
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF24322E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentLangue.nom,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF075E4D),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentLangue.locuteurs,
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6C7C77)),
                      const SizedBox(width: 4),
                      Text(
                        'Régions : ${currentLangue.regions}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF6C7C77), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentLangue.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : const Color(0xFF4A5568),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Titre liste lexique
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEXIQUE DU QUOTIDIEN (${filteredLexique.length})',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Color(0xFF6C7C77),
                  ),
                ),
                Text(
                  currentLangue.nomLocal,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF075E4D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Liste des expressions
          Expanded(
            child: filteredLexique.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                        const SizedBox(height: 8),
                        const Text(
                          'Aucune expression trouvée pour cette recherche.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF6C7C77)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredLexique.length,
                    itemBuilder: (context, index) {
                      final item = filteredLexique[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2825) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.015),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF075E4D).withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.record_voice_over_rounded,
                                size: 16,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.mot,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF075E4D),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.categorie,
                                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '[${item.phonetique}]',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF718096),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.traduction,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF1A202C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RoundedRectangle18 extends RoundedRectangleBorder {
  RoundedRectangle18()
      : super(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        );
}

