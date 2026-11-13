import 'package:flutter/material.dart';

import 'donnees.dart';
import 'models.dart';

/// Écran Échéances : bandeau de statistiques, filtres, puis ListView.builder de cartes.
class ListeEcheances extends StatelessWidget {
  final List<Task> taches;
  final Filtre filtre;
  final int? selectionId; // tâche mise en évidence (mode tablette)
  final ValueChanged<Filtre> onFiltre;
  final ValueChanged<Task> onOuvrir;
  final ValueChanged<Task> onBasculer;

  const ListeEcheances({
    super.key,
    required this.taches,
    required this.filtre,
    required this.onFiltre,
    required this.onOuvrir,
    required this.onBasculer,
    this.selectionId,
  });

  bool _estCetteSemaine(Task t) {
    final maintenant = DateTime.now();
    final debut = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final fin = debut.add(const Duration(days: 7));
    return !t.echeance.isBefore(debut) && t.echeance.isBefore(fin);
  }

  bool _enRetard(Task t) => !t.terminee && t.echeance.isBefore(DateTime.now());

  bool _correspond(Task t) {
    switch (filtre) {
      case Filtre.toutes:
        return true;
      case Filtre.semaine:
        return _estCetteSemaine(t);
      case Filtre.aFaire:
        return !t.terminee;
    }
  }

  Widget _stat(BuildContext context, String valeur, String libelle) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valeur,
            style: textes.headlineMedium?.copyWith(color: couleurs.onPrimary),
          ),
          Text(
            libelle,
            style: textes.bodySmall?.copyWith(
              color: couleurs.onPrimary.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entete(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;
    final total = taches.length;
    final faites = taches.where((t) => t.terminee).length;
    final semaine = taches.where((t) => !t.terminee && _estCetteSemaine(t)).length;
    final retard = taches.where(_enRetard).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            couleurs.primary,
            Color.alphaBlend(Colors.black.withAlpha(90), couleurs.primary),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: couleurs.primary.withAlpha(70),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour Festus',
            style: textes.titleLarge?.copyWith(color: couleurs.onPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            'Voici où vous en êtes.',
            style: textes.bodyMedium?.copyWith(
              color: couleurs.onPrimary.withAlpha(220),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(context, '$semaine', 'à faire cette semaine'),
              _stat(context, '$retard', 'en retard'),
              _stat(context, '$faites/$total', 'terminées'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : faites / total,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(60),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtres() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _puceFiltre('Toutes', Filtre.toutes),
          _puceFiltre('Cette semaine', Filtre.semaine),
          _puceFiltre('À faire', Filtre.aFaire),
        ],
      ),
    );
  }

  Widget _puceFiltre(String texte, Filtre f) {
    return ChoiceChip(
      label: Text(texte),
      selected: filtre == f,
      onSelected: (_) => onFiltre(f),
    );
  }

  Widget _pastille(IconData icone, String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: couleur),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              texte,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: couleur,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carte(BuildContext context, Task t) {
    final couleurs = Theme.of(context).colorScheme;
    final retard = _enRetard(t);
    final cours = nomDuCours(t.coursId);
    final Color accent;
    if (t.terminee) {
      accent = couleurs.tertiary;
    } else if (retard) {
      accent = couleurs.error;
    } else {
      accent = couleurs.primary;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        color: t.id == selectionId ? couleurs.primaryContainer : couleurs.surface,
        child: InkWell(
          onTap: () => onOuvrir(t),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                    child: Row(
                      children: [
                        Semantics(
                          label: 'Statut de la tâche ${t.titre}',
                          child: Checkbox(
                            value: t.terminee,
                            onChanged: (_) => onBasculer(t),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.titre,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  decoration: t.terminee
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _pastille(
                                    Icons.event,
                                    formatDate(t.echeance),
                                    retard ? couleurs.error : couleurs.primary,
                                  ),
                                  if (cours != null)
                                    _pastille(
                                      Icons.school,
                                      cours,
                                      couleurs.secondary,
                                    ),
                                  if (retard)
                                    _pastille(
                                      Icons.warning_amber,
                                      'En retard',
                                      couleurs.error,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          semanticLabel: 'Ouvrir le détail',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibles = taches.where(_correspond).toList()
      ..sort((a, b) => a.echeance.compareTo(b.echeance));
    // Index 0 : bandeau + filtres. Ensuite une carte par tâche (ou un message vide).
    final nombre = 1 + (visibles.isEmpty ? 1 : visibles.length);
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: nombre,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(children: [_entete(context), _filtres()]);
        }
        if (visibles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Aucune tâche pour ce filtre')),
          );
        }
        return _carte(context, visibles[i - 1]);
      },
    );
  }
}