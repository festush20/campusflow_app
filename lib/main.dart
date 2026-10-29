import 'package:flutter/material.dart';

import 'models.dart';
import 'repository.dart';

void main() => runApp(const CampusFlowApp());

// Cours de démonstration (même liste utilisée par l'onglet Cours et le formulaire).
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

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEC3013)),
        useMaterial3: true,
      ),
      home: const Accueil(),
    );
  }
}

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _onglet = 0;
  bool _simulerErreur = false;
  bool _chargement = false;
  Filtre _filtre = Filtre.toutes;
  List<Task>? _taches;
  Object? _erreur;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  // Les trois états d'un Future : en cours, valeur, erreur.
  Future<void> _charger() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final resultat = await FakeTaskRepository(echec: _simulerErreur).charger();
      if (!mounted) return;
      setState(() {
        _taches = resultat;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e;
        _chargement = false;
      });
    }
  }

  // Objet immuable : on remplace la tâche par une copie modifiée.
  void _remplacer(Task modifiee) {
    final liste = _taches;
    if (liste == null) return;
    setState(() {
      _taches = liste.map((t) => t.id == modifiee.id ? modifiee : t).toList();
    });
  }

  void _basculer(Task tache) {
    _remplacer(tache.copyWith(terminee: !tache.terminee));
  }

  Future<void> _ouvrirDetail(Task tache) async {
    final modifiee = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => DetailTache(tache: tache)),
    );
    if (modifiee == null || !mounted) return;
    _remplacer(modifiee);
  }

  Future<void> _ajouter() async {
    final liste = _taches ?? <Task>[];
    final nouvelId = liste.isEmpty
        ? 1
        : liste.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    final nouvelle = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => FormulaireTache(nouvelId: nouvelId)),
    );
    if (nouvelle == null || !mounted) return;
    setState(() {
      _taches = [...(_taches ?? <Task>[]), nouvelle];
    });
  }

  bool _estCetteSemaine(Task t) {
    final maintenant = DateTime.now();
    final debut = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final fin = debut.add(const Duration(days: 7));
    return !t.echeance.isBefore(debut) && t.echeance.isBefore(fin);
  }

  bool _correspond(Task t) {
    switch (_filtre) {
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
      enRetard ? 'En retard · ${formatDate(t.echeance)}' : 'Pour le ${formatDate(t.echeance)}',
    ];
    final cours = nomDuCours(t.coursId);
    if (cours != null) parties.add(cours);
    return parties.join(' · ');
  }

  Widget _puce(String texte, Filtre f) {
    return ChoiceChip(
      label: Text(texte),
      selected: _filtre == f,
      onSelected: (_) => setState(() => _filtre = f),
    );
  }

  Widget _ligne(Task t) {
    final enRetard = !t.terminee && t.echeance.isBefore(DateTime.now());
    return ListTile(
      leading: Semantics(
        label: 'Statut de la tâche ${t.titre}',
        child: Checkbox(value: t.terminee, onChanged: (_) => _basculer(t)),
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
      onTap: () => _ouvrirDetail(t),
    );
  }

  Widget _vueEcheances() {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, semanticLabel: 'Erreur'),
              const SizedBox(height: 12),
              Text('Erreur : $_erreur', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _charger,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    final toutes = _taches ?? <Task>[];
    final visibles = toutes.where(_correspond).toList()
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
              : ListView(children: visibles.map(_ligne).toList()),
        ),
      ],
    );
  }

  Widget _vueCours() {
    final toutes = _taches ?? <Task>[];
    return ListView(
      children: coursDemo.map((c) {
        final nombre = toutes.where((t) => t.coursId == c.id).length;
        return ListTile(
          leading: const Icon(Icons.menu_book, semanticLabel: 'Cours'),
          title: Text(c.nom),
          subtitle: Text('${c.enseignant} · $nombre tâche(s)'),
        );
      }).toList(),
    );
  }

  Widget _vueProfil() {
    const utilisateur = User(id: 1, nom: 'Festus', email: 'festus@exemple.com');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person, semanticLabel: 'Profil'),
          ),
          title: Text(utilisateur.nom),
          subtitle: Text(utilisateur.email),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Simuler une erreur réseau'),
          value: _simulerErreur,
          onChanged: (v) => setState(() => _simulerErreur = v),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            setState(() => _onglet = 0);
            _charger();
          },
          child: const Text('Recharger les tâches'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const titres = ['Échéances', 'Cours', 'Profil'];
    final vues = [_vueEcheances(), _vueCours(), _vueProfil()];
    return Scaffold(
      appBar: AppBar(title: Text(titres[_onglet])),
      body: vues[_onglet],
      floatingActionButton: _onglet == 0 && _taches != null
          ? FloatingActionButton(
        onPressed: _ajouter,
        tooltip: 'Nouvelle tâche',
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _onglet,
        onDestinationSelected: (i) => setState(() => _onglet = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Échéances'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Cours'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Écran de détail : renvoie la tâche modifiée (copyWith) à l'écran précédent.
class DetailTache extends StatelessWidget {
  final Task tache;
  const DetailTache({super.key, required this.tache});

  @override
  Widget build(BuildContext context) {
    final cours = nomDuCours(tache.coursId);
    final description = tache.description;
    return Scaffold(
      appBar: AppBar(title: Text(tache.titre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Cours'),
            subtitle: Text(cours ?? 'Aucun cours'),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Échéance'),
            subtitle: Text(formatDate(tache.echeance)),
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Description'),
            subtitle: Text(description ?? 'Aucune description'),
          ),
          ListTile(
            leading: Icon(
              tache.terminee ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
            title: const Text('Statut'),
            subtitle: Text(tache.terminee ? 'Terminée' : 'À faire'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, tache.copyWith(terminee: !tache.terminee)),
            child: Text(
              tache.terminee ? 'Marquer comme à faire' : 'Marquer comme fait',
            ),
          ),
        ],
      ),
    );
  }
}

// Formulaire complet : titre, cours, date, description.
class FormulaireTache extends StatefulWidget {
  final int nouvelId;
  const FormulaireTache({super.key, required this.nouvelId});

  @override
  State<FormulaireTache> createState() => _FormulaireTacheState();
}

class _FormulaireTacheState extends State<FormulaireTache> {
  final _titre = TextEditingController();
  final _description = TextEditingController();
  int? _coursId;
  DateTime _date = DateTime.now().add(const Duration(days: 3));
  String? _erreurTitre;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final choix = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (choix == null || !mounted) return;
    setState(() => _date = DateTime(choix.year, choix.month, choix.day, 17));
  }

  void _enregistrer() {
    final titre = _titre.text.trim();
    if (titre.isEmpty) {
      setState(() => _erreurTitre = 'Le titre est obligatoire');
      return;
    }
    final description = _description.text.trim();
    Navigator.pop(
      context,
      Task(
        id: widget.nouvelId,
        titre: titre,
        echeance: _date,
        description: description.isEmpty ? null : description,
        coursId: _coursId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle tâche')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titre,
            decoration: InputDecoration(
              labelText: 'Titre',
              errorText: _erreurTitre,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButton<int?>(
            isExpanded: true,
            value: _coursId,
            hint: const Text('Cours'),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Aucun cours')),
              ...coursDemo.map(
                    (c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.nom)),
              ),
            ],
            onChanged: (v) => setState(() => _coursId = v),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: const Text('Échéance'),
            subtitle: Text(formatDate(_date)),
            trailing: const Icon(Icons.edit, semanticLabel: 'Changer la date'),
            onTap: _choisirDate,
          ),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description (facultative)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _enregistrer,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}