import 'package:flutter/material.dart';

import 'donnees.dart';
import 'ecran_calendrier.dart';
import 'ecran_detail.dart';
import 'ecran_echeances.dart';
import 'ecran_formulaire.dart';
import 'ecran_titre.dart';
import 'models.dart';
import 'repository.dart';
import 'theme.dart';

void main() => runApp(const CampusFlowApp());

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.clair(),
      home: Builder(
        builder: (context) => EcranTitre(
          onCommencer: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const Accueil()),
          ),
        ),
      ),
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
  int? _selectionId; // tâche affichée à droite en mode tablette
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

  // Téléphone : le détail est poussé sur la pile d'écrans.
  void _ouvrirDetail(Task tache) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EcranDetail(tache: tache, onChange: _remplacer),
      ),
    );
  }

  Task? _tacheSelectionnee() {
    final liste = _taches;
    final id = _selectionId;
    if (liste == null || id == null) return null;
    for (final t in liste) {
      if (t.id == id) return t;
    }
    return null;
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tâche ajoutée')),
    );
  }

  // Chargement ou erreur : partagé par les onglets Échéances et Calendrier.
  Widget? _etatSpecial() {
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
    return null;
  }

  // Écran 1 + version tablette : LayoutBuilder à 840 dp.
  Widget _vueEcheances() {
    final special = _etatSpecial();
    if (special != null) return special;
    final toutes = _taches ?? <Task>[];
    return LayoutBuilder(
      builder: (context, contraintes) {
        final etendu = contraintes.maxWidth >= 840;
        final liste = ListeEcheances(
          taches: toutes,
          filtre: _filtre,
          selectionId: etendu ? _selectionId : null,
          onFiltre: (f) => setState(() => _filtre = f),
          onOuvrir: etendu
              ? (Task t) => setState(() => _selectionId = t.id)
              : _ouvrirDetail,
          onBasculer: _basculer,
        );
        if (!etendu) return liste;
        final selection = _tacheSelectionnee();
        return Row(
          children: [
            Expanded(flex: 2, child: liste),
            const VerticalDivider(width: 1),
            Expanded(
              flex: 3,
              child: selection == null
                  ? const Center(child: Text('Sélectionne une tâche'))
                  : DetailContenu(tache: selection, onChange: _remplacer),
            ),
          ],
        );
      },
    );
  }

  Widget _vueCalendrier() {
    final special = _etatSpecial();
    if (special != null) return special;
    return EcranCalendrier(
      taches: _taches ?? <Task>[],
      onOuvrir: _ouvrirDetail,
      onBasculer: _basculer,
    );
  }

  Widget _vueCours() {
    final toutes = _taches ?? <Task>[];
    final couleurs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: coursDemo.map((c) {
        final duCours = toutes.where((t) => t.coursId == c.id).toList();
        final faites = duCours.where((t) => t.terminee).length;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: couleurs.primaryContainer,
              foregroundColor: couleurs.onPrimaryContainer,
              child: Text(c.nom.substring(0, 1)),
            ),
            title: Text(c.nom),
            subtitle: Text(
              '${c.enseignant} · ${duCours.length} tâche(s), $faites terminée(s)',
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _vueProfil() {
    const utilisateur = User(id: 1, nom: 'Festus', email: 'festus@exemple.com');
    final couleurs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: couleurs.primary,
              foregroundColor: couleurs.onPrimary,
              child: Text(
                utilisateur.nom.substring(0, 1),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Text(utilisateur.nom, style: Theme.of(context).textTheme.titleLarge),
            Text(utilisateur.email),
            const SizedBox(height: 20),
          ],
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Simuler une erreur réseau'),
                subtitle: const Text('Pour tester le message et « Réessayer »'),
                value: _simulerErreur,
                onChanged: (v) => setState(() => _simulerErreur = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
    const titres = ['Échéances', 'Calendrier', 'Cours', 'Profil'];
    final vues = [_vueEcheances(), _vueCalendrier(), _vueCours(), _vueProfil()];
    return Scaffold(
      appBar: AppBar(title: Text(titres[_onglet])),
      body: vues[_onglet],
      floatingActionButton: _onglet <= 1 && _taches != null
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
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendrier',
          ),
          NavigationDestination(icon: Icon(Icons.school), label: 'Cours'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}