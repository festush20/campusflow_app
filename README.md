# CampusFlow (application Flutter)

Application mobile de suivi des échéances académiques, réalisée dans le cadre du cours de Programmation mobile (Master 1, Université Aube Nouvelle).

**Auteur(s) :** WOROMOGO Hery Festus
**Date :** 28 octobre 2026

L'application réutilise les modèles Dart de l'atelier « Les modèles de CampusFlow en Dart pur » : https://github.com/TON_PSEUDO/campusflow_models.

## Fonctionnalités

- **Échéances** : chargement simulé (indicateur de chargement, puis liste des tâches), possibilité de cocher une tâche comme faite, d'ajouter une tâche avec le bouton +, et message d'erreur avec bouton « Réessayer ».
- **Cours** : liste des cours.
- **Profil** : informations de l'utilisateur et interrupteur pour simuler une erreur réseau.
- Navigation par barre inférieure (Échéances, Cours, Profil) et thème Material 3.

## Structure du projet

- `lib/models.dart` : les modèles `Task`, `Course` et `User` (attributs `final`, constructeur `const`, `copyWith`, `fromJson`).
- `lib/repository.dart` : l'interface `TaskRepository` et le dépôt simulé `FakeTaskRepository` (`Future.delayed`, erreur possible).
- `lib/main.dart` : l'interface Flutter.
- `test/widget_test.dart` : tests (`copyWith` et affichage du chargement puis des tâches).

## Lancer l'application

```
flutter pub get
flutter run
```

Choisir ensuite l'appareil : Chrome ou un téléphone branché en USB (débogage USB activé).

## Lancer les tests

```
flutter analyze
flutter test
```

## Ce que j'ai appris

- **Immutabilité et copyWith** : les objets sont `final`. Pour cocher une tâche, on crée une copie avec `copyWith` au lieu de modifier l'original.
- **Future et états de l'écran** : un `Future` passe par trois états (en cours, valeur, erreur), ce qui se traduit par trois affichages : chargement, liste, message d'erreur.
- **Interface et dépôt séparés** : l'interface dépend de `TaskRepository`, donc on pourra remplacer le faux dépôt par une vraie API sans changer l'écran.
- [Ajoute ici une chose que tu as apprise ou une difficulté rencontrée, avec tes propres mots.]