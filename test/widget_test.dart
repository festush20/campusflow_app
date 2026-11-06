import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> attendreChargement(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  test('copyWith ne change que le champ demandé', () {
    final t = Task(id: 1, titre: 'TP', echeance: DateTime(2026, 11, 1));
    final t2 = t.copyWith(terminee: true);
    expect(t2.terminee, true);
    expect(t2.titre, 'TP');
    expect(t.terminee, false);
  });

  test('Course.fromJson construit un cours', () {
    final c = Course.fromJson({'id': 1, 'nom': 'Maths', 'enseignant': 'M. Ouedraogo'});
    expect(c.id, 1);
    expect(c.nom, 'Maths');
  });

  test('User.fromJson construit un utilisateur', () {
    final u = User.fromJson({'id': 2, 'nom': 'Awa', 'email': 'awa@exemple.com'});
    expect(u.nom, 'Awa');
    expect(u.email, 'awa@exemple.com');
  });

  testWidgets('affiche le chargement puis les tâches', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await attendreChargement(tester);

    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Examen UX'), findsOneWidget);
  });

  testWidgets('toucher une tâche ouvre son détail (téléphone)', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    await attendreChargement(tester);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();

    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Aucun cours'), findsOneWidget);
  });

  testWidgets('le formulaire refuse un titre vide puis ajoute la tâche',
          (tester) async {
        await tester.pumpWidget(const CampusFlowApp());
        await attendreChargement(tester);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pump();
        expect(find.text('Titre requis'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField).first, 'Réviser XML');
        await tester.ensureVisible(find.text('Enregistrer'));
        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(find.text('Réviser XML'), findsOneWidget);
        expect(find.text('Tâche ajoutée'), findsOneWidget);
      });

  testWidgets('à 840 dp ou plus : liste et détail côte à côte', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CampusFlowApp());
    await attendreChargement(tester);

    expect(find.text('Sélectionne une tâche'), findsOneWidget);

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pump();

    expect(find.text('Sélectionne une tâche'), findsNothing);
    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Examen UX'), findsOneWidget);
  });
}