import 'package:flutter/material.dart';

import 'donnees.dart';
import 'models.dart';

Widget _ligneInfo(IconData icone, String titre, String valeur) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icone),
    title: Text(titre),
    subtitle: Text(valeur),
  );
}

/// Contenu du détail, sans Scaffold : on peut l'afficher seul (téléphone)
/// ou à droite de la liste (tablette).
class DetailContenu extends StatelessWidget {
  final Task tache;
  final ValueChanged<Task> onChange;

  const DetailContenu({super.key, required this.tache, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final cours = nomDuCours(tache.coursId);
    final description = tache.description;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tache.titre,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _ligneInfo(Icons.school, 'Cours', cours ?? 'Aucun cours'),
                  _ligneInfo(Icons.event, 'Échéance', formatDate(tache.echeance)),
                  _ligneInfo(
                    Icons.notes,
                    'Description',
                    description ?? 'Aucune description',
                  ),
                  _ligneInfo(
                    tache.terminee
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    'Statut',
                    tache.terminee ? 'Terminée' : 'À faire',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                onChange(tache.copyWith(terminee: !tache.terminee)),
            child: Text(
              tache.terminee ? 'Marquer comme à faire' : 'Marquer comme fait',
            ),
          ),
        ],
      ),
    );
  }
}

/// Écran de détail poussé sur la pile (téléphone).
class EcranDetail extends StatefulWidget {
  final Task tache;
  final ValueChanged<Task> onChange;

  const EcranDetail({super.key, required this.tache, required this.onChange});

  @override
  State<EcranDetail> createState() => _EcranDetailState();
}

class _EcranDetailState extends State<EcranDetail> {
  late Task _tache = widget.tache;

  void _changer(Task modifiee) {
    setState(() => _tache = modifiee);
    widget.onChange(modifiee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tache.titre)),
      body: DetailContenu(tache: _tache, onChange: _changer),
    );
  }
}
