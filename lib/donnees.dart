import 'models.dart';

// Cours de démonstration (utilisés par l'onglet Cours et le formulaire).
const coursDemo = [
  Course(id: 1, nom: 'Programmation mobile', enseignant: 'Enseignant 1'),
  Course(id: 2, nom: 'XML et Web sémantique', enseignant: 'Enseignant 2'),
  Course(id: 3, nom: 'Services Web SOAP', enseignant: 'Enseignant 3'),
];

enum Filtre { toutes, semaine, aFaire }

String? nomDuCours(int? id) {
  if (id == null) return null;
  for (final c in coursDemo) {
    if (c.id == id) return c.nom;
  }
  return null;
}

String formatDate(DateTime d) {
  final jour = d.day.toString().padLeft(2, '0');
  final mois = d.month.toString().padLeft(2, '0');
  final heure = d.hour.toString().padLeft(2, '0');
  final minute = d.minute.toString().padLeft(2, '0');
  return '$jour/$mois/${d.year} à ${heure}h$minute';
}
