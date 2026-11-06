import 'package:flutter/material.dart';

import 'donnees.dart';
import 'models.dart';

/// Liste des échéances : filtres, tri par date, ListView.builder de ListTile.
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

  String _sousTitre(Task t, bool enRetard) {
    final parties = <String>[
      enRetard
          ? 'En retard · ${formatDate(t.echeance)}'
          : 'Pour le ${formatDate(t.echeance)}',
    ];
    final cours = nomDuCours(t.coursId);
    if (cours != null) parties.add(cours);
    return parties.join(' · ');
  }

  Widget _puce(String texte, Filtre f) {
    return ChoiceChip(
      label: Text(texte),
      selected: filtre == f,
      onSelected: (_) => onFiltre(f),
    );
  }

  Widget _ligne(BuildContext context, Task t) {
    final enRetard = !t.terminee && t.echeance.isBefore(DateTime.now());
    return ListTile(
      selected: t.id == selectionId,
      leading: Semantics(
        label: 'Statut de la tâche ${t.titre}',
        child: Checkbox(value: t.terminee, onChanged: (_) => onBasculer(t)),
      ),
      title: Text(
        t.titre,
        style: t.terminee
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        _sousTitre(t, enRetard),
        style: enRetard
            ? TextStyle(color: Theme.of(context).colorScheme.error)
            : null,
      ),
      trailing: const Icon(Icons.chevron_right, semanticLabel: 'Ouvrir le détail'),
      onTap: () => onOuvrir(t),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibles = taches.where(_correspond).toList()
      ..sort((a, b) => a.echeance.compareTo(b.echeance));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              _puce('Toutes', Filtre.toutes),
              _puce('Cette semaine', Filtre.semaine),
              _puce('À faire', Filtre.aFaire),
            ],
          ),
        ),
        Expanded(
          child: visibles.isEmpty
              ? const Center(child: Text('Aucune tâche pour ce filtre'))
              : ListView.builder(
                  itemCount: visibles.length,
                  itemBuilder: (context, i) => _ligne(context, visibles[i]),
                ),
        ),
      ],
    );
  }
}
