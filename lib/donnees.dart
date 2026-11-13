import 'package:intl/intl.dart'; // package ajouté avec : flutter pub add intl

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

/// Ex. « 29/10/2026 à 17h00 » (format fait avec intl).
String formatDate(DateTime d) {
  final jour = DateFormat('dd/MM/yyyy').format(d);
  final heure = DateFormat("HH'h'mm").format(d);
  return '$jour à $heure';
}

/// Ex. « 29/10 ».
String formatJourCourt(DateTime d) => DateFormat('dd/MM').format(d);