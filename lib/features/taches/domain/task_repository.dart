import 'package:campusflow_app/models.dart';

abstract class TaskRepository {
  Future<List<Task>> lister();
  Future<Task> ajouter(Task t);
  Future<Task> changerStatut(int id, bool terminee);
  Future<void> supprimer(int id);
}