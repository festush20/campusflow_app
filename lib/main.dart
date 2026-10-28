import 'package:flutter/material.dart';

import 'models.dart';
import 'repository.dart';

void main() => runApp(const CampusFlowApp());

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

  // Objet immuable : on remplace la tâche par une copie modifiée (copyWith).
  void _basculer(Task tache) {
    final liste = _taches;
    if (liste == null) return;
    setState(() {
      _taches = liste
          .map((t) => t.id == tache.id ? t.copyWith(terminee: !t.terminee) : t)
          .toList();
    });
  }

  Future<void> _ajouter() async {
    final controleur = TextEditingController();
    final titre = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle tâche'),
        content: TextField(
          controller: controleur,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Titre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controleur.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (titre == null || titre.isEmpty) return;
    final liste = _taches ?? <Task>[];
    final nouvelId = liste.isEmpty
        ? 1
        : liste.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
    setState(() {
      _taches = [
        ...liste,
        Task(
          id: nouvelId,
          titre: titre,
          echeance: DateTime.now().add(const Duration(days: 3)),
        ),
      ];
    });
  }

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _sousTitre(Task t) {
    final base = 'Pour le ${_date(t.echeance)}';
    final description = t.description;
    return description == null ? base : '$base · $description';
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
              const Icon(Icons.error_outline, size: 48),
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
    final liste = _taches ?? <Task>[];
    if (liste.isEmpty) {
      return const Center(child: Text('Aucune tâche'));
    }
    return ListView(
      children: liste
          .map(
            (t) => ListTile(
              leading: Checkbox(
                value: t.terminee,
                onChanged: (_) => _basculer(t),
              ),
              title: Text(
                t.titre,
                style: t.terminee
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              subtitle: Text(_sousTitre(t)),
              onTap: () => _basculer(t),
            ),
          )
          .toList(),
    );
  }

  Widget _vueCours() {
    const cours = [
      Course(id: 1, nom: 'Programmation mobile', enseignant: 'Enseignant 1'),
      Course(id: 2, nom: 'XML et Web sémantique', enseignant: 'Enseignant 2'),
      Course(id: 3, nom: 'Services Web SOAP', enseignant: 'Enseignant 3'),
    ];
    return ListView(
      children: cours
          .map(
            (c) => ListTile(
              leading: const Icon(Icons.menu_book),
              title: Text(c.nom),
              subtitle: Text(c.enseignant),
            ),
          )
          .toList(),
    );
  }

  Widget _vueProfil() {
    const utilisateur = User(id: 1, nom: 'Festus', email: 'festus@exemple.com');
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
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
