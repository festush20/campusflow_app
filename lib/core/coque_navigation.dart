import 'package:campusflow_app/features/taches/application/taches_notifier.dart';
import 'package:campusflow_app/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusflow_app/core/etats_ui.dart';

const _chemins = ['/taches', '/calendrier', '/cours', '/profil'];
const _titres = ['Échéances', 'Calendrier', 'Cours', 'Profil'];

int _indexDe(String chemin) {
  for (var i = 0; i < _chemins.length; i++) {
    if (chemin.startsWith(_chemins[i])) return i;
  }
  return 0;
}

class CoqueNavigation extends ConsumerWidget {
  final String chemin;
  final Widget child;

  const CoqueNavigation({super.key, required this.chemin, required this.child});

  Future<void> _ajouter(BuildContext context, WidgetRef ref) async {
    final tache = await context.push<Task>('/taches/nouvelle');
    if (tache == null || !context.mounted) return;
    await executerAction(
      context,
          () => ref.read(tachesProvider.notifier).ajouter(tache),
      succes: 'Tâche ajoutée',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = _indexDe(chemin);
    return Scaffold(
      appBar: AppBar(title: Text(_titres[index])),
      body: child,
      floatingActionButton: index <= 1
          ? FloatingActionButton(
        onPressed: () => _ajouter(context, ref),
        tooltip: 'Nouvelle tâche',
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => context.go(_chemins[i]),
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