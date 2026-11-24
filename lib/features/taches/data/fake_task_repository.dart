import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';
import 'package:campusflow_app/models.dart';


class FakeTaskRepository implements TaskRepository {
  bool echec;
  final Duration delai;
  final List<Task> _taches;

  FakeTaskRepository({
    List<Task>? initiales,
    this.echec = false,
    this.delai = Duration.zero,
  }) : _taches = [...(initiales ?? exemples())];

  static List<Task> exemples() {
    final maintenant = DateTime.now();
    DateTime dans(int jours, int heure) {
      final d = maintenant.add(Duration(days: jours));
      return DateTime(d.year, d.month, d.day, heure);
    }

    return [
      Task(id: 1, titre: 'Rendu TP Dart', echeance: dans(1, 17)),
      Task(
        id: 2,
        titre: 'Projet Flutter',
        echeance: dans(3, 17),
        description: 'Dossier de conception v1',
        coursId: 1,
      ),
      Task(id: 3, titre: 'Examen UX', echeance: dans(-1, 8), terminee: true),
      Task(
        id: 4,
        titre: 'Réviser XML et DTD',
        echeance: dans(5, 10),
        coursId: 2,
      ),
      Task(
        id: 5,
        titre: 'Rapport SOAP',
        echeance: dans(-2, 12),
        description: 'Service Web à documenter',
        coursId: 3,
      ),
    ];
  }

  Future<void> _simuler() async {
    if (delai > Duration.zero) await Future.delayed(delai);
    if (echec) throw const ApiException('Serveur injoignable.');
  }

  @override
  Future<List<Task>> lister() async {
    await _simuler();
    return [..._taches];
  }

  @override
  Future<Task> ajouter(Task t) async {
    await _simuler();
    _taches.add(t);
    return t;
  }

  @override
  Future<Task> changerStatut(int id, bool terminee) async {
    await _simuler();
    final index = _taches.indexWhere((t) => t.id == id);
    if (index < 0) {
      throw const ApiException('Tâche introuvable.', statut: 404);
    }
    _taches[index] = _taches[index].copyWith(terminee: terminee);
    return _taches[index];
  }

  @override
  Future<void> supprimer(int id) async {
    await _simuler();
    _taches.removeWhere((t) => t.id == id);
  }
}