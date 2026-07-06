# Game Board

Plateforme multi-jeux de plateau mobile (iOS/Android) développée avec Flutter dans le cadre du projet IPSSI.

## Objectif du projet

Game Board propose trois jeux de plateau classiques — Morpion, Puissance 4 et Jeu de Dames (règles françaises) —
jouables en solo contre un bot (3 niveaux de difficulté basés sur minimax) ou en local à deux joueurs. Les comptes
utilisateurs, l'historique et les statistiques de parties sont synchronisés via Firebase.

## Composition du groupe

- Front-end / UI-UX : [À compléter]
- Back-end / logique de jeu, Firebase, algorithmes : [À compléter]

## Jeux et modes

| Jeu | Plateau | Règles |
|---|---|---|
| Morpion | 3x3 | Classique |
| Puissance 4 | 6x7 | Classique |
| Dames | 10x10 | Règles françaises, prises obligatoires, rafles, promotion en dame |

- **1 joueur vs bot** : Facile (aléatoire), Moyen (heuristique / minimax profondeur limitée), Difficile (minimax + élagage alpha-bêta)
- **2 joueurs en local** : tour par tour sur le même appareil
- Les bots utilisent uniquement du minimax pur, aucune API IA externe

## Stack technique

- **Flutter / Dart** — SDK ^3.12.2
- **flutter_bloc** — gestion d'état (BLoC pattern)
- **go_router** — navigation déclarative
- **firebase_core / firebase_auth / cloud_firestore** — authentification et base de données
- **shared_preferences** — persistance locale (thème, dernier jeu, difficulté préférée)
- **google_fonts** — typographie (Poppins)
- **audioplayers** — effets sonores
- **equatable** — comparaison de valeur pour les entités et états BLoC

## Architecture

Le projet suit une **Clean Architecture** stricte en trois couches, afin de garantir que la logique de jeu et les
règles métier restent totalement indépendantes de Firebase et de l'UI (testabilité, remplaçabilité des sources de
données, séparation claire des responsabilités entre les deux développeurs) :

```
lib/
├── core/            # thème, router, constantes, service locator
├── domain/          # entités, enums, interfaces abstraites (aucune dépendance Flutter/Firebase)
├── data/            # implémentations concrètes (Firebase Auth, Firestore, SharedPreferences)
├── application/      # BLoCs et moteurs de jeu (logique pure, testable sans UI)
└── presentation/     # écrans et widgets (aucune logique métier)
```

- Aucune logique métier n'est écrite dans les widgets.
- Aucun appel Firebase direct n'est fait dans les blocs : ils passent exclusivement par les interfaces du
  `domain/repositories/`, implémentées dans `data/repositories/`.
- Les moteurs de jeu (`TicTacToeEngine`, `Connect4Engine`, `CheckersEngine`) implémentent tous l'interface
  `GameEngine` et ne connaissent ni Flutter ni Firebase : ils sont testables unitairement en isolation.

## Configuration Firebase

Le dépôt contient un fichier `android/app/google-services.json` **placeholder** qui ne fonctionnera pas tel quel.
Pour le remplacer par une vraie configuration :

1. Créer un projet sur [Firebase Console](https://console.firebase.google.com/).
2. Ajouter une application Android avec l'ID de package `com.ipssi.gameboard.game_board`.
3. Télécharger le vrai `google-services.json` et remplacer `android/app/google-services.json`.
4. Activer **Authentication > Email/Password** dans la console Firebase.
5. Créer une base **Cloud Firestore** (mode production ou test selon les besoins) avec les collections `users` et
   `scores`.
6. (Optionnel mais recommandé) Installer la CLI FlutterFire et lancer `flutterfire configure` pour générer
   automatiquement `lib/firebase_options.dart` et les configurations iOS/Android/Web.

## Lancer le projet

```bash
flutter pub get
flutter analyze
flutter run
```

## Difficultés rencontrées

[À compléter après développement]
