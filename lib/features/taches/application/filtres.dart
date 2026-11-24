import 'package:campusflow_app/donnees.dart';
import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool estEnRetard(Task t) => !t.terminee && t.echeance.isBefore(DateTime.now());

// Fournisseurs dérivés : calculés à partir de la liste chargée.
final tachesAFaireProvider = Provider<List<Task>>(
      (ref) => ref.watch(listeTachesProvider).where((t) => !t.terminee).toList(),
);

final tachesFaitesProvider = Provider<List<Task>>(
      (ref) => ref.watch(listeTachesProvider).where((t) => t.terminee).toList(),
);

final tachesEnRetardProvider = Provider<List<Task>>(
      (ref) => ref.watch(listeTachesProvider).where(estEnRetard).toList(),
);

// Filtre actif choisi par l'utilisateur.
class FiltreNotifier extends Notifier<Filtre> {
  @override
  Filtre build() => Filtre.toutes;

  void choisir(Filtre f) => state = f;
}

final filtreProvider =
NotifierProvider<FiltreNotifier, Filtre>(FiltreNotifier.new);

// Liste affichée à l'écran selon le filtre actif.
final tachesVisiblesProvider = Provider<List<Task>>((ref) {
  final filtre = ref.watch(filtreProvider);
  switch (filtre) {
    case Filtre.toutes:
      return ref.watch(listeTachesProvider);
    case Filtre.aFaire:
      return ref.watch(tachesAFaireProvider);
    case Filtre.faites:
      return ref.watch(tachesFaitesProvider);
    case Filtre.enRetard:
      return ref.watch(tachesEnRetardProvider);
  }
});

// Tâche ouverte à droite en mode tablette.
class SelectionNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void choisir(int? id) => state = id;
}

final selectionProvider =
NotifierProvider<SelectionNotifier, int?>(SelectionNotifier.new);

// Identifiant de la prochaine tâche créée.
final prochainIdProvider = Provider<int>((ref) {
  final taches = ref.watch(listeTachesProvider);
  var maximum = 0;
  for (final t in taches) {
    if (t.id > maximum) maximum = t.id;
  }
  return maximum + 1;
});