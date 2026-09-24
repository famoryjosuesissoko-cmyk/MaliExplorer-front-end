🇲🇱 MaliExplorer - Application Mobile (Frontend)MaliExplorer est une application mobile interactive dédiée à la valorisation, la promotion et la redécouverte du patrimoine culturel, historique et touristique du Mali. Conçue avec Flutter, elle offre une expérience immersive mêlant vues panoramiques 360°, chronologie interactive, modules ludo-éducatifs et services partenaires.🚀 Fonctionnalités PrincipalesModuleDescription🔐 Authentification (auth)Inscription, connexion sécurisée et gestion du profil utilisateur via Firebase / Supabase.🌍 Exploration 360° (discovery)Découverte guidée des villes et sites emblématiques avec visites virtuelles à 360°, cartographie et contenus multimédias.📜 Chronologie Historique (timeline)Frise chronologique interactive retraçant les époques clés et les figures marquantes de l'histoire du Mali.🎮 Gamification & Quiz (gamification)Systèmes de défis, quiz culturels et attribution de badges (Kuntigi) pour stimuler l'apprentissage.💼 Espace Partenaires (b2b)Soumission de projets, référencement d'acteurs touristiques et opportunités de partenariats.🛠️ Stack TechniqueFramework : Flutter (Dart)Gestion d'état : Flutter RiverpodNavigation : GoRouterServices Cloud & Backend : Firebase Auth, Supabase, API REST Spring BootRendu Médias & 360° : webview_flutter, video_player, cached_network_imageDesign & UI : Material 3, Google Fonts, flutter_svg🎨 Charte Graphique & Palette de CouleursLe design système s'inspire directement des paysages et de la culture malienne :Dartclass AppColors {
  static const Color primaryForest = Color(0xFF075E4D);    // Vert Forêt Profond (Vert principal)
  static const Color secondaryEmerald = Color(0xFF0E8F76); // Vert Émeraude (Vert secondaire)
  static const Color sahelGold = Color(0xFFD6A23A);         // Or Sahélien (Patrimoine & Accent)
  static const Color solarYellow = Color(0xFFF2B544);       // Jaune Solaire (Accent visuel)
  static const Color mistIvory = Color(0xFFF7F8F5);         // Ivoire Brumeux (Arrière-plan)
  static const Color pureWhite = Color(0xFFFFFFFF);          // Blanc Pur (Cartes & Surfaces)
  static const Color textPrimary = Color(0xFF16332D);        // Vert Anthracite (Texte principal)
  static const Color textSecondary = Color(0xFF6C7C77);      // Gris Sauge (Texte secondaire)
}
📐 Architecture du ProjetLe projet suit une architecture Feature-First combinée aux principes de la Clean Architecture :Plaintextlib/
├── core/                          # Socle partagé (thème, constantes, widgets globaux)
│   ├── constants/                 # Couleurs, dimensions, routes
│   ├── theme/                     # Configuration Material 3
│   ├── utils/                     # Formatters et helpers
│   └── widgets/                   # Composants UI réutilisables
│
├── features/                      # Modules métier indépendants
│   ├── auth/                      # Authentification
│   ├── discovery/                 # Exploration & 360°
│   ├── timeline/                  # Histoire & Chronologie
│   ├── gamification/              # Quiz & Badges
│   └── b2b/                       # Espace Partenaires
│       ├── data/                  # Modèles de données & DTOs
│       ├── domain/                # Logique métier pure
│       └── presentation/          # Écrans, contrôleurs Riverpod & widgets
│
├── router/                        # Configuration centrale GoRouter
└── services/                      # Clients d'intégration (API REST, Firebase, Supabase)
⚙️ Installation et LancementPrérequisFlutter SDK : ^3.13.0 ou supérieurDart SDK : Inclus avec FlutterIDE : VS Code ou Android Studio avec les extensions Flutter/DartÉtapes d'exécutionCloner le dépôt :Bashgit clone https://github.com/votre-compte/MaliExplorer-front-end.git
cd MaliExplorer-front-end
Installer les dépendances :Bashflutter pub get
Lancer l'application :Bash# Sur Chrome
flutter run -d chrome

# Sur un appareil Android
flutter run -d android
📄 LicenceProjet développé dans le cadre de la plateforme MaliExplorer. Tous droits réservés.
