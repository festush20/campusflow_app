import 'package:campusflow_app/core/etats_ui.dart';
import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


Widget avecTaches(WidgetRef ref, Widget Function() donnees) {
  final etat = ref.watch(tachesProvider);
  return etat.when(
    skipLoadingOnRefresh: false,
    data: (_) => donnees(),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) => MessageErreur(
      message: messageDe(e),
      onReessayer: () => ref.invalidate(tachesProvider),
    ),
  );
}

Task? trouverTache(List<Task> liste, int? id) {
  for (final t in liste) {
    if (t.id == id) return t;
  }
  return null;
}