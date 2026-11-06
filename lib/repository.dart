
import 'models.dart';

abstract class TaskRepository {
  Future<List<Task>> charger();
}

class FakeTaskRepository implements TaskRepository {
  final bool echec;

  const FakeTaskRepository({this.echec = false});

  @override
  Future<List<Task>> charger() async {
    await Future.delayed(const Duration(seconds: 1));

    if (echec) {
      throw Exception('Réseau coupé');
    }

    // Dates calculées automatiquement à partir de la date actuelle.
    final maintenant = DateTime.now();

    final donnees = <Map<String, dynamic>>[
      {
        'id': 1,
        'titre': 'Rendu TP Dart',
        'echeance': DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day + 1,
          17,
        ).toIso8601String(),
        'coursId': 1,
        'description': 'Finaliser et déposer le travail pratique de Dart.',
      },
      {
        'id': 2,
        'titre': 'Projet Flutter',
        'echeance': DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day + 3,
          17,
        ).toIso8601String(),
        'coursId': 1,
        'description': 'Préparer la version de démonstration du projet.',
      },
      {
        'id': 3,
        'titre': 'Examen UX',
        'echeance': DateTime(
          maintenant.year,
          maintenant.month,
          maintenant.day + 5,
          8,
        ).toIso8601String(),
        'coursId': 2,
        'terminee': true,
        'description': 'Réviser les notions principales du cours UX.',
      },
    ];

    return donnees.map(Task.fromJson).toList();
  }
}
