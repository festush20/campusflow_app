import 'package:campusflow_app/core/dio_provider.dart';
import 'package:campusflow_app/features/taches/data/api_task_repository.dart';
import 'package:campusflow_app/features/taches/domain/task_repository.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Seul point d'accès aux données : on remplace l'implémentation en test.
final taskRepositoryProvider = Provider<TaskRepository>(
      (ref) => ApiTaskRepository(ref.watch(dioProvider)),
);

class TachesNotifier extends AsyncNotifier<List<Task>> {
  // Chargement initial : AsyncLoading, puis AsyncData ou AsyncError.
  @override
  Future<List<Task>> build() => ref.watch(taskRepositoryProvider).lister();

  // POST
  Future<void> ajouter(Task t) async {
    final creee = await ref.read(taskRepositoryProvider).ajouter(t);
    final actuelles = state.valueOrNull ?? <Task>[];
    state = AsyncData([...actuelles, creee]);
  }

  // PATCH : l'écran change tout de suite, et revient en arrière si le serveur échoue.
  Future<void> basculer(int id) async {
    final avant = state.valueOrNull;
    if (avant == null) return;
    Task? cible;
    for (final t in avant) {
      if (t.id == id) cible = t;
    }
    if (cible == null) return;
    final nouvelleValeur = !cible.terminee;

    state = AsyncData([
      for (final t in avant)
        t.id == id ? t.copyWith(terminee: nouvelleValeur) : t,
    ]);
    try {
      await ref.read(taskRepositoryProvider).changerStatut(id, nouvelleValeur);
    } catch (_) {
      state = AsyncData(avant);
      rethrow;
    }
  }

  // DELETE : même principe.
  Future<void> supprimer(int id) async {
    final avant = state.valueOrNull;
    if (avant == null) return;
    state = AsyncData([
      for (final t in avant)
        if (t.id != id) t,
    ]);
    try {
      await ref.read(taskRepositoryProvider).supprimer(id);
    } catch (_) {
      state = AsyncData(avant);
      rethrow;
    }
  }
}

final tachesProvider =
AsyncNotifierProvider<TachesNotifier, List<Task>>(TachesNotifier.new);

// La liste telle quelle (vide tant qu'elle n'est pas chargée), pour les écrans
// et les fournisseurs dérivés.
final listeTachesProvider = Provider<List<Task>>(
      (ref) => ref.watch(tachesProvider).valueOrNull ?? const <Task>[],
);