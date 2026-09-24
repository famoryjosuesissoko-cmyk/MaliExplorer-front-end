# MaliExplorer — Frontend

> **Espace Découverte, Valorisation & Partenariats du Mali**

MaliExplorer est une plateforme **Web & Mobile** dédiée à la découverte et à la valorisation du patrimoine culturel, historique et touristique du Mali.


## Fonctionnalités

* Exploration du Mali et découverte des lieux
* Histoire, patrimoine et chronologie
* Expériences immersives 360°
* Quiz et système de badges
* Favoris et recommandations
* Espace partenaires et opportunités B2B
* Authentification Firebase
* Interface Web & Mobile

## Technologies

* **Flutter / Dart**
* **Material 3**
* **Riverpod**
* **GoRouter**
* **Firebase Authentication**
* **Spring Boot / API REST**
* **Supabase Storage**
* **MySQL**

## Architecture

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── discovery/
│   ├── timeline/
│   ├── gamification/
│   └── b2b/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── router/
└── services/
```

### Architecture des fonctionnalités

Chaque fonctionnalité métier est organisée de manière indépendante afin de faciliter la maintenance et l'évolution du projet.

```text
feature/
├── data/
├── domain/
└── presentation/
```

## Authentification

Firebase Authentication gère l'authentification des utilisateurs.

Le backend **Spring Boot** vérifie les tokens Firebase avant l'accès aux ressources protégées.

Les mots de passe ne sont **pas stockés dans MySQL**.

## Installation

```bash
git clone <URL_DU_REPOSITORY>
cd maliexplorer-frontend
flutter pub get
flutter run
```

Pour lancer la version Web :

```bash
flutter run -d chrome
```

## Identité visuelle

| Couleur            | HEX       |
| ------------------ | --------- |
| Vert Forêt Profond | `#075E4D` |
| Vert Émeraude      | `#0E8F76` |
| Or Sahélien        | `#D6A23A` |
| Jaune Solaire      | `#F2B544` |
| Ivoire Brumeux     | `#F7F8F5` |
| Blanc Pur          | `#FFFFFF` |
| Vert Anthracite    | `#16332D` |
| Gris Sauge         | `#6C7C77` |

## Équipe

**Famory Josué Sissoko** & 
**Hamath Oumar Diallo**


---

**MaliExplorer — Découvrir, valoriser et connecter le Mali.**
