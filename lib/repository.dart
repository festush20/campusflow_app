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
    final donnees = <Map<String, dynamic>>[
      {'id': 1, 'titre': 'Rendu TP Dart', 'echeance': '2026-10-29T17:00:00'},
      {
        'id': 2,
        'titre': 'Projet Flutter',
        'echeance': '2026-10-30T17:00:00',
        'description': 'Dossier de conception v1',
      },
      {
        'id': 3,
        'titre': 'Examen UX',
        'echeance': '2026-11-02T08:00:00',
        'terminee': true,
      },
    ];
    return donnees.map(Task.fromJson).toList();
  }
}
