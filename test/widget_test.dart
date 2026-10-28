import 'package:campusflow_app/main.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith ne change que le champ demandé', () {
    final t = Task(id: 1, titre: 'TP', echeance: DateTime(2026, 11, 1));
    final t2 = t.copyWith(terminee: true);
    expect(t2.terminee, true);
    expect(t2.titre, 'TP');
    expect(t.terminee, false);
  });

  testWidgets('affiche le chargement puis les tâches', (tester) async {
    await tester.pumpWidget(const CampusFlowApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Rendu TP Dart'), findsOneWidget);
    expect(find.text('Examen UX'), findsOneWidget);
  });
}