
## Student Hub (UEMF)

Application mobile Flutter qui centralise les annonces, événements, clubs et informations pratiques du campus de l'Université Euromed de Fès (UEMF).

> **Projet réalisé par :** Hind El Messsaouri - Marwa Reffouh - Firdawss El Hayouni - Hamza Smlali - Mohamed Wassim Boukhari
> **Filière / Niveau :** Développement Android 
> **Encadrant :** Clement Regis Tuyishime
> **Année universitaire :** [2026-2027]

---

## 1. Présentation

Les étudiants reçoivent aujourd'hui l'information du campus par de nombreux canaux dispersés. Student Hub propose un point d'accès unique, réservé aux membres de l'université : seules les adresses `@ueuromed.org` sont acceptées, et l'accès n'est ouvert qu'après vérification de l'adresse e-mail.

## 2. Fonctionnalités

| Module | Description |
| --- | --- |
| **Inscription / Connexion** | Domaine `@ueuromed.org` (et sous-domaines) uniquement. Validation en direct, suggestion de correction de faute de frappe, indicateur de robustesse du mot de passe. |
| **Vérification d'e-mail** | Aucun accès à l'application tant que l'adresse n'est pas vérifiée. |
| **Accueil** | Annonce épinglée, statistiques, dernières actualités, événements à venir, clubs à découvrir, recherche globale. |
| **Actualités** | Catégories, recherche, indicateur de non-lu, favoris, page de détail. Les publicateurs peuvent publier. |
| **Événements** | Bandeau de 14 jours, filtre par catégorie, agenda « J'y vais », page de détail. |
| **Clubs** | Filtre par catégorie, suivre / ne plus suivre, page du club avec fil d'actualité et contact. |
| **Campus** | Services avec statut Ouvert / Fermé en direct, horaires, lieux, contacts utiles. |
| **Profil** | Badge « vérifié », compteurs, choix de la couleur d'accentuation, déconnexion. |

## 3. Technologies

- **Flutter / Dart** : application mobile (Android)
- **Firebase Authentication** : comptes et vérification d'e-mail
- **google_fonts** : polices Space Grotesk et Inter
- Deux modes d'exécution : **Démo** (sans serveur) et **Firebase** (réel)

## 4. Prérequis

- Flutter SDK (version stable) : https://docs.flutter.dev/get-started/install
- Android Studio avec un émulateur (ex. Pixel 7) ou un téléphone Android en débogage USB
- Pour le mode Firebase : un compte Google et un projet Firebase

> **Windows :** le projet, le SDK Flutter (`C:\src\flutter`) et le cache des paquets (`PUB_CACHE=C:\pub_cache`) doivent se trouver dans des chemins **sans espace**, et le **mode développeur** de Windows doit être activé.

## 5. Installation et lancement

### Mode Démo (aucun serveur requis)

Les comptes sont stockés sur l'appareil et le code de vérification à 6 chiffres s'affiche à l'écran. **Aucun e-mail réel n'est envoyé dans ce mode.**

```bash
flutter pub get
flutter run
```

Astuce : s'inscrire avec `admin@ueuromed.org` donne accès aux fonctions de publication (bouton « + » dans l'onglet Actualités).

### Mode Firebase (vérification d'e-mail réelle)

1. Créer un projet sur https://console.firebase.google.com
2. **Authentication → Méthode de connexion → E-mail/Mot de passe → Activer**
3. Configurer le projet :
   ```bash
   dart pub global activate flutterfire_cli
   firebase login
   flutterfire configure
   ```
   Cette commande remplace `lib/firebase_options.dart` par les paramètres réels.
4. Vérifier que `minSdk` vaut au moins **23** dans `android/app/build.gradle(.kts)`.
5. Lancer :
   ```bash
   flutter run --dart-define=USE_FIREBASE=true
   ```

### Générer l'APK

Vérifier que `android/app/src/main/AndroidManifest.xml` contient la permission `android.permission.INTERNET`, puis :

```bash
flutter build apk --release --dart-define=USE_FIREBASE=true
```

Le fichier se trouve dans `build/app/outputs/flutter-apk/app-release.apk`.

## 6. Architecture

```
lib/
├── main.dart                 Point d'entrée, routage selon l'état de connexion
├── app_config.dart           Domaines autorisés, publicateurs, mode Démo / Firebase
├── firebase_options.dart     Configuration Firebase (générée par flutterfire)
├── theme/app_theme.dart      Couleurs, polices, palettes d'accentuation
├── models/models.dart        Annonce, Événement, Club, Service du campus
├── data/seed_data.dart       Contenu d'exemple
├── services/
│   ├── email_rules.dart      Validation UEMF et suggestions de correction
│   └── auth_service.dart     Implémentations Firebase et Démo
├── state/app_state.dart      Session, abonnements, agenda, favoris, publication
├── widgets/                  Composants d'interface partagés
└── screens/                  Écrans (auth, vérification, accueil, actualités,
                              événements, clubs, campus, profil, recherche)
test/widget_test.dart         Tests unitaires des règles d'e-mail
```

## 7. Sécurité

La vérification du domaine dans l'application donne un retour immédiat, mais **elle peut être contournée** par quelqu'un qui contacte Firebase directement. Les garanties réelles sont :

- **E-mail vérifié obligatoire** : l'application bloque les comptes non vérifiés.
- **Règles côté serveur** : pour toute donnée stockée (Firestore, Storage), exiger
  `request.auth.token.email_verified == true && request.auth.token.email.matches('.*@ueuromed[.]org')`.
- **Blocage à la création** : les *blocking functions* de Firebase Auth (`beforeCreate`, Identity Platform) peuvent refuser tout e-mail hors UEMF.
- **Droits de publication** : `AppConfig.publisherEmails` est un raccourci de prototype. En production, utiliser des *custom claims* attribués par un administrateur.

## 8. Limites connues

- **Contenu d'exemple** : annonces, événements, clubs, horaires et contacts de `lib/data/seed_data.dart` sont fictifs et doivent être remplacés par les données réelles de l'université.
- **Données locales** : abonnements, « J'y vais », favoris et publications sont enregistrés sur l'appareil. Pour partager le contenu entre étudiants, il faut un backend partagé (Cloud Firestore est la suite naturelle ; seul `AppState` serait à adapter).
- **Polices** : chargées via `google_fonts` à la première utilisation ; à embarquer en ressources pour un usage totalement hors ligne.

## 9. Évolutions prévues

Notifications push pour les clubs suivis, ajout au calendrier, carte interactive du campus, localisation arabe / français / anglais, tableaux de bord pour les responsables de club, enregistrement d'entrée par QR code, backend Firestore.

## 10. Licence et contact

Projet académique, UEMF. 
