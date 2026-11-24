import 'package:campusflow_app/core/etats_ui.dart';
import 'package:campusflow_app/ecran_calendrier.dart';
import 'package:campusflow_app/ecran_detail.dart';
import 'package:campusflow_app/ecran_echeances.dart';
import 'package:campusflow_app/ecran_formulaire.dart';
import 'package:campusflow_app/features/taches/application/filtres.dart';
import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/features/taches/presentation/avec_taches.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class PageEcheances extends ConsumerWidget {
  const PageEcheances({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return avecTaches(ref, () {
      final taches = ref.watch(listeTachesProvider);
      final visibles = ref.watch(tachesVisiblesProvider);
      final filtre = ref.watch(filtreProvider);
      final selection = ref.watch(selectionProvider);

      return LayoutBuilder(
        builder: (context, contraintes) {
          final etendu = contraintes.maxWidth >= 840;
          final liste = ListeEcheances(
            taches: taches,
            visibles: visibles,
            filtre: filtre,
            selectionId: etendu ? selection : null,
            onFiltre: (f) => ref.read(filtreProvider.notifier).choisir(f),
            onOuvrir: etendu
                ? (Task t) => ref.read(selectionProvider.notifier).choisir(t.id)
                : (Task t) => context.push('/taches/${t.id}'),
            onBasculer: (Task t) => executerAction(
              context,
                  () => ref.read(tachesProvider.notifier).basculer(t.id),
            ),
          );
          if (!etendu) return liste;

          final choisie = trouverTache(taches, selection);
          return Row(
            children: [
              Expanded(flex: 2, child: liste),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: choisie == null
                    ? const Center(child: Text('Sélectionne une tâche'))
                    : DetailContenu(
                  tache: choisie,
                  onChange: (t) => executerAction(
                    context,
                        () => ref.read(tachesProvider.notifier).basculer(t.id),
                  ),
                  onSupprimer: () async {
                    final ok = await executerAction(
                      context,
                          () => ref
                          .read(tachesProvider.notifier)
                          .supprimer(choisie.id),
                      succes: 'Tâche supprimée',
                    );
                    if (ok) {
                      ref.read(selectionProvider.notifier).choisir(null);
                    }
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

/// /calendrier
class PageCalendrier extends ConsumerWidget {
  const PageCalendrier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return avecTaches(
      ref,
          () => EcranCalendrier(
        taches: ref.watch(listeTachesProvider),
        onOuvrir: (Task t) => context.push('/taches/${t.id}'),
        onBasculer: (Task t) => executerAction(
          context,
              () => ref.read(tachesProvider.notifier).basculer(t.id),
        ),
      ),
    );
  }
}

/// /taches/:id : lit l'identifiant dans l'adresse.
class PageDetail extends ConsumerWidget {
  final int? id;
  const PageDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tache = trouverTache(ref.watch(listeTachesProvider), id);
    return Scaffold(
      appBar: AppBar(title: Text(tache?.titre ?? 'Tâche')),
      body: avecTaches(ref, () {
        if (tache == null) {
          return const Center(child: Text('Tâche introuvable'));
        }
        return DetailContenu(
          tache: tache,
          onChange: (t) => executerAction(
            context,
                () => ref.read(tachesProvider.notifier).basculer(t.id),
          ),
          onSupprimer: () async {
            final ok = await executerAction(
              context,
                  () => ref.read(tachesProvider.notifier).supprimer(tache.id),
              succes: 'Tâche supprimée',
            );
            if (ok && context.mounted) context.pop();
          },
        );
      }),
    );
  }
}

class PageFormulaire extends ConsumerWidget {
  const PageFormulaire({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormulaireTache(nouvelId: ref.watch(prochainIdProvider));
  }
}