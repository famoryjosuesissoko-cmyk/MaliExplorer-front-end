# MaliExplorer Plateforme de Découverte Culturelle & Touristique du Mali
#Structure MaliExplorer FrontEnd :
lib/
├── core/                          # Socle partagé par TOUTE l'application
│   ├── constants/                 # Couleurs (AppColors), polices, tailles, constantes API
│   ├── theme/                     # Configuration ThemeData (Mode clair / sombre)
│   ├── utils/                     # Fonctions d'aide (formatters de date, conversion FCFA)
│   └── widgets/                   # Boutons, cartes, inputs réutilisables dans tout le projet
│
├── features/                      # Découpage par Fonctionnalités Métier (Feature-First)
│   ├── auth/                      # Module Connexion / Inscription
│   ├── discovery/                 # Module Exploration, Villes, Lieux & Panoramas 360°
│   ├── timeline/                  # Module Chronologie de l'histoire du Mali
│   ├── gamification/              # Module Quiz & Badges (Kuntigi)
│   └── b2b/                       # Module Soumission de projets partenaires
│       │
│       # --- Architecture interne de CHAQUE module (Clean Architecture) ---
│       ├── data/                  # 1. COUCHE DONNÉES : Modèles JSON, requêtes HTTP / Supabase
│       ├── domain/                # 2. COUCHE MÉTIER : Règles logiques et objets purs
│       └── presentation/          # 3. COUCHE AFFICHAGE : Interface Utilisateur (UI)
│           ├── screens/           # Pages complètes (ex: LoginScreen.dart, PanoramaScreen.dart)
│           ├── controllers/       # Gestion d'état avec Riverpod (Providers / Logic)
│           └── widgets/           # Composants visuels spécifiques à ce module uniquement
│
├── router/                        # Navigation centralisée de l'application (GoRouter)
└── services/                      # Clients d'intégration (Firebase, Supabase, Spring Boot)
