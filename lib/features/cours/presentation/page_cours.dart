import 'package:campusflow_app/donnees.dart';
import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/features/taches/presentation/avec_taches.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// /cours
class PageCours extends ConsumerWidget {
  const PageCours({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return avecTaches(ref, () {
      final toutes = ref.watch(listeTachesProvider);
      final couleurs = Theme.of(context).colorScheme;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: coursDemo.map((c) {
          final duCours = toutes.where((t) => t.coursId == c.id).toList();
          final faites = duCours.where((t) => t.terminee).length;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: couleurs.primaryContainer,
                foregroundColor: couleurs.onPrimaryContainer,
                child: Text(c.nom.substring(0, 1)),
              ),
              title: Text(c.nom),
              subtitle: Text(
                '${c.enseignant} · ${duCours.length} tâche(s), $faites terminée(s)',
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}