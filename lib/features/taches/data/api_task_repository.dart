import 'package:campusflow_app/core/api_exception.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';
import 'package:campusflow_app/models.dart';
import 'package:dio/dio.dart';

class ApiTaskRepository implements TaskRepository {
  final Dio _dio;

  ApiTaskRepository(this._dio);

  ApiException _traduire(DioException e) {
    final code = e.response?.statusCode;
    if (code == 401) {
      return const ApiException('Session expirée, reconnectez-vous.', statut: 401);
    }
    if (code != null) {
      return ApiException('Erreur du serveur ($code).', statut: code);
    }
    return const ApiException('Serveur injoignable. Vérifiez la connexion.');
  }

  @override
  Future<List<Task>> lister() async {
    try {
      final r = await _dio.get('/taches');
      final liste = r.data as List;
      return liste
          .map((j) => Task.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _traduire(e);
    }
  }

  @override
  Future<Task> ajouter(Task t) async {
    try {
      final r = await _dio.post('/taches', data: t.toJson()); // POST
      return Task.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _traduire(e);
    }
  }

  @override
  Future<Task> changerStatut(int id, bool terminee) async {
    try {
      final r = await _dio.patch('/taches/$id', data: {'terminee': terminee}); // PATCH
      return Task.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _traduire(e);
    }
  }

  @override
  Future<void> supprimer(int id) async {
    try {
      await _dio.delete('/taches/$id'); // DELETE
    } on DioException catch (e) {
      throw _traduire(e);
    }
  }
}