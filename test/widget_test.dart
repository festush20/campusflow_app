import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter_test/flutter_test.dart';

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
    expect(c.enseignant, 'M. Ouedraogo');
  });

  test('User.fromJson construit un utilisateur', () {
    final u = User.fromJson({'id': 2, 'nom': 'Awa', 'email': 'awa@exemple.com'});
    expect(u.nom, 'Awa');
    expect(u.email, 'awa@exemple.com');
  });

  testWidgets('affiche le chargement puis les tâches', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Examen UX'), findsOneWidget);
  });

  testWidgets('toucher une tâche ouvre son détail', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    await tester.tap(find.text('Rendu TP Dart'));
    await tester.pumpAndSettle();

    expect(find.text('Marquer comme fait'), findsOneWidget);
    expect(find.text('Aucun cours'), findsOneWidget);
  });
}