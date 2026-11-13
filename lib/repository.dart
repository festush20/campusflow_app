import 'models.dart';

abstract class TaskRepository {
  Future<List<Task>> charger();
}

/// Date relative à aujourd'hui (ex. dans(1, 17) = demain à 17 h), au format ISO.
String _dans(int jours, int heure) {
  final n = DateTime.now().add(Duration(days: jours));
  return DateTime(n.year, n.month, n.day, heure).toIso8601String();
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
      {'id': 1, 'titre': 'Rendu TP Dart', 'echeance': _dans(1, 17)},
      {
        'id': 2,
        'titre': 'Projet Flutter',
        'echeance': _dans(3, 17),
        'description': 'Dossier de conception v1',
        'coursId': 1,
      },
      {
        'id': 3,
        'titre': 'Examen UX',
        'echeance': _dans(-1, 8),
        'terminee': true,
      },
      {
        'id': 4,
        'titre': 'Réviser XML et DTD',
        'echeance': _dans(5, 10),
        'coursId': 2,
      },
      {
        'id': 5,
        'titre': 'Rapport SOAP',
        'echeance': _dans(-2, 12),
        'description': 'Service Web à documenter',
        'coursId': 3,
      },
    ];
    return donnees.map(Task.fromJson).toList();
  }
}