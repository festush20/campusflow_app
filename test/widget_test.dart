import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/application/filtres.dart';
import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/features/taches/data/fake_task_repository.dart';
import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Écran haut pour que toute la liste soit visible pendant les tests.
void configurerEcran(WidgetTester tester, {double largeur = 800}) {
  tester.view.physicalSize = Size(largeur, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

ProviderContainer conteneur(FakeTaskRepository depot) {
  final container = ProviderContainer(
    overrides: [taskRepositoryProvider.overrideWithValue(depot)],
  );
  addTearDown(container.dispose);
  return container;
}

// Écran de titre, connexion, puis liste (chargée depuis le faux dépôt).
Future<FakeTaskRepository> demarrer(
    WidgetTester tester, {
      double largeur = 800,
      FakeTaskRepository? depot,
      bool attendre = true,
    }) async {
  configurerEcran(tester, largeur: largeur);
  final repo = depot ?? FakeTaskRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [taskRepositoryProvider.overrideWithValue(repo)],
      child: const CampusFlowApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Commencer'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).at(0), 'festus@campusflow.bf');
  await tester.enterText(find.byType(TextFormField).at(1), '1234');
  await tester.tap(find.text('Se connecter'));
  if (attendre) await tester.pumpAndSettle();
  return repo;
}

void main() {
  test('copyWith ne change que le champ demandé', () {
    final t = Task(id: 1, titre: 'TP', echeance: DateTime(2026, 11, 1));
    final t2 = t.copyWith(terminee: true);
    expect(t2.terminee, true);
    expect(t2.titre, 'TP');
    expect(t.terminee, false);
  });

  test('Course.fromJson et User.fromJson', () {
    final c = Course.fromJson({'id': 1, 'nom': 'Maths', 'enseignant': 'M. Ouedraogo'});
    final u = User.fromJson({'id': 2, 'nom': 'Awa', 'email': 'awa@exemple.com'});
    expect(c.nom, 'Maths');
    expect(u.email, 'awa@exemple.com');
  });

  test('Task.toJson puis fromJson redonne la même tâche', () {
    final t = Task(
      id: 7,
      titre: 'X',
      echeance: DateTime(2026, 12, 1, 9),
      description: 'd',
      coursId: 2,
    );
    final copie = Task.fromJson(t.toJson());
    expect(copie.id, 7);
    expect(copie.titre, 'X');
    expect(copie.echeance, DateTime(2026, 12, 1, 9));
    expect(copie.description, 'd');
    expect(copie.coursId, 2);
  });

  test('FakeTaskRepository : CRUD en mémoire', () async {
    final depot = FakeTaskRepository();
    final avant = (await depot.lister()).length;

    await depot.ajouter(Task(id: 99, titre: 'Test', echeance: DateTime(2030, 1, 1)));
    expect((await depot.lister()).length, avant + 1);

    final modifiee = await depot.changerStatut(99, true);
    expect(modifiee.terminee, true);

    await depot.supprimer(99);
    expect((await depot.lister()).length, avant);
  });

  test('TachesNotifier : ajouter, cocher et supprimer passent par le repository',
          () async {
        final depot = FakeTaskRepository();
        final container = conteneur(depot);
        await container.read(tachesProvider.future);
        final notifier = container.read(tachesProvider.notifier);

        await notifier.ajouter(Task(id: 10, titre: 'Nouvelle', echeance: DateTime(2030, 1, 1)));
        expect(container.read(listeTachesProvider).any((t) => t.id == 10), true);

        await notifier.basculer(10);
        expect(
          container.read(listeTachesProvider).firstWhere((t) => t.id == 10).terminee,
          true,
        );
        expect((await depot.lister()).firstWhere((t) => t.id == 10).terminee, true);

        await notifier.supprimer(10);
        expect(container.read(listeTachesProvider).any((t) => t.id == 10), false);
      });

  test('TachesNotifier : si le serveur échoue, l\'écran revient en arrière',
          () async {
        final depot = FakeTaskRepository();
        final container = conteneur(depot);
        await container.read(tachesProvider.future);

        depot.echec = true;
        await expectLater(
          container.read(tachesProvider.notifier).basculer(1),
          throwsA(isA<ApiException>()),
        );

        final t1 = container.read(listeTachesProvider).firstWhere((t) => t.id == 1);
        expect(t1.terminee, false); // l'état précédent est restauré
      });

  test('fournisseurs dérivés : à faire, faites, en retard', () async {
    final container = conteneur(FakeTaskRepository());
    await container.read(tachesProvider.future);

    expect(container.read(tachesFaitesProvider).length, 1);
    expect(container.read(tachesAFaireProvider).length, 4);
    expect(container.read(tachesEnRetardProvider).length, 1);
  });

  testWidgets('chargement (indicateur) puis liste', (tester) async {
    final depot = FakeTaskRepository(delai: const Duration(milliseconds: 500));
    await demarrer(tester, depot: depot, attendre: false);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Examen UX'), findsOneWidget);
  });

  testWidgets('erreur du serveur : message puis Réessayer', (tester) async {
    final depot = FakeTaskRepository(echec: true);
    await demarrer(tester, depot: depot);

    expect(find.text('Serveur injoignable.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    depot.echec = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Rendu TP Dart'), findsOneWidget);
  });

  testWidgets('le détail et la liste partagent le même état', (tester) async {
    await demarrer(tester);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Aucun cours'), findsOneWidget);

    await tester.tap(find.text('Marquer comme fait'));
    await tester.pumpAndSettle();
    expect(find.text('Marquer comme à faire'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('2/5'), findsOneWidget);
  });

  testWidgets('le filtre Faites ne garde que les tâches terminées',
          (tester) async {
        await demarrer(tester);

        await tester.tap(find.text('Faites'));
        await tester.pumpAndSettle();

        expect(find.text('Examen UX'), findsOneWidget);
        expect(find.text('Rendu TP Dart'), findsNothing);
      });

  testWidgets('le formulaire refuse un titre vide puis crée la tâche',
          (tester) async {
        final depot = await demarrer(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pump();
        expect(find.text('Titre requis'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).first, 'Réviser Dart');
        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.text('Réviser Dart'), findsOneWidget);
        expect(find.text('Tâche ajoutée'), findsOneWidget);
        expect((await depot.lister()).any((t) => t.titre == 'Réviser Dart'), true);
      });

  testWidgets('supprimer une tâche depuis son détail', (tester) async {
    final depot = await demarrer(tester);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Supprimer la tâche'));
    await tester.tap(find.text('Supprimer la tâche'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer')); // bouton de confirmation
    await tester.pumpAndSettle();

    expect(find.text('Rendu TP Dart'), findsNothing);
    expect(find.text('Tâche supprimée'), findsOneWidget);
    expect((await depot.lister()).any((t) => t.id == 1), false);
  });

  testWidgets('à 840 dp ou plus : liste et détail côte à côte', (tester) async {
    await demarrer(tester, largeur: 1000);

    expect(find.text('Sélectionne une tâche'), findsOneWidget);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pump();

    expect(find.text('Sélectionne une tâche'), findsNothing);
    expect(find.text('Marquer comme fait'), findsOneWidget);
  });

  testWidgets('la barre de navigation mène au calendrier', (tester) async {
    await demarrer(tester);

    await tester.tap(find.text('Calendrier'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Mois précédent'), findsOneWidget);
    expect(find.byTooltip('Mois suivant'), findsOneWidget);
  });
}