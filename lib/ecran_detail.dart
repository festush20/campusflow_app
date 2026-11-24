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

/// Contenu du détail, sans Scaffold : affiché seul (téléphone)
/// ou à droite de la liste (tablette).
class DetailContenu extends StatelessWidget {
  final Task tache;
  final ValueChanged<Task> onChange;
  final VoidCallback? onSupprimer;

  const DetailContenu({
    super.key,
    required this.tache,
    required this.onChange,
    this.onSupprimer,
  });

  Future<void> _confirmerSuppression(BuildContext context) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: Text(tache.titre),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme == true) onSupprimer?.call();
  }

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
          if (onSupprimer != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmerSuppression(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer la tâche'),
            ),
          ],
        ],
      ),
    );
  }
}