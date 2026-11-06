import 'package:flutter/material.dart';

import 'donnees.dart';
import 'models.dart';

const _moisNoms = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];
const _joursNoms = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

bool _memeJour(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Calendrier mensuel : un point sous chaque jour qui a des échéances,
/// et la liste des tâches du jour choisi en dessous.
class EcranCalendrier extends StatefulWidget {
  final List<Task> taches;
  final ValueChanged<Task> onOuvrir;
  final ValueChanged<Task> onBasculer;

  const EcranCalendrier({
    super.key,
    required this.taches,
    required this.onOuvrir,
    required this.onBasculer,
  });

  @override
  State<EcranCalendrier> createState() => _EcranCalendrierState();
}

class _EcranCalendrierState extends State<EcranCalendrier> {
  late DateTime _mois;
  late DateTime _jour;

  @override
  void initState() {
    super.initState();
    final maintenant = DateTime.now();
    _jour = DateTime(maintenant.year, maintenant.month, maintenant.day);
    _mois = DateTime(maintenant.year, maintenant.month);
  }

  void _changerMois(int delta) {
    setState(() => _mois = DateTime(_mois.year, _mois.month + delta));
  }

  List<Task> _tachesDuJour(DateTime jour) =>
      widget.taches.where((t) => _memeJour(t.echeance, jour)).toList();

  Widget _cellule(BuildContext context, DateTime? jour) {
    if (jour == null) return const SizedBox(height: 48);
    final couleurs = Theme.of(context).colorScheme;
    final taches = _tachesDuJour(jour);
    final selectionne = _memeJour(jour, _jour);
    final aujourdhui = _memeJour(jour, DateTime.now());
    final enAttente = taches.any((t) => !t.terminee);

    final Color couleurPoint;
    if (selectionne) {
      couleurPoint = couleurs.onPrimary;
    } else if (enAttente) {
      couleurPoint = couleurs.error;
    } else {
      couleurPoint = couleurs.outline;
    }

    return Semantics(
      button: true,
      label:
      '${jour.day} ${_moisNoms[jour.month - 1]}, ${taches.length} échéance(s)',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => _jour = jour),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selectionne ? couleurs.primary : null,
                border: aujourdhui && !selectionne
                    ? Border.all(color: couleurs.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${jour.day}',
                    style: TextStyle(
                      color: selectionne ? couleurs.onPrimary : null,
                      fontWeight: aujourdhui ? FontWeight.bold : null,
                    ),
                  ),
                  if (taches.isNotEmpty)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: couleurPoint,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tuile(Task t) {
    return ListTile(
      leading: Semantics(
        label: 'Statut de la tâche ${t.titre}',
        child: Checkbox(value: t.terminee, onChanged: (_) => widget.onBasculer(t)),
      ),
      title: Text(
        t.titre,
        style: t.terminee
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        '${formatDate(t.echeance)} · ${nomDuCours(t.coursId) ?? 'Aucun cours'}',
      ),
      trailing: const Icon(Icons.chevron_right, semanticLabel: 'Ouvrir le détail'),
      onTap: () => widget.onOuvrir(t),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premier = DateTime(_mois.year, _mois.month, 1);
    final decalage = premier.weekday - 1; // lundi = 0
    final nbJours = DateTime(_mois.year, _mois.month + 1, 0).day;
    final nbLignes = (decalage + nbJours + 6) ~/ 7;

    final lignes = <Widget>[];
    for (var l = 0; l < nbLignes; l++) {
      final cellules = <Widget>[];
      for (var c = 0; c < 7; c++) {
        final numero = l * 7 + c - decalage + 1;
        final jour = (numero < 1 || numero > nbJours)
            ? null
            : DateTime(_mois.year, _mois.month, numero);
        cellules.add(Expanded(child: _cellule(context, jour)));
      }
      lignes.add(Row(children: cellules));
    }

    final duJour = _tachesDuJour(_jour);
    final styleTitre = Theme.of(context).textTheme.titleMedium;

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Mois précédent',
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changerMois(-1),
                    ),
                    Expanded(
                      child: Text(
                        '${_moisNoms[_mois.month - 1]} ${_mois.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Mois suivant',
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changerMois(1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: _joursNoms
                      .map(
                        (j) => Expanded(
                      child: Center(
                        child: Text(
                          j,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
                const SizedBox(height: 4),
                ...lignes,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '${_jour.day} ${_moisNoms[_jour.month - 1]} ${_jour.year}',
            style: styleTitre,
          ),
        ),
        if (duJour.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucune échéance ce jour'),
          )
        else
          ...duJour.map(_tuile),
      ],
    );
  }
}